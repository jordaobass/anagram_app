// Digitar o valor de um knob: a pessoa escreve o número que vê embaixo dele,
// na unidade do bloco, com vírgula ou ponto, com ou sem a unidade.
import 'package:anagram_app/nucleo/catalogo/definicao_bloco.dart';
import 'package:anagram_app/nucleo/catalogo/formatador_valor.dart';
import 'package:flutter_test/flutter_test.dart';

const _limiar = DefinicaoParametro(simbolo: 'th', nome: 'Threshold', minimo: -80, maximo: 0, padrao: -40, unidade: 'dB');
const _frequencia = DefinicaoParametro(simbolo: 'f', nome: 'Freq', minimo: 20, maximo: 20000, padrao: 750, unidade: 'Hz');
const _passos = DefinicaoParametro(simbolo: 'v', nome: 'Voices', minimo: 1, maximo: 8, padrao: 2, inteiro: true);

num? _ler(DefinicaoParametro p, String texto) => FormatadorValor.lerDigitado(p, texto);

void main() {
  test('should_read_the_number_with_comma_or_dot_and_with_or_without_the_unit_when_typed', () {
    expect(_ler(_limiar, '-12,5'), -12.5);
    expect(_ler(_limiar, '-12.5'), -12.5);
    expect(_ler(_limiar, '-12,5 dB'), -12.5);
    expect(_ler(_limiar, '  -3  '), -3);
  });

  test('should_read_kilohertz_when_the_frequency_is_typed_as_shown_on_screen', () {
    expect(_ler(_frequencia, '1,5k'), 1500);
    expect(_ler(_frequencia, '1.5 kHz'), 1500);
    expect(_ler(_frequencia, '750 Hz'), 750);
  });

  test('should_keep_the_value_inside_the_parameter_range_when_the_number_is_out_of_it', () {
    expect(_ler(_limiar, '12'), 0);
    expect(_ler(_limiar, '-200'), -80);
  });

  test('should_round_when_the_parameter_only_takes_whole_numbers', () {
    expect(_ler(_passos, '3,6'), 4);
  });

  test('should_refuse_text_that_is_not_a_number', () {
    expect(_ler(_limiar, ''), isNull);
    expect(_ler(_limiar, 'abc'), isNull);
    expect(_ler(_limiar, '1,2,3'), isNull);
  });
}
