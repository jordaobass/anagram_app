// Saída MIDI para a Anagram. O HID não tem comando de "selecionar slot":
// a troca de verdade é Program Change pelo USB MIDI (interface própria, que
// funciona junto com o HID). A pedaleira precisa do USB MIDI ligado nos
// ajustes de MIDI dela.
import '../modelo/slot_preset.dart';

abstract final class MensagensMidi {
  static const canal = 0; // canal 1

  /// Conferido no anagram-tone-maker (midi.py `goto_slot`): o programa é o
  /// próprio número do slot, contando de 1 (17A = slot 49 = programa 49),
  /// sem bank select.
  static List<int> trocaDePrograma(SlotPreset slot) => [0xC0 | canal, slot.numero & 0x7F];
}

abstract interface class SaidaMidiAnagram {
  String get descricao;
  bool get aberta;

  /// Abre a porta MIDI da Anagram. Lança [ErroAnagram] se não achar.
  Future<void> abrir();

  Future<void> enviar(List<int> mensagem);
  Future<void> fechar();
}

/// Pedaleira simulada: só anota o que recebeu.
class SaidaMidiDemonstracao implements SaidaMidiAnagram {
  SaidaMidiDemonstracao({this.atrasoAoAbrir = Duration.zero});

  /// Simula uma porta MIDI lenta para abrir (testes de cancelamento).
  final Duration atrasoAoAbrir;
  final List<List<int>> mensagens = [];
  bool _aberta = false;

  @override
  String get descricao => 'MIDI (demonstração)';

  @override
  bool get aberta => _aberta;

  @override
  Future<void> abrir() async {
    if (atrasoAoAbrir > Duration.zero) await Future<void>.delayed(atrasoAoAbrir);
    _aberta = true;
  }

  @override
  Future<void> enviar(List<int> mensagem) async => mensagens.add(List.of(mensagem));

  @override
  Future<void> fechar() async => _aberta = false;
}
