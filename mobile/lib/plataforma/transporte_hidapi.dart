// Transporte USB para Linux e Windows via hidapi. A leitura bloqueante
// roda num isolate próprio para não travar a interface.
import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import '../nucleo/protocolo/erros_anagram.dart';
import '../nucleo/protocolo/quadros_hid.dart';
import '../nucleo/protocolo/transporte_anagram.dart';
import 'hidapi_ffi.dart';

class TransporteHidapi implements TransporteAnagram {
  final _estados = StreamController<EstadoTransporte>.broadcast();
  final _entrada = StreamController<Uint8List>.broadcast();
  HidApi? _api;
  Pointer<Void> _dispositivo = nullptr;
  Pointer<Int32> _parar = nullptr;
  ReceivePort? _porta;

  @override
  Duration get pausaSugerida => const Duration(milliseconds: 10);

  @override
  String get descricao => 'USB (hidapi)';

  @override
  bool get aberto => _dispositivo != nullptr;

  @override
  Stream<EstadoTransporte> get estados => _estados.stream;

  @override
  Stream<Uint8List> get relatoriosRecebidos => _entrada.stream;

  @override
  Future<void> abrir() async {
    final api = _api ??= HidApi.carregar();
    if (api == null) {
      throw const ErroPlataformaSemSuporte(
          'Biblioteca hidapi não encontrada. Linux: instale libhidapi-hidraw0. Windows: coloque hidapi.dll junto do app.');
    }
    api.hid_init();
    final caminhos = _caminhosDaAnagram(api);
    if (caminhos.isEmpty) throw const ErroDesconectado('Nenhuma Anagram no USB.');
    for (final caminho in caminhos) {
      final nativo = caminho.toNativeUtf8();
      _dispositivo = api.hid_open_path(nativo);
      calloc.free(nativo);
      if (_dispositivo != nullptr) break;
    }
    if (_dispositivo == nullptr) {
      throw const ErroInterfaceOcupada('A interface de controle não abriu (Suite aberto ou sem permissão udev).');
    }
    await _iniciarLeitura(api);
    _estados.add(EstadoTransporte.aberto);
  }

  /// Interface de fornecedor primeiro; as outras só se ela não aparecer.
  static List<String> _caminhosDaAnagram(HidApi api) {
    final lista = api.hid_enumerate(ProtocoloAnagram.idFornecedor, ProtocoloAnagram.idProduto);
    final fornecedor = <String>[];
    final outras = <String>[];
    for (var item = lista; item != nullptr; item = item.ref.next) {
      final caminho = item.ref.path.toDartString();
      final ehFornecedor = ProtocoloAnagram.paginasDeUsoFornecedor.contains(item.ref.usagePage);
      (ehFornecedor ? fornecedor : outras).add(caminho);
    }
    if (lista != nullptr) api.hid_free_enumeration(lista);
    return fornecedor.isNotEmpty ? fornecedor : outras;
  }

  Future<void> _iniciarLeitura(HidApi api) async {
    _parar = calloc<Int32>();
    final porta = ReceivePort();
    _porta = porta;
    porta.listen((mensagem) {
      if (mensagem is Uint8List) {
        _entrada.add(mensagem);
      } else if (mensagem == 'perdido') {
        _soltar();
        _estados.add(EstadoTransporte.perdido);
      }
    });
    await Isolate.spawn(
      _lerEmLaco,
      _PedidoLeitura(porta.sendPort, _dispositivo.address, _parar.address, api.nomeBiblioteca),
    );
  }

  @override
  Future<void> enviarRelatorio(Uint8List relatorio) async {
    final api = _api;
    if (api == null || !aberto) throw const ErroDesconectado('USB fechado.');
    final memoria = calloc<Uint8>(relatorio.length);
    memoria.asTypedList(relatorio.length).setAll(0, relatorio);
    final escritos = api.hid_write(_dispositivo, memoria, relatorio.length);
    calloc.free(memoria);
    if (escritos < 0) throw const ErroDesconectado('Falha de escrita no USB.');
  }

  @override
  Future<void> fechar() async {
    _soltar();
    _estados.add(EstadoTransporte.fechado);
  }

  void _soltar() {
    final parar = _parar;
    final dispositivo = _dispositivo;
    _parar = nullptr;
    _dispositivo = nullptr;
    if (parar != nullptr) parar.value = 1;
    // dá tempo do isolate sair do hid_read_timeout (100 ms) antes de fechar
    Timer(const Duration(milliseconds: 250), () {
      if (dispositivo != nullptr) _api?.hid_close(dispositivo);
      if (parar != nullptr) calloc.free(parar);
    });
    _porta?.close();
    _porta = null;
  }
}

class _PedidoLeitura {
  const _PedidoLeitura(this.porta, this.dispositivo, this.parar, this.biblioteca);
  final SendPort porta;
  final int dispositivo;
  final int parar;
  final String biblioteca;
}

void _lerEmLaco(_PedidoLeitura pedido) {
  final api = HidApi.carregar(pedido.biblioteca)!;
  final dispositivo = Pointer<Void>.fromAddress(pedido.dispositivo);
  final parar = Pointer<Int32>.fromAddress(pedido.parar);
  final memoria = calloc<Uint8>(ProtocoloAnagram.tamanhoRelatorio);
  while (parar.value == 0) {
    final lidos = api.hid_read_timeout(dispositivo, memoria, ProtocoloAnagram.tamanhoRelatorio, 100);
    if (lidos < 0) {
      if (parar.value == 0) pedido.porta.send('perdido');
      break;
    }
    if (lidos > 0) pedido.porta.send(Uint8List.fromList(memoria.asTypedList(lidos)));
  }
  calloc.free(memoria);
}
