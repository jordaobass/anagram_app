import 'package:anagram_app/aplicacao/casos_de_uso/salvar_no_slot.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/conexao_demo.dart';

void main() {
  test('should_rename_remove_block_and_play_it_live', () async {
    final (container, pedaleira) = await conectarDemonstracao();
    final editor = container.read(editorProvider.notifier);
    await editor.abrirSlot(SlotPreset(3));

    await editor.renomear('Grave de Igreja');
    await editor.removerBloco(const PosicaoBloco(1, 1));

    final estado = container.read(editorProvider);
    expect(estado.atual!.nome, 'Grave de Igreja');
    expect(estado.atual!.bloco(const PosicaoBloco(1, 1)), isNull);
    expect(estado.naoSalvo, isTrue);
    expect(pedaleira.presetTocando!['preset']['name'], 'Grave de Igreja');
  });

  test('should_create_a_new_preset_in_an_empty_slot_and_save_it_there', () async {
    final (container, pedaleira) = await conectarDemonstracao();
    final editor = container.read(editorProvider.notifier);
    await editor.abrirSlot(SlotPreset.doRotulo('03C'));
    expect(container.read(editorProvider).atual, isNull);

    await editor.novoPresetNoSlot();
    final resultado = await editor.salvar();

    expect(resultado, isA<PresetSalvo>());
    expect(pedaleira.conteudoDoSlot(9)!['preset']['name'], 'Novo preset');
  });
}
