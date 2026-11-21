// Posição 0–1 do controle ↔ valor real do parâmetro (linear ou log).
import 'dart:math';

import 'definicao_bloco.dart';

extension EscalaParametro on DefinicaoParametro {
  bool get _usaLog => logaritmico && minimo > 0 && maximo > minimo;

  double fracaoDe(num valor) {
    if (maximo == minimo) return 0;
    if (opcoes.length > 1) return indiceOpcao(valor) / (opcoes.length - 1);
    final limitado = valor.clamp(minimo, maximo).toDouble();
    if (_usaLog) return log(limitado / minimo) / log(maximo / minimo);
    return (limitado - minimo) / (maximo - minimo);
  }

  /// Onde o arco ou a faixa do controle nasce: no zero dos parâmetros que
  /// cortam e reforçam (-12…+12 dB), no início dos outros.
  double get fracaoDaOrigem => minimo < 0 && maximo > 0 && opcoes.isEmpty ? fracaoDe(0) : 0;

  num valorDe(double fracao) {
    final t = fracao.clamp(0.0, 1.0);
    if (opcoes.length > 1) return valorDaOpcao((t * (opcoes.length - 1)).round());
    final bruto = _usaLog ? minimo * pow(maximo / minimo, t) : minimo + (maximo - minimo) * t;
    return limitar(bruto);
  }
}
