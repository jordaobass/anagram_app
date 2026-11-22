// As pílulas do modo acendem nas cores dos LEDs da Anagram (pedido do dono,
// DECISOES FM8): roxo no Stomp, branco no Preset, azul-claro no Scene. O texto
// sobre a pílula acesa precisa de contraste AA (4,5:1, WCAG 2.x), e a pílula
// acesa precisa se destacar do fundo do case.
import 'package:anagram_app/apresentacao/tema/tokens.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

double _contraste(Color a, Color b) {
  final (claro, escuro) = a.computeLuminance() > b.computeLuminance() ? (a, b) : (b, a);
  return (claro.computeLuminance() + 0.05) / (escuro.computeLuminance() + 0.05);
}

void main() {
  test('should_give_the_text_on_each_lit_mode_pill_at_least_aa_contrast', () {
    final acesas = {'stomp': Paleta.escura.modoStomp, 'preset': Paleta.escura.modoPreset, 'scene': Paleta.escura.modoScene};

    for (final e in acesas.entries) {
      expect(_contraste(e.value, Paleta.escura.sobreModo), greaterThanOrEqualTo(4.5), reason: '${e.key}: texto sobre a pílula');
      expect(_contraste(e.value, Paleta.escura.fundoCase), greaterThanOrEqualTo(3), reason: '${e.key}: pílula sobre o case');
    }
  });

  test('should_use_the_pedal_led_hues_purple_white_and_light_blue', () {
    final roxo = HSVColor.fromColor(Paleta.escura.modoStomp);
    final azul = HSVColor.fromColor(Paleta.escura.modoScene);

    expect(roxo.hue, inInclusiveRange(250, 290), reason: 'Stomp é roxo');
    expect(azul.hue, inInclusiveRange(190, 215), reason: 'Scene é azul-claro');
    expect(azul.value, greaterThan(0.85));
    expect(HSVColor.fromColor(Paleta.escura.modoPreset).saturation, lessThan(0.05), reason: 'Preset é branco');
  });
}
