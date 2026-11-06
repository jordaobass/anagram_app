import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/app_de_teste.dart';

const ipadMiniPaisagem = Size(1133, 744);
const ipadMiniRetrato = Size(744, 1133);

Future<void> abrirNoTablet(WidgetTester tester, Size tela, String rotulo) async {
  tester.view.physicalSize = tela;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(appDeTeste());
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('botao-demonstracao')));
  await tester.pumpAndSettle();
  if (find.byKey(ValueKey('slot-$rotulo')).evaluate().isEmpty) {
    await tester.tap(find.text('VER PRESETS'));
    await tester.pumpAndSettle();
  }
  await tester.tap(find.byKey(ValueKey('slot-$rotulo')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('should_show_all_twelve_slots_of_the_chain_on_the_smallest_ipad_in_landscape', (tester) async {
    await abrirNoTablet(tester, ipadMiniPaisagem, '02A');
    for (final linha in [1, 2]) {
      final retangulo = tester.getRect(find.byKey(ValueKey('casa-$linha-12')));
      expect(retangulo.right, lessThanOrEqualTo(ipadMiniPaisagem.width), reason: 'casa 12 da linha $linha à vista');
    }
  });

  testWidgets('should_list_every_parameter_on_an_ipad_in_landscape_without_pages', (tester) async {
    await abrirNoTablet(tester, ipadMiniPaisagem, '02C');
    await tester.tap(find.byKey(const ValueKey('casa-1-2')));
    await tester.pumpAndSettle();
    final rolagem = find.descendant(of: find.byKey(const ValueKey('rolagem-editor')), matching: find.byType(Scrollable));
    final ultimo = find.byKey(const ValueKey('param-arp_octaves'));
    await tester.scrollUntilVisible(ultimo, 300, scrollable: rolagem.first);
    expect(ultimo, findsOneWidget, reason: 'o 25º parâmetro sem trocar de página');
    expect(find.byTooltip('Próxima página'), findsNothing);
  });

  testWidgets('should_fit_more_blocks_per_row_on_an_ipad_in_portrait_than_on_a_phone', (tester) async {
    await abrirNoTablet(tester, ipadMiniRetrato, '02A');
    final primeira = tester.getRect(find.byKey(const ValueKey('casa-1-1')));
    final quinta = tester.getRect(find.byKey(const ValueKey('casa-1-7'))); // 5º bloco: as casas ocupadas são 1, 2, 3, 5 e 7
    expect(quinta.top, primeira.top, reason: 'cinco blocos na mesma fileira');
  });
}
