// A linha do sinal atrás dos blocos: pista 1 de ponta a ponta; a pista 2
// (paralela) desce em 45° no split e sobe no merge, como linha de metrô.
import 'package:flutter/rendering.dart';

import '../tema/tokens.dart';

class GeometriaGrade {
  const GeometriaGrade({required this.larguraCasa, required this.vao, required this.alturaLinha, required this.centroArte});

  final double larguraCasa;
  final double vao;
  final double alturaLinha;

  /// Distância do topo da linha até o centro da arte.
  final double centroArte;

  double xDaCasa(int casa) => (casa - 1) * (larguraCasa + vao) + larguraCasa / 2;
  double yDaLinha(int linha) => (linha - 1) * (alturaLinha + vao) + centroArte;
  double get larguraTotal => 12 * larguraCasa + 11 * vao;
}

class PintorLinhaSinal extends CustomPainter {
  const PintorLinhaSinal({required this.geometria, required this.temLinha2, this.casaSplit, this.casaMerge});

  final GeometriaGrade geometria;
  final bool temLinha2;
  final int? casaSplit;
  final int? casaMerge;

  @override
  void paint(Canvas canvas, Size size) {
    final tinta = Paint()
      ..color = Cores.aluminio
      ..style = PaintingStyle.stroke
      ..strokeWidth = Medidas.linhaSinal
      ..strokeJoin = StrokeJoin.round;
    final y1 = geometria.yDaLinha(1);
    canvas.drawLine(Offset(0, y1), Offset(size.width, y1), tinta);
    if (temLinha2) canvas.drawPath(_pista2(size), tinta);
  }

  Path _pista2(Size size) {
    final y1 = geometria.yDaLinha(1);
    final y2 = geometria.yDaLinha(2);
    final queda = y2 - y1;
    final inicio = casaSplit == null ? 0.0 : geometria.xDaCasa(casaSplit!);
    final fim = casaMerge == null ? size.width : geometria.xDaCasa(casaMerge!);
    return Path()
      ..moveTo(inicio, y1)
      ..lineTo(inicio + queda, y2)
      ..lineTo(fim - queda, y2)
      ..lineTo(fim, y1);
  }

  @override
  bool shouldRepaint(PintorLinhaSinal antigo) =>
      antigo.temLinha2 != temLinha2 || antigo.casaSplit != casaSplit || antigo.casaMerge != casaMerge ||
      antigo.geometria.larguraCasa != geometria.larguraCasa;
}
