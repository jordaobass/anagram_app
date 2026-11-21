// Resposta do Global EQ para o desenho: soma, em dB, das 6 bandas (shelves e
// peaks de 2ª ordem, fórmulas de R. Bristow-Johnson). É ilustrativa: o
// filtro exato da pedaleira não é publicado, e a "width" da Anagram (0,33 a
// 4,0 já vistos) vira inclinação do shelf e largura em oitavas do peak por
// uma conversão linear escolhida pelo app (DECISOES PD8).
import 'dart:math' as math;

import 'mapa_ajustes.dart';

const _amostragem = 48000.0;

class BandaGlobalEq {
  const BandaGlobalEq(this.tipo, this.frequencia, this.ganho, [this.largura = 0.5]);
  final TipoBandaEq tipo;
  final double frequencia;
  final double ganho;

  /// A "width" da pedaleira: maior = mais larga (peak) ou mais íngreme (shelf).
  final double largura;
}

/// Inclinação S do shelf, de 0,1 a 1: a fórmula não tem solução real com
/// S > 1, então width de 1 a 4 desenha a mesma inclinação máxima.
double inclinacaoShelf(double largura) => (0.1 + 0.9 * largura).clamp(0.1, 1.0);

/// Largura do peak em oitavas: o dobro da width (0,5 = uma oitava), de 0,1 a 6.
double oitavasDoPeak(double largura) => (2 * largura).clamp(0.1, 6.0);

/// Ganho em dB de todas as [bandas] somadas na frequência [f].
double respostaEmDb(List<BandaGlobalEq> bandas, double f) =>
    bandas.fold(0, (soma, b) => soma + _resposta(b, f));

double _resposta(BandaGlobalEq banda, double f) {
  if (banda.ganho == 0) return 0;
  final (b, a) = banda.tipo == TipoBandaEq.peak ? _peak(banda) : _shelf(banda);
  final w = 2 * math.pi * f / _amostragem;
  return 20 * math.log(_modulo(b, w) / _modulo(a, w)) / math.ln10;
}

(List<double>, List<double>) _peak(BandaGlobalEq banda) {
  final a = math.pow(10, banda.ganho / 40).toDouble();
  final w0 = 2 * math.pi * banda.frequencia / _amostragem;
  final oitavas = oitavasDoPeak(banda.largura);
  final x = math.ln2 / 2 * oitavas * w0 / math.sin(w0);
  final alfa = math.sin(w0) * (math.exp(x) - math.exp(-x)) / 2;
  final c = math.cos(w0);
  return ([1 + alfa * a, -2 * c, 1 - alfa * a], [1 + alfa / a, -2 * c, 1 - alfa / a]);
}

(List<double>, List<double>) _shelf(BandaGlobalEq banda) {
  final a = math.pow(10, banda.ganho / 40).toDouble();
  final w0 = 2 * math.pi * banda.frequencia / _amostragem;
  final s = inclinacaoShelf(banda.largura);
  final alfa = math.sin(w0) / 2 * math.sqrt((a + 1 / a) * (1 / s - 1) + 2);
  final c = math.cos(w0);
  final r = 2 * math.sqrt(a) * alfa;
  final sinal = banda.tipo == TipoBandaEq.lowShelf ? -1.0 : 1.0;
  return (
    [
      a * ((a + 1) + sinal * (a - 1) * c + r),
      -2 * sinal * a * ((a - 1) + sinal * (a + 1) * c),
      a * ((a + 1) + sinal * (a - 1) * c - r),
    ],
    [
      (a + 1) - sinal * (a - 1) * c + r,
      2 * sinal * ((a - 1) - sinal * (a + 1) * c),
      (a + 1) - sinal * (a - 1) * c - r,
    ],
  );
}

/// |c0 + c1·e^-jw + c2·e^-2jw|
double _modulo(List<double> c, double w) {
  final real = c[0] + c[1] * math.cos(w) + c[2] * math.cos(2 * w);
  final imag = -c[1] * math.sin(w) - c[2] * math.sin(2 * w);
  return math.sqrt(real * real + imag * imag);
}
