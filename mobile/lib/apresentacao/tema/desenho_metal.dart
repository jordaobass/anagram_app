// O metal desenhado em código (nenhuma imagem): escovado, bisel, reflexo
// especular, ranhura usinada e parafusos. Tudo determinístico (seno no lugar
// de aleatório), para a captura não variar entre execuções.
import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// Ruído fixo de 0 a 1 a partir de um índice.
double _ruido(int i, double semente) => math.sin(i * 12.9898 + semente * 78.233) * 0.5 + 0.5;

/// Riscos horizontais finos e densos, de comprimento, altura e brilho que
/// variam: o escovado do alumínio. [passo] é a distância entre riscos.
void pintarEscovado(Canvas canvas, Rect area, {required Color claro, required Color escuro, double passo = 1.5, double semente = 0}) {
  canvas.save();
  canvas.clipRect(area);
  final risco = Paint()..strokeWidth = 0.7;
  final linhas = (area.height / passo).ceil();
  for (var i = 0; i < linhas; i++) {
    final y = area.top + i * passo + _ruido(i, semente) * passo * 0.6;
    final cor = _ruido(i * 7, semente) > 0.5 ? claro : escuro;
    risco.color = cor.withValues(alpha: cor.a * (0.35 + 0.65 * _ruido(i * 3, semente)));
    final inicio = area.left + _ruido(i * 5, semente) * area.width * 0.7 - area.width * 0.1;
    final comprimento = area.width * (0.25 + 0.75 * _ruido(i * 11, semente));
    canvas.drawLine(Offset(inicio, y), Offset(inicio + comprimento, y), risco);
  }
  canvas.restore();
}

/// O reflexo especular: uma faixa diagonal larga de luz que some nas bordas.
void pintarEspecular(Canvas canvas, Rect area, Color luz) {
  final faixa = Paint()
    ..shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [luz.withValues(alpha: 0), luz, luz.withValues(alpha: 0)],
      stops: const [0.25, 0.42, 0.6],
    ).createShader(area);
  canvas.drawRect(area, faixa);
}

/// Bisel: luz na borda de cima e da esquerda, sombra embaixo e à direita.
/// [afundado] inverte (baixo-relevo, a tela encaixada no chassi).
void pintarBisel(Canvas canvas, RRect borda, {required Color luz, required Color sombra, double largura = 2, bool afundado = false}) {
  final (cima, baixo) = afundado ? (sombra, luz) : (luz, sombra);
  final r = borda.outerRect;
  final traco = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = largura;
  canvas.save();
  canvas.clipRRect(borda);
  traco.color = cima;
  canvas.drawPath(Path()..moveTo(r.left, r.bottom)..lineTo(r.left, r.top)..lineTo(r.right, r.top), traco);
  traco.color = baixo;
  canvas.drawPath(Path()..moveTo(r.left, r.bottom)..lineTo(r.right, r.bottom)..lineTo(r.right, r.top), traco);
  canvas.restore();
}

/// Ranhura usinada: um sulco escuro com o lábio de luz logo abaixo.
void pintarRanhura(Canvas canvas, Offset de, Offset ate, {required Color luz, required Color sombra}) {
  canvas.drawLine(de, ate, Paint()
    ..color = sombra
    ..strokeWidth = 1.2);
  canvas.drawLine(de.translate(0, 1.2), ate.translate(0, 1.2), Paint()
    ..color = luz
    ..strokeWidth = 0.8);
}

enum CabecaParafuso { philips, sextavado }

/// Um parafuso visto de cima: cabeça com degradê radial, borda escura e a
/// fenda em cruz (Philips) ou o encaixe sextavado.
void pintarParafuso(Canvas canvas, Offset centro, double raio,
    {required Color corpo, required Color fenda, CabecaParafuso cabeca = CabecaParafuso.philips}) {
  final rect = Rect.fromCircle(center: centro, radius: raio);
  canvas.drawCircle(centro.translate(0.6, 0.8), raio, Paint()..color = fenda.withValues(alpha: 0.5));
  canvas.drawCircle(centro, raio, Paint()
    ..shader = RadialGradient(center: const Alignment(-0.4, -0.5), colors: [corpo, Color.lerp(corpo, fenda, 0.55)!])
        .createShader(rect));
  canvas.drawCircle(centro, raio, Paint()
    ..color = fenda
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.6);
  final traco = Paint()
    ..color = fenda
    ..strokeWidth = raio * 0.28
    ..strokeCap = StrokeCap.round;
  if (cabeca == CabecaParafuso.philips) {
    final d = raio * 0.55;
    canvas.drawLine(centro.translate(-d, -d), centro.translate(d, d), traco);
    canvas.drawLine(centro.translate(-d, d), centro.translate(d, -d), traco);
    return;
  }
  final hexagono = Path()..addPolygon([
    for (var i = 0; i < 6; i++) centro + Offset.fromDirection(math.pi / 6 + i * math.pi / 3, raio * 0.5),
  ], true);
  canvas.drawPath(hexagono, Paint()..color = fenda);
}

/// Um parafuso em cada canto de [area], a [recuo] da borda.
void pintarParafusosNosCantos(Canvas canvas, Rect area, double recuo, double raio,
    {required Color corpo, required Color fenda, CabecaParafuso cabeca = CabecaParafuso.philips}) {
  for (final canto in [
    area.topLeft.translate(recuo, recuo),
    area.topRight.translate(-recuo, recuo),
    area.bottomLeft.translate(recuo, -recuo),
    area.bottomRight.translate(-recuo, -recuo),
  ]) {
    pintarParafuso(canvas, canto, raio, corpo: corpo, fenda: fenda, cabeca: cabeca);
  }
}
