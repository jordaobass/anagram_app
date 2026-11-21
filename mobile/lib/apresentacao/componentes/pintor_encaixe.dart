// Encaixe vazio da cadeia: contorno tracejado, como o lugar de um pedal ainda
// não parafusado no board. Opaco, para a linha do sinal não atravessar o "+".
import 'package:flutter/rendering.dart';

import '../tema/tokens.dart';

class PintorEncaixe extends CustomPainter {
  const PintorEncaixe();

  @override
  void paint(Canvas canvas, Size size) {
    final caixa = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(Raios.controle));
    canvas.drawRRect(caixa, Paint()..color = Cores.fundoCase);
    final tinta = Paint()
      ..color = Cores.filete
      ..style = PaintingStyle.stroke
      ..strokeWidth = Medidas.contornoSelecao;
    for (final metrica in (Path()..addRRect(caixa.deflate(Medidas.contornoSelecao / 2))).computeMetrics()) {
      for (var d = 0.0; d < metrica.length; d += Medidas.tracoEncaixe * 2) {
        canvas.drawPath(metrica.extractPath(d, d + Medidas.tracoEncaixe), tinta);
      }
    }
  }

  @override
  bool shouldRepaint(PintorEncaixe antigo) => false;
}
