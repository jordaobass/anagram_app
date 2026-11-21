// Resposta do Global EQ para o desenho: soma, em dB, das bandas conhecidas
// (shelves de 2ª ordem, fórmulas de R. Bristow-Johnson, inclinação S = 1).
// É ilustrativa: o filtro exato da pedaleira não é publicado (DECISOES PD4).
import 'dart:math' as math;

import 'mapa_ajustes.dart';

const _amostragem = 48000.0;

class BandaGlobalEq {
  const BandaGlobalEq(this.tipo, this.frequencia, this.ganho);
  final TipoBandaEq tipo;
  final double frequencia;
  final double ganho;
}

/// Ganho em dB de todas as [bandas] somadas na frequência [f].
double respostaEmDb(List<BandaGlobalEq> bandas, double f) =>
    bandas.fold(0, (soma, b) => soma + _shelf(b, f));

double _shelf(BandaGlobalEq banda, double f) {
  if (banda.ganho == 0) return 0;
  final a = math.pow(10, banda.ganho / 40).toDouble();
  final w0 = 2 * math.pi * banda.frequencia / _amostragem;
  final alfa = math.sin(w0) / 2 * math.sqrt2;
  final c = math.cos(w0);
  final r = 2 * math.sqrt(a) * alfa;
  final grave = banda.tipo == TipoBandaEq.lowShelf;
  final s = grave ? -1.0 : 1.0;
  final b = [
    a * ((a + 1) + s * (a - 1) * c + r),
    -2 * s * a * ((a - 1) + s * (a + 1) * c),
    a * ((a + 1) + s * (a - 1) * c - r),
  ];
  final d = [
    (a + 1) - s * (a - 1) * c + r,
    2 * s * ((a - 1) - s * (a + 1) * c),
    (a + 1) - s * (a - 1) * c - r,
  ];
  final w = 2 * math.pi * f / _amostragem;
  return 20 * math.log(_modulo(b, w) / _modulo(d, w)) / math.ln10;
}

/// |c0 + c1·e^-jw + c2·e^-2jw|
double _modulo(List<double> c, double w) {
  final real = c[0] + c[1] * math.cos(w) + c[2] * math.cos(2 * w);
  final imag = -c[1] * math.sin(w) - c[2] * math.sin(2 * w);
  return math.sqrt(real * real + imag * imag);
}
