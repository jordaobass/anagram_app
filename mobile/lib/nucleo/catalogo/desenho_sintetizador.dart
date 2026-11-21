// Geometria dos desenhos do painel do synth, em coordenadas normalizadas
// (x de 0 a 1 da esquerda para a direita), sem Flutter: a tela só escala.
// O catálogo dá Cutoff, Resonance e o envelope em 0–10, sem Hz nem ms, então
// o filtro e o envelope são ILUSTRATIVOS — mostram a direção e a forma do
// que muda ao girar o knob, não a medida exata da pedaleira (DECISOES AX2).
import 'dart:math' as math;

/// As formas de onda que o desenho conhece.
enum FormaOnda { serra, quadrada, triangulo, senoide }

/// A forma pelo rótulo da opção do catálogo ("Saw", "Square", "Triangle");
/// rótulo desconhecido (firmware novo) não vira desenho chutado.
FormaOnda? formaDaOpcao(String rotulo) {
  final texto = rotulo.toLowerCase();
  if (texto.contains('saw')) return FormaOnda.serra;
  if (texto.contains('square') || texto.contains('pulse')) return FormaOnda.quadrada;
  if (texto.contains('tri')) return FormaOnda.triangulo;
  if (texto.contains('sin')) return FormaOnda.senoide;
  return null;
}

/// Vértices da onda: [ciclos] períodos, x de 0 a 1 e y de −1 a 1. Os cantos
/// são vértices exatos, para a quadrada e a serra terem paredes retas.
List<(double, double)> pontosDaOnda(FormaOnda forma, {int ciclos = 2}) {
  final pontos = <(double, double)>[];
  for (var c = 0; c < ciclos; c++) {
    for (final (x, y) in _umCiclo(forma)) {
      pontos.add(((c + x) / ciclos, y));
    }
  }
  return pontos;
}

List<(double, double)> _umCiclo(FormaOnda forma) => switch (forma) {
      FormaOnda.serra => const [(0, -1), (1, 1)],
      FormaOnda.quadrada => const [(0, 1), (0.5, 1), (0.5, -1), (1, -1)],
      FormaOnda.triangulo => const [(0, 0), (0.25, 1), (0.75, -1), (1, 0)],
      FormaOnda.senoide => [for (var i = 0; i <= 24; i++) (i / 24, math.sin(2 * math.pi * i / 24))],
    };

const _fMinima = 20.0;
const _fMaxima = 20000.0;

/// Cutoff 0–10 na escala log de 40 Hz a 18 kHz (ilustrativa).
double frequenciaDeCorte(num corte) => 40 * math.pow(18000 / 40, corte.clamp(0, 10) / 10).toDouble();

/// Resonance 0–10 como o Q do filtro, de 0,707 (sem pico) a 12 (pico agudo).
double qDaRessonancia(num ressonancia) => 0.707 * math.pow(12 / 0.707, ressonancia.clamp(0, 10) / 10).toDouble();

/// Ganho em dB de um passa-baixas de 2ª ordem na frequência [f].
double ganhoDoPassaBaixas(double f, double fc, double q) {
  final razao = f / fc;
  final real = 1 - razao * razao;
  final imaginaria = razao / q;
  return -10 * math.log(real * real + imaginaria * imaginaria) / math.ln10;
}

/// A curva do filtro: x é a posição log entre 20 Hz e 20 kHz, y o ganho em dB.
List<(double, double)> respostaDoFiltro({required num corte, required num ressonancia, int amostras = 96}) {
  final fc = frequenciaDeCorte(corte);
  final q = qDaRessonancia(ressonancia);
  return [
    for (var i = 0; i <= amostras; i++)
      (i / amostras, ganhoDoPassaBaixas(_frequenciaNaPosicao(i / amostras), fc, q)),
  ];
}

double _frequenciaNaPosicao(double x) => _fMinima * math.pow(_fMaxima / _fMinima, x).toDouble();

/// Posição log (0 a 1) de uma frequência no eixo do desenho.
double posicaoDaFrequencia(double f) => math.log(f / _fMinima) / math.log(_fMaxima / _fMinima);

/// Nível em que o desenho segura a nota entre o decay e o release: o catálogo
/// não tem sustain, então é só onde a curva descansa enquanto a nota soa.
const nivelSegurado = 0.35;
const _larguraSegurada = 0.16;

/// Envelope Attack → Decay → nota segurada → Release, cada trecho mais longo
/// quanto maior o knob (0–10). x vai de 0 a 1, y de 0 a 1.
List<(double, double)> curvaDoEnvelope({required num ataque, required num decaimento, required num liberacao}) {
  double trecho(num v) => 0.03 + v.clamp(0, 10) / 10 * 0.3;
  final larguras = [trecho(ataque), trecho(decaimento), _larguraSegurada, trecho(liberacao)];
  final total = larguras.reduce((a, b) => a + b);
  final niveis = [1.0, nivelSegurado, nivelSegurado, 0.0];
  final pontos = <(double, double)>[(0, 0)];
  var x = 0.0;
  for (var i = 0; i < larguras.length; i++) {
    x += larguras[i] / total;
    pontos.add((x, niveis[i]));
  }
  return pontos;
}
