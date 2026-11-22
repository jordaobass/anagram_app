// Âmbar só para seleção e ação principal: o LIGADO do bloco é estado, não
// ação — vira contorno com o LED verde aceso (cinza quando desligado); o
// DISPARAR da bateria é um toque ao vivo, não a ação principal da tela, e
// também vira contorno. Nenhum dos dois pinta o fundo de âmbar.
import 'package:anagram_app/apresentacao/tema/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../apoio/contraste.dart';
import '../../apoio/demonstracao_na_tela.dart';

const _bateria = 'https://falktx.com/plugins/auto-drummer';
final _bypass = find.byKey(const ValueKey('bypass'));

Color? _led(WidgetTester tester) {
  final led = find.descendant(of: _bypass, matching: find.byKey(const ValueKey('led-bypass')));
  return (tester.widget<Container>(led).decoration! as BoxDecoration).color;
}

void main() {
  testWidgets('should_show_the_block_power_as_an_outline_with_a_green_led_that_goes_grey_when_off', (tester) async {
    await abrirComBloco(tester, 'urn:darkglass:ignissor');

    expect(materialDoBotao(tester, _bypass).color, isNot(Cores.tally));
    expect(_led(tester), Cores.ledLigado);

    await tester.tap(_bypass);
    await tester.pumpAndSettle();
    expect(_led(tester), Cores.ledDesligado);
  });

  testWidgets('should_draw_the_drum_trigger_as_an_outline_not_an_amber_fill', (tester) async {
    await abrirComBloco(tester, _bateria);
    final disparar = find.byWidgetPredicate((w) => w.key is ValueKey<String> && (w.key! as ValueKey<String>).value.startsWith('pulso-'));
    await tester.ensureVisible(disparar);
    await tester.pumpAndSettle();

    expect(materialDoBotao(tester, disparar).color, isNot(Cores.tally));
  });
}
