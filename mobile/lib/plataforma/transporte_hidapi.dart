// Transporte USB para Linux e Windows via hidapi. A leitura bloqueante
// roda num isolate próprio para não travar a interface.
//
// Quem fecha o dispositivo é o isolate de leitura, e só depois de sair do
// laço: fechar pelo lado principal enquanto o `hid_read_timeout` ainda roda
// seria usar um handle já liberado (queda do app). O lado principal só pede a
// parada e libera a memória compartilhada quando o isolate termina.
import 'dart:async';
import 'dart:ffi';
import 'dart:io' show sleep;
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import '../nucleo/protocolo/erros_anagram.dart';
import '../nucleo/protocolo/quadros_hid.dart';
import '../nucleo/protocolo/transporte_anagram.dart';
import '../nucleo/registro.dart';
import 'hidapi_ffi.dart';

/// Uma interface da Anagram que o `hid_enumerate` listou.
class CandidatoHid {
  const CandidatoHid(this.caminho, {required this.paginaDeUso, required this.numeroInterface});
  final String caminho;
  final int paginaDeUso;
  final int numeroInterface;

  bool get ehFornecedor => ProtocoloAnagram.paginasDeUsoFornecedor.contains(paginaDeUso);

  @override
  String toString() => '$caminho (página 0x${paginaDeUso.toRadixString(16)}, interface $numeroInterface)';
}

/// Ordem de tentativa: a interface de fornecedor; se nenhuma se anunciar
/// (hidraw antigo devolve página 0), todas, pela ordem do número da interface,
/// para a escolha não depender da ordem em que o sistema as listou.
List<CandidatoHid> ordenarCandidatos(List<CandidatoHid> candidatos) {
  final fornecedor = candidatos.where((c) => c.ehFornecedor).toList();
  if (fornecedor.isNotEmpty) return fornecedor;
  return [...candidatos]..sort((a, b) => a.numeroInterface.compareTo(b.numeroInterface));
}

class TransporteHidapi with FluxosDoTransporte implements TransporteAnagram {
  /// Quanto o isolate espera por um relatório antes de olhar se deve parar.
  static const prazoLeitura = Duration(milliseconds: 100);

  HidApi? _api;
  _SessaoLeitura? _sessao;

  @override
  Duration get pausaSugerida => const Duration(milliseconds: 10);

  @override
  String get descricao => 'USB (hidapi)';

  @override
  bool get aberto => _sessao != null;

  @override
  Future<void> abrir() async {
    final api = _api ??= HidApi.carregar();
    if (api == null) {
      throw const ErroPlataformaSemSuporte(
          'Biblioteca hidapi não encontrada. Linux: instale libhidapi-hidraw0. Windows: coloque hidapi.dll junto do app.');
    }
    api.hid_init();
    final candidatos = ordenarCandidatos(_listarCandidatos(api));
    if (candidatos.isEmpty) throw const ErroDesconectado('Nenhuma Anagram no USB.');
    final dispositivo = _abrirPrimeiro(api, candidatos);
    if (dispositivo == nullptr) {
      throw const ErroInterfaceOcupada('A interface de controle não abriu (Suite aberto ou sem permissão udev).');
    }
    _sessao = await _SessaoLeitura.iniciar(api, dispositivo, aoReceber: entregarRelatorio, aoPerder: _aoPerder);
    anunciarEstado(EstadoTransporte.aberto);
  }

  static List<CandidatoHid> _listarCandidatos(HidApi api) {
    final lista = api.hid_enumerate(ProtocoloAnagram.idFornecedor, ProtocoloAnagram.idProduto);
    final candidatos = [
      for (var item = lista; item != nullptr; item = item.ref.next)
        CandidatoHid(item.ref.path.toDartString(),
            paginaDeUso: item.ref.usagePage, numeroInterface: item.ref.interfaceNumber),
    ];
    if (lista != nullptr) api.hid_free_enumeration(lista);
    return candidatos;
  }

  /// Tenta cada interface na ordem e registra qual abriu: quando a página de
  /// uso não vem, é o único jeito de saber depois qual foi a escolhida.
  static Pointer<Void> _abrirPrimeiro(HidApi api, List<CandidatoHid> candidatos) {
    for (final candidato in candidatos) {
      final nativo = candidato.caminho.toNativeUtf8();
      final dispositivo = api.hid_open_path(nativo);
      calloc.free(nativo);
      if (dispositivo != nullptr) {
        registro.i('hidapi: abriu $candidato');
        return dispositivo;
      }
      registro.w('hidapi: não abriu $candidato');
    }
    return nullptr;
  }

  void _aoPerder(_SessaoLeitura sessao) {
    // aviso atrasado de uma sessão que já foi fechada não derruba a atual
    if (!identical(sessao, _sessao)) return;
    _soltar();
    anunciarEstado(EstadoTransporte.perdido);
  }

