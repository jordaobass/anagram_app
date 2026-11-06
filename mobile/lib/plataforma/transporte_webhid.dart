// Transporte WebHID. O navegador entrega relatórios sem o id (0x01), e o
// envio leva o id à parte: por isso o primeiro byte é separado aqui.
import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import '../nucleo/protocolo/erros_anagram.dart';
import '../nucleo/protocolo/quadros_hid.dart';
import '../nucleo/protocolo/transporte_anagram.dart';
import '../nucleo/registro.dart';

extension type _Hid._(JSObject _) implements JSObject {
  external JSPromise<JSArray<_DispositivoHid>> requestDevice(JSAny opcoes);
  external void addEventListener(String tipo, JSFunction ouvinte);
  external void removeEventListener(String tipo, JSFunction ouvinte);
}

extension type _DispositivoHid._(JSObject _) implements JSObject {
  external bool get opened;
  external JSArray<_Colecao> get collections;
  external JSPromise<JSAny?> open();
  external JSPromise<JSAny?> close();
  external JSPromise<JSAny?> sendReport(int idRelatorio, JSUint8Array dados);
  external void addEventListener(String tipo, JSFunction ouvinte);
  external void removeEventListener(String tipo, JSFunction ouvinte);
}

extension type _Colecao._(JSObject _) implements JSObject {
  external int get usagePage;
}

extension type _EventoHid._(JSObject _) implements JSObject {
  external JSDataView get data;
  external _DispositivoHid get device;
}

class TransporteWebHid with FluxosDoTransporte implements TransporteAnagram {
  static const _eventoRelatorio = 'inputreport';
  static const _eventoDesconexao = 'disconnect';

  _DispositivoHid? _dispositivo;

  // `.toJS` cria uma função JS nova a cada chamada: para remover o ouvinte no
  // fechar é preciso guardar exatamente a que foi registrada.
  late final JSFunction _ouvinteRelatorio = _aoReceber.toJS;
  late final JSFunction _ouvinteDesconexao = _aoDesconectar.toJS;

  @override
  Duration get pausaSugerida => const Duration(milliseconds: 10);

  @override
  String get descricao => 'WebHID';

  @override
  bool get aberto => _dispositivo?.opened ?? false;

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
    dispositivo.addEventListener(_eventoRelatorio, _ouvinteRelatorio);
    _hid.addEventListener(_eventoDesconexao, _ouvinteDesconexao);
    _dispositivo = dispositivo;
    anunciarEstado(EstadoTransporte.aberto);
  }

  static bool _ehFornecedor(_DispositivoHid d) =>
      d.collections.toDart.any((c) => ProtocoloAnagram.paginasDeUsoFornecedor.contains(c.usagePage));

  void _aoReceber(_EventoHid evento) {
    final dados = evento.data.toDart;
    entregarRelatorio(dados.buffer.asUint8List(dados.offsetInBytes, dados.lengthInBytes));
  }

  void _aoDesconectar(_EventoHid evento) {
    final atual = _dispositivo;
    if (atual == null || !evento.device.strictEquals(atual).toDart) return;
    _soltar(atual);
    anunciarEstado(EstadoTransporte.perdido);
  }

  /// Tira os ouvintes: sem isso cada reconexão empilha mais um no navegador.
  void _soltar(_DispositivoHid dispositivo) {
    _dispositivo = null;
    dispositivo.removeEventListener(_eventoRelatorio, _ouvinteRelatorio);
    _hid.removeEventListener(_eventoDesconexao, _ouvinteDesconexao);
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
    if (dispositivo != null) {
      _soltar(dispositivo);
      // como nos outros transportes, fechar não lança: só registra
      try {
        await dispositivo.close().toDart;
      } catch (erro) {
        registro.w('WebHID: o navegador falhou ao fechar a pedaleira', error: erro);
      }
    }
    anunciarEstado(EstadoTransporte.fechado);
  }
}
