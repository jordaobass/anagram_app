// Knob de 270°: trilho de alumínio, arco na cor da família e ponteiro de
// fita gaffer.
import 'dart:math';

import 'package:flutter/rendering.dart';

import '../tema/tokens.dart';

class PintorKnob extends CustomPainter {
  const PintorKnob({required this.fracao, required this.cor, required this.focado});

  final double fracao;
  final Color cor;
  final bool focado;

  static const _inicio = 0.75 * pi;
  static const _varredura = 1.5 * pi;

  @override
  void paint(Canvas canvas, Size size) {
    final centro = size.center(Offset.zero);
    final raio = size.shortestSide / 2 - Medidas.espessuraArco;
    final arco = Rect.fromCircle(center: centro, radius: raio);
    canvas.drawArc(arco, _inicio, _varredura, false, _traco(Cores.filete));
    canvas.drawArc(arco, _inicio, _varredura * fracao, false, _traco(cor));
    final corpo = raio - Medidas.espessuraArco * Medidas.folgaCorpoKnob;
    canvas.drawCircle(centro, corpo, Paint()..color = Cores.painelElevado);
    canvas.drawCircle(
      centro,
      corpo,
      Paint()
        ..color = focado ? Cores.tally : Cores.aluminio
        ..style = PaintingStyle.stroke
        ..strokeWidth = focado ? Medidas.contornoSelecao : Medidas.filete,
    );
    final angulo = _inicio + _varredura * fracao;
    final ponta = centro + Offset(cos(angulo), sin(angulo)) * corpo * Medidas.pontaPonteiroKnob;
    final base = centro + Offset(cos(angulo), sin(angulo)) * corpo * Medidas.basePonteiroKnob;
    canvas.drawLine(base, ponta, _traco(Cores.fitaGaffer)..strokeWidth = Medidas.espessuraArco * Medidas.espessuraPonteiroKnob);
  }

  Paint _traco(Color cor) => Paint()
    ..color = cor
    ..style = PaintingStyle.stroke
    ..strokeWidth = Medidas.espessuraArco
    ..strokeCap = StrokeCap.round;

  @override
  bool shouldRepaint(PintorKnob antigo) => antigo.fracao != fracao || antigo.cor != cor || antigo.focado != focado;
}
