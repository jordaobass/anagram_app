// USB MIDI pelo lado nativo: CoreMIDI no macOS/iOS, android.media.midi no
// Android. Procura a porta de saída cujo nome contém "Anagram".
import 'package:flutter/services.dart';

import '../nucleo/midi/saida_midi.dart';
import '../nucleo/protocolo/erros_anagram.dart';

class SaidaMidiNativa implements SaidaMidiAnagram {
  static const _canal = MethodChannel('anagram_app/midi');
  static const nomeDaPorta = 'Anagram';

  bool _aberta = false;

  @override
  String get descricao => 'USB MIDI';

  @override
  bool get aberta => _aberta;

  @override
  Future<void> abrir() async {
    try {
      await _canal.invokeMethod<void>('abrir', {'nome': nomeDaPorta});
      _aberta = true;
    } on PlatformException catch (erro) {
      throw ErroDesconectado('MIDI: ${erro.message ?? erro.code}');
    } on MissingPluginException {
      throw const ErroPlataformaSemSuporte('MIDI indisponível nesta plataforma.');
    }
  }

  @override
  Future<void> enviar(List<int> mensagem) async {
    try {
      await _canal.invokeMethod<void>('enviar', Uint8List.fromList(mensagem));
    } on PlatformException catch (erro) {
      throw ErroDesconectado('MIDI: ${erro.message ?? erro.code}');
    }
  }

  @override
  Future<void> fechar() async {
    _aberta = false;
    await _canal.invokeMethod<void>('fechar');
  }
}
