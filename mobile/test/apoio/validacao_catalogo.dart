// Confere um ajuste (símbolo → valor) contra o catálogo, do jeito que
// `set_parameter` o aceitaria: o símbolo existe no bloco, o número cabe na
// faixa e o rótulo é uma das opções. É o que impede guia e receita de
// mandarem a IA mexer no que não existe.
import 'package:anagram_app/nucleo/catalogo/definicao_bloco.dart';

/// Nulo quando o ajuste vale; senão, a frase do problema.
String? problemaDoAjuste(DefinicaoBloco definicao, String simbolo, Object valor) {
  final parametro = definicao.parametro(simbolo);
  if (parametro == null) return '${definicao.uri}: no parameter "$simbolo"';
  if (valor is num) {
    if (valor < parametro.minimo || valor > parametro.maximo) {
      return '${definicao.uri}: $simbolo=$valor outside ${parametro.minimo}..${parametro.maximo}';
    }
    return null;
  }
  if (valor is bool) return parametro.alternavel ? null : '${definicao.uri}: $simbolo is not a toggle';
  if (valor is String) {
    final rotulo = valor.toLowerCase();
    if (parametro.opcoes.any((o) => o.toLowerCase() == rotulo)) return null;
    if (parametro.alternavel && const {'on', 'off', 'true', 'false'}.contains(rotulo)) return null;
    return '${definicao.uri}: "$valor" is not an option of $simbolo (${parametro.opcoes.join(', ')})';
  }
  return '${definicao.uri}: $simbolo has an unsupported value type';
}
