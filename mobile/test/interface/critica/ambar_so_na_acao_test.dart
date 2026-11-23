// Âmbar só para seleção e ação principal: o LIGADO do bloco é estado, não
// ação — vira contorno com o LED verde aceso (cinza quando desligado), sem
// pintar o fundo de âmbar.
import 'package:anagram_app/apresentacao/tema/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../apoio/contraste.dart';
import '../../apoio/demonstracao_na_tela.dart';

final _bypass = find.byKey(const ValueKey('bypass'));

Color? _led(WidgetTester tester) {
  final led = find.descendant(of: _bypass, matching: find.byKey(const ValueKey('led-bypass')));
  return (tester.widget<Container>(led).decoration! as BoxDecoration).color;
}

void main() {
  testWidgets('should_show_the_block_power_as_an_outline_with_a_green_led_that_goes_grey_when_off', (tester) async {
    await abrirComBloco(tester, 'urn:darkglass:ignissor');

    expect(materialDoBotao(tester, _bypass).color, isNot(Paleta.escura.tally));
    expect(_led(tester), Paleta.escura.ledLigado);

    await tester.tap(_bypass);
    await tester.pumpAndSettle();
    expect(_led(tester), Paleta.escura.ledDesligado);
  });

}
