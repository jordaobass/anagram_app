// Achados da revisão da rodada 3 (as expectativas descrevem o comportamento
// desejado; vistos vermelhos antes das correções).
import 'dart:async';

import 'package:anagram_app/aplicacao/casos_de_uso/salvar_no_slot.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/app_de_teste.dart';
import '../apoio/conexao_demo.dart';

void main() {
  test('A_read_failure_must_not_leave_previous_preset_under_new_slot_and_save_it_there', () async {
    final (container, pedaleira) = await conectarDemonstracao();
    final editor = container.read(editorProvider.notifier);
    await editor.abrirSlot(SlotPreset(3));
    final nomeDo3 = container.read(editorProvider).atual!.nome;
    final slot4Antes = (pedaleira.conteudoDoSlot(4)!['preset'] as Map)['name'];
    pedaleira.falharEnvio = true;
    await editor.abrirSlot(SlotPreset(4));
    pedaleira.falharEnvio = false;
    final estado = container.read(editorProvider);
    expect(estado.atual?.nome, isNot(nomeDo3), reason: 'o preset do 3 não pode ficar sob o slot 4');

    final resultado = await editor.salvar();
    final slot4Depois = (pedaleira.conteudoDoSlot(4)!['preset'] as Map)['name'];
    expect(resultado, isNot(isA<PresetSalvo>()), reason: 'não há o que salvar em 04 sem ter lido 04');
    expect(slot4Depois, slot4Antes, reason: 'slot 4 não pode receber o preset do slot 3 sem perguntar');
  });

  test('B_save_while_loading_must_not_write_previous_preset_into_new_slot', () async {
    final (container, pedaleira) = await conectarDemonstracao();
    final editor = container.read(editorProvider.notifier);
    await editor.abrirSlot(SlotPreset(3));
    final uuidDo3 = container.read(editorProvider).atual!.uuid;
    final slot4Antes = (pedaleira.conteudoDoSlot(4)!['preset'] as Map)['name'];

    final abrindo = editor.abrirSlot(SlotPreset(4)); // não aguardado: carregando
    final resultado = await editor.salvar(); // Cmd+S chama isto direto (atalhos_editor.dart:26)
    await abrindo;

    final gravado = pedaleira.conteudoDoSlot(4)!['preset'] as Map;
    expect(resultado, isNot(isA<PresetSalvo>()), reason: 'salvar enquanto carrega grava o preset anterior no slot novo');
    expect(gravado['name'], slot4Antes);
    expect(gravado['uuid'], isNot(uuidDo3));
  });

  testWidgets('C_undo_must_apply_to_the_block_that_was_reset_not_the_selected_one', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(appDeTeste());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('botao-demonstracao')));
    await tester.pumpAndSettle();
    final c = ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));
    unawaited(c.read(editorProvider.notifier).abrirSlot(SlotPreset.doRotulo('02A')));
    await tester.pumpAndSettle();
    final sup = c.read(editorProvider).selecionado!;
    const cmp = PosicaoBloco(1, 2);
    final thresholdCmpAntes = c.read(editorProvider).atual!.bloco(cmp)!.valorBase('Threshold');
    c.read(editorProvider.notifier).alterarParametro('Threshold', -12, arrastando: false);
    await tester.pumpAndSettle();

    await tester.longPress(find.byKey(const ValueKey('param-Threshold')));
    await tester.pumpAndSettle();
    c.read(editorProvider.notifier).selecionarBloco(cmp); // usuário clica noutro bloco com o snackbar aberto
    await tester.pumpAndSettle();
    await tester.tap(find.text('DESFAZER'));
    await tester.pumpAndSettle();

    final doc = c.read(editorProvider).atual!;
    expect(doc.bloco(cmp)!.valorBase('Threshold'), thresholdCmpAntes, reason: 'DESFAZER mexeu no bloco errado');
    expect(doc.bloco(sup)!.valorBase('Threshold'), -12, reason: 'DESFAZER devia restaurar o SUP');
  });
}
