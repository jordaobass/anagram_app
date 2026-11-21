// O passa-baixas no máximo (20 kHz) não corta nada: a pedaleira escreve OFF.
// Ele se reconhece pelo símbolo, não pelo nome que o catálogo dá.
import 'package:anagram_app/apresentacao/componentes/faixa_frequencias.dart';
import 'package:anagram_app/nucleo/catalogo/definicao_bloco.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/textos_pt.dart';

DefinicaoParametro _corte(String simbolo, String nome) =>
    DefinicaoParametro(simbolo: simbolo, nome: nome, minimo: 40, maximo: 20000, padrao: 250, unidade: 'Hz');

void main() {
  test('should_write_off_when_the_low_pass_is_at_its_maximum_whatever_its_display_name', () {
    expect(textoDoCorte(textosPt, _corte('hi_lp_freq', 'Low Pass'), 20000), 'OFF');
    expect(textoDoCorte(textosPt, _corte('hi_lp_freq', 'Lo-Pass Freq'), 20000), 'OFF');
  });

  test('should_write_the_frequency_when_the_cut_is_not_a_low_pass_at_its_maximum', () {
    expect(textoDoCorte(textosPt, _corte('hi_lp_freq', 'Lo-Pass Freq'), 800), isNot('OFF'));
    expect(textoDoCorte(textosPt, _corte('lomid_xo_freq', 'Lo-Pass Crossover'), 20000), isNot('OFF'));
  });
}
