import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';

Future<ProviderContainer> abrirSujoDeEnsaio(WidgetTester tester) async {
  final container = await abrirDemonstracao(tester);
  await tocarNoSlot(tester, '02A');
  return container;
}

num? limiar(ProviderContainer c) => c.read(editorProvider).blocoSelecionado!.valorBase('Threshold');

void main() {
  testWidgets('should_reset_the_knob_only_when_it_is_long_pressed_not_double_tapped', (tester) async {
    final container = await abrirSujoDeEnsaio(tester);
    final knob = find.byKey(const ValueKey('param-Threshold'));
    container.read(editorProvider.notifier).alterarParametro('Threshold', -12, arrastando: false);
    await tester.pumpAndSettle();

    await tester.tap(knob);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(knob);
    await tester.pumpAndSettle();
    expect(limiar(container), -12, reason: 'toque duplo é fácil de dar sem querer no palco');

    await tester.longPress(knob);
    await tester.pumpAndSettle();
    expect(limiar(container), -40, reason: 'segurar volta ao padrão do bloco');
  });
}
