import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';

const ipadMiniPaisagem = Size(1133, 744);
const ipadMiniRetrato = Size(744, 1133);

Future<void> abrirNoTablet(WidgetTester tester, Size tela, String rotulo) async {
  await abrirDemonstracao(tester, tamanho: tela);
  if (find.byKey(ValueKey('slot-$rotulo')).evaluate().isEmpty) {
    await tester.tap(find.text('VER PRESETS'));
    await tester.pumpAndSettle();
  }
  await tocarNoSlot(tester, rotulo);
}

void main() {
  testWidgets('should_show_all_twelve_chain_slots_when_on_the_smallest_ipad_in_landscape', (tester) async {
    // 03A tem linha paralela: as duas linhas mostram as 12 casas (sem ela, a
    // linha 2 é a faixa de criar a linha paralela)
    await abrirNoTablet(tester, ipadMiniPaisagem, '03A');
    for (final linha in [1, 2]) {
      final retangulo = tester.getRect(find.byKey(ValueKey('casa-$linha-12')));
      expect(retangulo.right, lessThanOrEqualTo(ipadMiniPaisagem.width), reason: 'casa 12 da linha $linha à vista');
    }
  });

  testWidgets('should_list_every_parameter_without_pages_when_on_an_ipad_in_landscape', (tester) async {
    await abrirNoTablet(tester, ipadMiniPaisagem, '02C');
    await tester.tap(find.byKey(const ValueKey('casa-1-2')));
    await tester.pumpAndSettle();
    final rolagem = find.descendant(of: find.byKey(const ValueKey('rolagem-editor')), matching: find.byType(Scrollable));
    final ultimo = find.byKey(const ValueKey('param-arp_octaves'));
    await tester.scrollUntilVisible(ultimo, 300, scrollable: rolagem.first);
    expect(ultimo, findsOneWidget, reason: 'o 25º parâmetro sem trocar de página');
    expect(find.byTooltip('Próxima página'), findsNothing);
  });

  testWidgets('should_fit_more_blocks_per_row_than_a_phone_when_on_an_ipad_in_portrait', (tester) async {
    await abrirNoTablet(tester, ipadMiniRetrato, '02A');
    final primeira = tester.getRect(find.byKey(const ValueKey('casa-1-1')));
    // a grade compacta mostra as casas na posição real (os buracos com "+"):
    // no celular cabem 4 por fileira; no iPad, a 5ª ainda está na primeira
    final quinta = tester.getRect(find.byKey(const ValueKey('casa-1-5')));
    expect(quinta.top, primeira.top, reason: 'cinco casas na mesma fileira');
  });

  testWidgets('should_show_list_and_editor_when_on_an_ipad_in_portrait', (tester) async {
    await abrirDemonstracao(tester, tamanho: const Size(820, 1180));
    expect(find.byKey(const ValueKey('slot-01A')), findsOneWidget);
  });
}
