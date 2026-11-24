// Escalas comuns aos gráficos de frequência (a faixa do multibanda e a
// curva do EQ): o eixo log de 20 Hz a 20 kHz é o do núcleo
// (`fracaoDaFrequencia`), as marcas da régua, a escala de dB e o texto dos
// eixos, para os dois desenhos falarem a mesma língua.
import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../../nucleo/catalogo/definicao_bloco.dart';
import '../tema/tokens.dart';

/// As décadas e o meio de cada uma, como as réguas de analisador.
const marcasDeFrequencia = [50, 100, 200, 500, 1000, 2000, 5000, 10000];

/// "100", "1k", "10k".
String rotuloDaFrequencia(int hz) => hz >= 1000 ? '${hz ~/ 1000}k' : '$hz';

/// "+12", "0", "-36": o sinal de mais deixa claro que é reforço.
String rotuloDoDb(double db) => db > 0 ? '+${db.round()}' : '${db.round()}';

/// Escreve [texto] no eixo, em [tamanho] da fonte de rótulo; [onde] recebe
/// o tamanho do texto e devolve o canto de cima à esquerda.
void pintarRotuloDoEixo(Canvas canvas, Paleta cores, String texto, double tamanho, Offset Function(Size) onde) {
  final pintor = TextPainter(
    text: TextSpan(text: texto, style: TextStyle(fontFamily: Fontes.rotulo, color: cores.textoSecundario, fontSize: tamanho)),
    textDirection: TextDirection.ltr,
  )..layout();
  pintor.paint(canvas, onde(pintor.size));
  pintor.dispose();
}

/// Escala vertical da faixa, em dB: por padrão a da tela da pedaleira
/// (+12 no topo, o maior Level; −36 embaixo). Ela se abre em degraus de 12 dB
/// para caber a faixa dos traços — o Threshold do Ignissor vai a −60, e com a
/// escala fixa o traço ficava preso na borda, longe do ponteiro (DECISOES K3).
class EscalaGanho {
  const EscalaGanho({this.topo = _topoPadrao, this.base = _basePadrao, this.passo = passoPadrao});

  /// A menor escala da pedaleira que cobre todos os [parametros].
  factory EscalaGanho.paraCobrir(Iterable<DefinicaoParametro> parametros) {
    var (topo, base) = (_topoPadrao, _basePadrao);
    for (final p in parametros) {
      topo = math.max(topo, (p.maximo / passoPadrao).ceil() * passoPadrao);
      base = math.min(base, (p.minimo / passoPadrao).floor() * passoPadrao);
    }
    return EscalaGanho(topo: topo, base: base);
  }

  static const _topoPadrao = 12.0;
  static const _basePadrao = -36.0;

  /// Distância entre as linhas da escala da pedaleira (+12, 0, −12, …).
  static const passoPadrao = 12.0;

  final double topo;
  final double base;
  final double passo;

  double get faixaDb => topo - base;

  /// Altura (0 em cima, 1 embaixo) de um ganho em dB; o que passa da base some na borda.
  double altura(double db) => ((topo - db) / faixaDb).clamp(0.0, 1.0);

  /// As linhas da escala, do topo à base.
  Iterable<double> get marcas sync* {
    for (var db = topo; db >= base; db -= passo) {
      yield db;
    }
  }

  @override
  bool operator ==(Object other) =>
      other is EscalaGanho && other.topo == topo && other.base == base && other.passo == passo;

  @override
  int get hashCode => Object.hash(topo, base, passo);
}
