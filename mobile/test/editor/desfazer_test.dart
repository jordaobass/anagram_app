// Segurar o knob volta ao padrão do bloco e oferece DESFAZER, que vale para o
// bloco que foi zerado, não para o que estiver selecionado depois.
import 'dart:async';

import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';

Future<ProviderContainer> zerarLimiarDoSujoDeEnsaio(WidgetTester tester) async {
  final c = await abrirDemonstracao(tester);
  unawaited(c.read(editorProvider.notifier).abrirSlot(SlotPreset.doRotulo('02A')));
  await tester.pumpAndSettle();
  c.read(editorProvider.notifier).alterarParametro('Threshold', -12, arrastando: false);
  await tester.pumpAndSettle();
  await tester.longPress(find.byKey(const ValueKey('param-Threshold')));
  await tester.pumpAndSettle();
  return c;
}

void main() {
  testWidgets('should_offer_undo_and_send_it_live_when_a_knob_is_reset', (tester) async {
    final c = await zerarLimiarDoSujoDeEnsaio(tester);

    await tester.tap(find.text('DESFAZER'));
    await tester.pumpAndSettle();

    final pedaleira = c.read(conexaoProvider.notifier).transporte! as TransporteDemonstracao;
    final tocando = pedaleira.presetTocando!['preset']['chains']['1']['blocks']['1']['parameters'] as Map;
    expect(c.read(editorProvider).blocoSelecionado!.valorBase('Threshold'), -12);
    expect(tocando.values.firstWhere((p) => p['symbol'] == 'Threshold')['value'], -12);
  });

  testWidgets('should_undo_the_block_that_was_reset_when_another_block_is_selected', (tester) async {
    final c = await abrirDemonstracao(tester);
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