  @override
  Future<void> enviarRelatorio(Uint8List relatorio) async {
    final api = _api;
    final sessao = _sessao;
    if (api == null || sessao == null) throw const ErroDesconectado('USB fechado.');
    final memoria = calloc<Uint8>(relatorio.length);
    memoria.asTypedList(relatorio.length).setAll(0, relatorio);
    final escritos = api.hid_write(sessao.dispositivo, memoria, relatorio.length);
    calloc.free(memoria);
    if (escritos < 0) throw const ErroDesconectado('Falha de escrita no USB.');
  }

  @override
  Future<void> fechar() async {
    _soltar();
    anunciarEstado(EstadoTransporte.fechado);
  }

  void _soltar() {
    _sessao?.pedirParada();
    _sessao = null;
  }
}

/// Uma leitura em curso: o isolate, a bandeira de parada (memória nativa
/// compartilhada) e a porta por onde chegam relatórios e avisos.
class _SessaoLeitura {
  _SessaoLeitura._(this._api, this.dispositivo, this._parar, this._porta, this._aoReceber, this._aoPerder);

  final HidApi _api;
  final Pointer<Void> dispositivo;
  final Pointer<Int32> _parar;
  final ReceivePort _porta;
  final void Function(Uint8List) _aoReceber;
  final void Function(_SessaoLeitura) _aoPerder;
  bool _paradaPedida = false;
  bool _liberada = false;

  static Future<_SessaoLeitura> iniciar(HidApi api, Pointer<Void> dispositivo,
      {required void Function(Uint8List) aoReceber, required void Function(_SessaoLeitura) aoPerder}) async {
    final sessao = _SessaoLeitura._(api, dispositivo, calloc<Int32>(), ReceivePort(), aoReceber, aoPerder);
    sessao._porta.listen(sessao._aoMensagem);
    // onExit manda `null` pela mesma porta: é por ele que se sabe que o
    // isolate não toca mais na bandeira nem no dispositivo
    try {
      await Isolate.spawn(
        _lerEmLaco,
        _PedidoLeitura(sessao._porta.sendPort, dispositivo.address, sessao._parar.address, api.nomeBiblioteca),
        onExit: sessao._porta.sendPort,
      );
    } on Object catch (erro, pilha) {
      // sem isolate ninguém mais vai fechar o dispositivo: fecha aqui
      registro.e('hidapi: a leitura não começou', error: erro, stackTrace: pilha);
      sessao._liberar();
      api.hid_close(dispositivo);
      throw const ErroDesconectado('Não foi possível começar a ler o USB.');
    }
    return sessao;
  }

  void _aoMensagem(Object? mensagem) {
    if (mensagem is Uint8List) {
      if (!_paradaPedida) _aoReceber(mensagem);
    } else if (mensagem == _PedidoLeitura.avisoPerdido) {
      _aoPerder(this);
    } else if (mensagem == null) {
      _liberar();
      // o isolate só sai do laço depois da parada; sem ela, ele caiu antes do
      // hid_close e o dispositivo ainda está aberto
      if (!_paradaPedida) _aoMorrerSemParada();
    }
  }

  void pedirParada() {
    // depois de liberada, a bandeira é memória devolvida: não se escreve nela
    if (_paradaPedida || _liberada) return;
    _paradaPedida = true;
    _parar.value = 1;
  }

  void _aoMorrerSemParada() {
    registro.e('hidapi: a leitura parou sem ninguém pedir');
    _api.hid_close(dispositivo);
    _aoPerder(this);
  }

  void _liberar() {
    _liberada = true;
    _porta.close();
    calloc.free(_parar);
  }
}

class _PedidoLeitura {
  const _PedidoLeitura(this.porta, this.dispositivo, this.parar, this.biblioteca);

  /// O isolate avisa que a leitura falhou (cabo saiu) e espera a parada.
  static const avisoPerdido = 'perdido';

  final SendPort porta;
  final int dispositivo;
  final int parar;
  final String biblioteca;
}

/// Lê até pedirem a parada. Se a leitura falhar antes, avisa e continua
/// esperando a parada sem fechar nada: o lado principal pode estar no meio de
/// um `hid_write` com este mesmo dispositivo.
void _lerEmLaco(_PedidoLeitura pedido) {
  final api = HidApi.carregar(pedido.biblioteca)!;
  final dispositivo = Pointer<Void>.fromAddress(pedido.dispositivo);
  final parar = Pointer<Int32>.fromAddress(pedido.parar);
  final memoria = calloc<Uint8>(ProtocoloAnagram.tamanhoRelatorio);
  final prazo = TransporteHidapi.prazoLeitura.inMilliseconds;
  var avisou = false;
  while (parar.value == 0) {
    if (avisou) {
      sleep(TransporteHidapi.prazoLeitura);
      continue;
    }
    final lidos = api.hid_read_timeout(dispositivo, memoria, ProtocoloAnagram.tamanhoRelatorio, prazo);
    if (lidos < 0) {
      pedido.porta.send(_PedidoLeitura.avisoPerdido);
      avisou = true;
    } else if (lidos > 0) {
      pedido.porta.send(Uint8List.fromList(memoria.asTypedList(lidos)));
    }
  }
  api.hid_close(dispositivo);
  calloc.free(memoria);
}
