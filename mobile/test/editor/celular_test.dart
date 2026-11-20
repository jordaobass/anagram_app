import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';

Future<void> abrirNoCelular(WidgetTester tester, String rotulo) async {
  await abrirDemonstracao(tester, tamanho: telaCelular, densidade: 2);
  await tester.tap(find.text('VER PRESETS'));
  await tester.pumpAndSettle();
  await tocarNoSlot(tester, rotulo);
}

void main() {
  testWidgets('should_show_the_whole_chain_without_side_scrolling_when_on_a_phone', (tester) async {
    await abrirNoCelular(tester, '02A');
    for (final casa in [1, 2, 3, 5, 7]) {
      final retangulo = tester.getRect(find.byKey(ValueKey('casa-1-$casa')));
      expect(retangulo.right, lessThanOrEqualTo(390), reason: 'casa $casa precisa caber na largura');
    }
  });

  testWidgets('should_list_every_parameter_without_pages_when_on_a_phone', (tester) async {
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
