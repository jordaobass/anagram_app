// Montar a cadeia na pedaleira simulada: o efeito novo e o bloco movido têm de
// soar ao vivo, marcar o preset como não salvo e ficar selecionados.
import 'dart:convert';

import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:anagram_app/nucleo/protocolo/api_anagram.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/conexao_demo.dart';
import '../apoio/fixtures.dart';

void main() {
  final suppressor = lerCatalogo().definicao('urn:darkglass:Suppressor');

  test('should_sound_live_select_and_mark_unsaved_when_an_effect_is_added_to_an_empty_slot', () async {
    final (container, pedaleira) = await conectarDemonstracao();
    final editor = container.read(editorProvider.notifier);
    await editor.abrirSlot(SlotPreset(1));
    const vazia = PosicaoBloco(1, 4);

    await editor.adicionarBloco(vazia, suppressor);

    final estado = container.read(editorProvider);
    expect(estado.atual!.bloco(vazia)?.uri, 'urn:darkglass:Suppressor');
    expect(estado.selecionado, vazia);
    expect(estado.naoSalvo, isTrue);
    final aoVivo = pedaleira.comandosRecebidos.lastWhere((c) => c.acao == AcoesAnagram.tocarAoVivo);
    expect(jsonEncode(aoVivo.carga).split('urn:darkglass:Suppressor').length - 1, 2,
        reason: 'o Suppressor que já havia na casa 1 e o novo, na casa 4');
  });

  test('should_not_replace_a_block_when_adding_to_an_occupied_slot', () async {
    final (container, _) = await conectarDemonstracao();
    final editor = container.read(editorProvider.notifier);
    await editor.abrirSlot(SlotPreset(1));
    const ocupada = PosicaoBloco(1, 2);

    await editor.adicionarBloco(ocupada, suppressor);

    expect(container.read(editorProvider).atual!.bloco(ocupada)?.uri, 'urn:darkglass:wah');
  });

  test('should_move_the_block_select_it_at_the_destination_and_mark_unsaved_when_dragged', () async {
    final (container, _) = await conectarDemonstracao();
    final editor = container.read(editorProvider.notifier);
    await editor.abrirSlot(SlotPreset(1));

    await editor.moverBloco(const PosicaoBloco(1, 1), const PosicaoBloco(1, 4));

    final estado = container.read(editorProvider);
    expect(estado.atual!.bloco(const PosicaoBloco(1, 4))?.uri, 'urn:darkglass:Suppressor');
    expect(estado.atual!.bloco(const PosicaoBloco(1, 1)), isNull);
    expect(estado.selecionado, const PosicaoBloco(1, 4));
    expect(estado.naoSalvo, isTrue);
  });

  test('should_keep_the_chain_when_asked_to_move_split_or_merge', () async {
    final (container, _) = await conectarDemonstracao();
    final editor = container.read(editorProvider.notifier);
    await editor.abrirSlot(SlotPreset(1));
    final antes = container.read(editorProvider).atual!;
    final split = antes.blocosDaLinha(1).firstWhere((b) => b.uri.endsWith(':split')).posicao;

    await editor.moverBloco(split, const PosicaoBloco(1, 4));

    expect(container.read(editorProvider).atual!.assinaturaSemCena, antes.assinaturaSemCena);
  });
}
