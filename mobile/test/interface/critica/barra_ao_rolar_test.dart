// A barra de título das telas (Configurações, Sobre) ficava âmbar ao rolar:
// o Material 3 tinge a barra rolada com a cor primária. Rolada ou não, ela
// fica no painel, sem tinta, com o filete embaixo.
import 'package:anagram_app/apresentacao/tema/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../apoio/demonstracao_na_tela.dart';

Material _materialDaBarra(WidgetTester tester) =>
    tester.widget<Material>(find.descendant(of: find.byType(AppBar), matching: find.byType(Material)).first);

void main() {
  testWidgets('should_keep_the_title_bar_on_the_panel_color_without_amber_tint_after_scrolling', (tester) async {
    await montarApp(tester);
    await tester.tap(find.byKey(const ValueKey('botao-configuracoes')));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
    await tester.pumpAndSettle();

    final barra = _materialDaBarra(tester);
    expect(barra.color, Cores.painel);
    expect(barra.elevation == 0 || barra.surfaceTintColor == Colors.transparent, isTrue, reason: 'sem tinta âmbar');
    expect((barra.shape! as Border).bottom.color, Cores.filete);
  });
}
