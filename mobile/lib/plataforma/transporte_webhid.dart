// Transporte WebHID. O navegador entrega relatórios sem o id (0x01), e o
// envio leva o id à parte: por isso o primeiro byte é separado aqui.
import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import '../nucleo/protocolo/erros_anagram.dart';
import '../nucleo/protocolo/quadros_hid.dart';
import '../nucleo/protocolo/transporte_anagram.dart';

extension type _Hid._(JSObject _) implements JSObject {
  external JSPromise<JSArray<_DispositivoHid>> requestDevice(JSAny opcoes);
  external void addEventListener(String tipo, JSFunction ouvinte);
}

extension type _DispositivoHid._(JSObject _) implements JSObject {
  external bool get opened;
  external JSArray<_Colecao> get collections;
  external JSPromise<JSAny?> open();
  external JSPromise<JSAny?> close();
  external JSPromise<JSAny?> sendReport(int idRelatorio, JSUint8Array dados);
  external void addEventListener(String tipo, JSFunction ouvinte);
}

extension type _Colecao._(JSObject _) implements JSObject {
  external int get usagePage;
}

extension type _EventoHid._(JSObject _) implements JSObject {
  external JSDataView get data;
  external _DispositivoHid get device;
}

class TransporteWebHid implements TransporteAnagram {
  final _estados = StreamController<EstadoTransporte>.broadcast();
  final _entrada = StreamController<Uint8List>.broadcast();
  _DispositivoHid? _dispositivo;

  @override
  Duration get pausaSugerida => const Duration(milliseconds: 10);

  @override
  String get descricao => 'WebHID';

  @override
  bool get aberto => _dispositivo?.opened ?? false;

  @override
  Stream<EstadoTransporte> get estados => _estados.stream;

  @override
  Stream<Uint8List> get relatoriosRecebidos => _entrada.stream;

  _Hid get _hid => globalContext.getProperty<JSObject>('navigator'.toJS).getProperty<_Hid>('hid'.toJS);

  @override
  Future<void> abrir() async {
    final filtros = {
      'filters': [
        {'vendorId': ProtocoloAnagram.idFornecedor, 'productId': ProtocoloAnagram.idProduto},
      ],
    }.jsify()!;
    final escolhidos = (await _hid.requestDevice(filtros).toDart).toDart;
    if (escolhidos.isEmpty) throw const ErroDesconectado('Nenhuma pedaleira escolhida.');
    final dispositivo = escolhidos.firstWhere(_ehFornecedor, orElse: () => escolhidos.first);
    try {
      if (!dispositivo.opened) await dispositivo.open().toDart;
    } catch (erro) {
      throw ErroInterfaceOcupada('$erro');
    }
    dispositivo.addEventListener('inputreport', _aoReceber.toJS);
    _hid.addEventListener('disconnect', _aoDesconectar.toJS);
    _dispositivo = dispositivo;
    _estados.add(EstadoTransporte.aberto);
  }

  static bool _ehFornecedor(_DispositivoHid d) =>
      d.collections.toDart.any((c) => ProtocoloAnagram.paginasDeUsoFornecedor.contains(c.usagePage));

  void _aoReceber(_EventoHid evento) {
    final dados = evento.data.toDart;
    _entrada.add(dados.buffer.asUint8List(dados.offsetInBytes, dados.lengthInBytes));
  }

  void _aoDesconectar(_EventoHid evento) {
    final atual = _dispositivo;
    if (atual == null || !evento.device.strictEquals(atual).toDart) return;
    _dispositivo = null;
    _estados.add(EstadoTransporte.perdido);
  }

  @override
  Future<void> enviarRelatorio(Uint8List relatorio) async {
    final dispositivo = _dispositivo;
    if (dispositivo == null) throw const ErroDesconectado('WebHID fechado.');
    await dispositivo.sendReport(relatorio.first, relatorio.sublist(1).toJS).toDart;
  }

  @override
  Future<void> fechar() async {
    final dispositivo = _dispositivo;
    _dispositivo = null;
    if (dispositivo != null) await dispositivo.close().toDart;
    _estados.add(EstadoTransporte.fechado);
  }
}
