import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/app_de_teste.dart';

Future<ProviderContainer> abrirSujoDeEnsaio(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1440, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(appDeTeste());
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('botao-demonstracao')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('slot-02A')));
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));
}

num? limiar(ProviderContainer c) => c.read(editorProvider).blocoSelecionado!.valorBase('Threshold');

void main() {
  testWidgets('should_not_reset_knob_on_double_tap_but_reset_on_long_press', (tester) async {
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
