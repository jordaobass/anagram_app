// Foco do teclado visível: o realce âmbar a 24% sobre o case dava 1,69:1.
// Botão focado ganha contorno sólido de 2px com pelo menos 3:1 (WCAG 2.4.11)
// contra o que está em volta dele.
import 'package:anagram_app/apresentacao/tema/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../apoio/contraste.dart';
import '../../apoio/demonstracao_na_tela.dart';

/// Anda com Tab até o foco cair dentro de [alvo].
Future<void> _focarComTab(WidgetTester tester, Finder alvo) async {
  for (var i = 0; i < 30; i++) {
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    final focado = FocusManager.instance.primaryFocus?.context;
    if (focado != null && find.descendant(of: alvo, matching: find.byElementPredicate((e) => e == focado)).evaluate().isNotEmpty) {
      return;
    }
  }
  fail('o Tab não chegou em $alvo');
}

void main() {
  testWidgets('should_draw_a_solid_two_pixel_ring_with_three_to_one_contrast_on_a_focused_outlined_button',
      (tester) async {
    await montarApp(tester);
    final demonstracao = find.byKey(const ValueKey('botao-demonstracao'));
    expect(contornoDoBotao(tester, demonstracao).width, Medidas.filete, reason: 'sem foco, o filete de sempre');

    await _focarComTab(tester, demonstracao);

    final anel = contornoDoBotao(tester, demonstracao);
    expect(anel.width, Medidas.contornoSelecao);
    expect(contraste(anel.color, Paleta.escura.fundoCase), greaterThanOrEqualTo(3));
  });

  testWidgets('should_draw_a_ring_that_stands_out_from_the_fill_on_a_focused_filled_button', (tester) async {
    await montarApp(tester);
    final conectar = find.byKey(const ValueKey('botao-conectar'));

    await _focarComTab(tester, conectar);

    final anel = contornoDoBotao(tester, conectar);
    expect(anel.width, Medidas.contornoSelecao);
    expect(contraste(anel.color, materialDoBotao(tester, conectar).color!), greaterThanOrEqualTo(3));
  });
}
