import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/app_de_teste.dart';

Future<void> abrirNoCelular(WidgetTester tester, String rotulo) async {
  tester.view.physicalSize = const Size(780, 1688);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(appDeTeste());
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('botao-demonstracao')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('VER PRESETS'));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(ValueKey('slot-$rotulo')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('should_show_the_whole_chain_on_a_phone_without_side_scrolling', (tester) async {
    await abrirNoCelular(tester, '02A');
    for (final casa in [1, 2, 3, 5, 7]) {
      final retangulo = tester.getRect(find.byKey(ValueKey('casa-1-$casa')));
      expect(retangulo.right, lessThanOrEqualTo(390), reason: 'casa $casa precisa caber na largura');
    }
  });

  testWidgets('should_list_every_parameter_on_a_phone_without_pages', (tester) async {
    await abrirNoCelular(tester, '02C');
    await tester.tap(find.byKey(const ValueKey('casa-1-2')));
    await tester.pumpAndSettle();
    final rolagem = find.descendant(of: find.byKey(const ValueKey('rolagem-editor')), matching: find.byType(Scrollable));
    final ultimo = find.byKey(const ValueKey('param-arp_octaves'));
    await tester.scrollUntilVisible(ultimo, 300, scrollable: rolagem.first);
    expect(ultimo, findsOneWidget, reason: 'o 25º parâmetro sem trocar de página');
    expect(find.byTooltip('Próxima página'), findsNothing);
  });
}
