// Parâmetros de EQ e amp conferidos contra o catálogo real da pedaleira:
// o número na tela tem de ter a resolução que o controle tem.
import 'package:anagram_app/nucleo/catalogo/formatador_valor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';

void main() {
  final catalogo = lerCatalogo();
  final parametrico = catalogo.definicao('urn:darkglass:fil4#mono');

  test('should_show_two_decimals_when_a_unitless_parameter_spans_less_than_two', () {
    // largura de banda 0–1: com uma casa, 0,33 e 0,30 seriam o mesmo "0,3"
    expect(FormatadorValor.formatar(parametrico.parametro('LSwidth')!, 0.33000001311302185), '0,33');
    expect(FormatadorValor.formatar(parametrico.parametro('HPQ')!, 0.7), '0,70');
    expect(FormatadorValor.formatar(catalogo.definicao('urn:darkglass:neural-plugins:swe').parametro('bass')!, 6.5),
        '6,5', reason: 'a escala 0–10 do amp continua com uma casa');
  });

  test('should_drop_trailing_zeros_when_showing_kilohertz', () {
    expect(FormatadorValor.formatar(parametrico.parametro('HSfreq')!, 8000), '8 kHz');
    expect(FormatadorValor.formatar(parametrico.parametro('freq4')!, 2500), '2,5 kHz');
    expect(FormatadorValor.formatar(parametrico.parametro('freq3')!, 1250), '1,25 kHz');
  });
}
