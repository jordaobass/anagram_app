// Um passo de seta, rodinha ou leitor de tela num controle (knob ou fader).
// Contínuo: uma fração do curso. Discreto (inteiro, liga/desliga, opções):
// posições inteiras e nunca menos de uma — 1% de 24 semitons arredondava para
// o mesmo valor e a seta não fazia nada (DECISOES K1).
import 'dart:math';

import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/catalogo/escala_parametro.dart';

/// Um passo fino é 1% do curso; o grosso (Shift), 10%.
const fracaoPassoFino = 0.01;
const fracaoPassoGrosso = 0.1;

extension PassoControle on DefinicaoParametro {
  /// Quantas posições o controle tem, ou null se é contínuo.
  int? get _posicoes {
    if (opcoes.length > 1) return opcoes.length;
    if (alternavel || inteiro) return (maximo - minimo).round() + 1;
    return null;
  }

  /// O valor depois de [quanto] do curso (negativo desce) a partir de [valor].
  num valorDepoisDoPasso(num valor, double quanto) {
    final posicoes = _posicoes;
    if (posicoes == null || posicoes < 2) return valorDe((fracaoDe(valor) + quanto).clamp(0.0, 1.0));
    final saltos = max(1, (quanto.abs() * (posicoes - 1)).round()) * quanto.sign.toInt();
    if (opcoes.length > 1) return valorDaOpcao(indiceOpcao(valor) + saltos);
    return limitar(limitar(valor) + saltos);
  }
}
