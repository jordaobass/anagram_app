// A release publicada só vira aviso quando é estável e maior que a do app,
// comparando número a número (0.1.9 < 0.1.10), nunca como texto.
import 'package:anagram_app/nucleo/versao/versao_semantica.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('should_compare_each_number_instead_of_the_text', () {
    expect(ehMaisNova('0.1.10', '0.1.9'), isTrue);
    expect(ehMaisNova('0.1.17', '0.1.10'), isTrue);
    expect(ehMaisNova('0.2.0', '0.1.17'), isTrue);
    expect(ehMaisNova('1.0.0', '0.99.99'), isTrue);
    expect(ehMaisNova('0.1.9', '0.1.10'), isFalse);
  });

  test('should_not_warn_when_the_published_version_is_the_same_or_older', () {
    expect(ehMaisNova('0.1.17', '0.1.17'), isFalse);
    expect(ehMaisNova('0.1.16', '0.1.17'), isFalse);
  });

  test('should_ignore_the_v_prefix_and_the_build_number', () {
    expect(ehMaisNova('v0.1.18', '0.1.17'), isTrue);
    expect(ehMaisNova('V0.1.18', 'v0.1.17'), isTrue);
    expect(ehMaisNova('v0.1.17', '0.1.17+18'), isFalse);
  });

  test('should_not_warn_when_the_tag_is_invalid_or_a_prerelease', () {
    for (final tag in ['', 'latest', 'v1.2', '1.2.3.4', 'v0.2.0-beta.1', '0.2.0-rc1', '0.x.1', ' 0.2.0', '-1.0.0']) {
      expect(ehMaisNova(tag, '0.1.17'), isFalse, reason: tag);
    }
    expect(ehMaisNova('0.2.0', ''), isFalse, reason: 'sem a versão do app não há com o que comparar');
  });

  test('should_read_the_numbers_of_a_valid_tag', () {
    expect(VersaoSemantica.ler('v12.0.345').toString(), '12.0.345');
  });
}
