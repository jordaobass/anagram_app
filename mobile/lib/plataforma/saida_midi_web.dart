// Web MIDI (Chrome/Edge): procura a saída cujo nome contém "Anagram".
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import '../nucleo/midi/saida_midi.dart';
import '../nucleo/protocolo/erros_anagram.dart';

extension type _AcessoMidi._(JSObject _) implements JSObject {
  external JSObject get outputs;
}

extension type _SaidaMidi._(JSObject _) implements JSObject {
  external String? get name;
  external void send(JSUint8Array dados);
}

class SaidaMidiWeb implements SaidaMidiAnagram {
  _SaidaMidi? _saida;

  @override
  String get descricao => 'Web MIDI';

  @override
  bool get aberta => _saida != null;

  @override
  Future<void> abrir() async {
    final navegador = globalContext.getProperty<JSObject>('navigator'.toJS);
    if (!navegador.has('requestMIDIAccess')) {
      throw const ErroPlataformaSemSuporte('Este navegador não tem Web MIDI.');
    }
    final promessa = navegador.callMethod<JSPromise<_AcessoMidi>>('requestMIDIAccess'.toJS);
    final acesso = await promessa.toDart;
    final encontradas = <_SaidaMidi>[];
    acesso.outputs.callMethod<JSAny?>(
      'forEach'.toJS,
      ((_SaidaMidi saida, JSAny _) {
        if ((saida.name ?? '').toLowerCase().contains('anagram')) encontradas.add(saida);
      }).toJS,
    );
    if (encontradas.isEmpty) throw const ErroDesconectado('Nenhuma saída MIDI "Anagram".');
    _saida = encontradas.first;
  }

  @override
  Future<void> enviar(List<int> mensagem) async => _saida?.send(Uint8List.fromList(mensagem).toJS);

  @override
  Future<void> fechar() async => _saida = null;
}
