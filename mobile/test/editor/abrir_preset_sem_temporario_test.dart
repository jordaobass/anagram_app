// Abrir um preset troca o slot da pedaleira por Program Change, e isso já
// carrega o preset salvo. Mandar também o "preset temporário" (try) logo em
// seguida fazia a tela da Anagram mostrar outro slot (teste real do usuário:
// tocou no 15B e a pedaleira mostrou o 05B ou um slot vazio).
import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/midi/saida_midi.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:anagram_app/nucleo/protocolo/api_anagram.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';

Future<(ProviderContainer, TransporteDemonstracao, SaidaMidiDemonstracao)> _conectar({required bool comMidi}) async {
  final midi = SaidaMidiDemonstracao();
  final container = ProviderContainer(overrides: [
    presetsDemonstracaoProvider.overrideWith((ref) async => lerPresetsDemonstracao()),
    midiDemonstracaoProvider.overrideWithValue(() => comMidi ? midi : null),
  ]);
  await container.read(conexaoProvider.notifier).conectarDemonstracao();
  final pedaleira = container.read(conexaoProvider.notifier).transporte! as TransporteDemonstracao;
  return (container, pedaleira, midi);
}

int _temporarios(TransporteDemonstracao p) => p.comandosRecebidos.where((c) => c.acao == AcoesAnagram.tocarAoVivo).length;

void main() {
  test('should_only_send_program_change_when_opening_a_preset_with_midi', () async {
    final (container, pedaleira, midi) = await _conectar(comMidi: true);

    await container.read(editorProvider.notifier).abrirSlot(SlotPreset.doRotulo('02A'));

    expect(midi.mensagens, [MensagensMidi.trocaDePrograma(SlotPreset.doRotulo('02A'))]);
    expect(_temporarios(pedaleira), 0, reason: 'o Program Change já carrega o preset salvo');
  });

  test('should_send_the_preset_to_listen_when_there_is_no_midi_to_switch_the_slot', () async {
    final (container, pedaleira, _) = await _conectar(comMidi: false);

    await container.read(editorProvider.notifier).abrirSlot(SlotPreset.doRotulo('02A'));

    expect(_temporarios(pedaleira), 1, reason: 'sem MIDI, o temporário é o único jeito de ouvir o preset');
  });

  test('should_still_send_live_edits_after_opening_with_program_change', () async {
    final (container, pedaleira, _) = await _conectar(comMidi: true);
    final editor = container.read(editorProvider.notifier);
    await editor.abrirSlot(SlotPreset.doRotulo('02A'));

    await editor.renomear('Editado');

    expect(_temporarios(pedaleira), 1, reason: 'a edição ao vivo continua indo para a pedaleira');
  });

  test('should_take_the_pedal_to_the_saved_slot_after_saving_in_the_same_slot', () async {
    // a edição ao vivo deixa a pedaleira tocando o "temporário", fora do slot;
    // depois de salvar ela tem de voltar ao slot, agora com o preset gravado
    final (container, _, midi) = await _conectar(comMidi: true);
    final editor = container.read(editorProvider.notifier);
    await editor.abrirSlot(SlotPreset.doRotulo('02A'));
    await editor.renomear('Editado');
    midi.mensagens.clear();

    await editor.salvar();

    expect(midi.mensagens, [MensagensMidi.trocaDePrograma(SlotPreset.doRotulo('02A'))]);
  });
}
