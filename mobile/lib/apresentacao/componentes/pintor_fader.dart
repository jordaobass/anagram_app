// Fader vertical das bandas do GEQ: trilho de alumínio, marca do zero, a
// faixa na cor da família indo do zero até o cursor, e o cursor de fita
// gaffer. Lado a lado, os faders desenham a curva, como no pedal.
import 'package:flutter/rendering.dart';

import '../tema/tokens.dart';

class PintorFader extends CustomPainter {
  const PintorFader({required this.fracao, required this.origem, required this.cor, required this.focado});

  final double fracao;

  /// Onde a faixa colorida nasce (o 0 dB, no meio do curso).
  final double origem;
  final Color cor;
  final bool focado;

  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width / 2;
    final topo = Medidas.alturaCursorFader / 2;
    final curso = size.height - Medidas.alturaCursorFader;
    double y(double f) => topo + curso * (1 - f);
    canvas.drawLine(Offset(x, y(0)), Offset(x, y(1)), _traco(Cores.filete));
    canvas.drawLine(Offset(x - Medidas.marcaZeroFader, y(origem)), Offset(x + Medidas.marcaZeroFader, y(origem)),
        _traco(Cores.aluminio)..strokeWidth = Medidas.filete);
    canvas.drawLine(Offset(x, y(origem)), Offset(x, y(fracao)), _traco(cor));
    final cursor = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(x, y(fracao)), width: Medidas.larguraCursorFader, height: Medidas.alturaCursorFader),
      const Radius.circular(Raios.canto),
    );
    canvas.drawRRect(cursor, Paint()..color = Cores.painelElevado);
    canvas.drawRRect(
      cursor,
      Paint()
        ..color = focado ? Cores.tally : Cores.aluminio
        ..style = PaintingStyle.stroke
        ..strokeWidth = focado ? Medidas.contornoSelecao : Medidas.filete,
    );
    canvas.drawLine(Offset(x - Medidas.larguraCursorFader / 2 + Medidas.espessuraArco, y(fracao)),
        Offset(x + Medidas.larguraCursorFader / 2 - Medidas.espessuraArco, y(fracao)), _traco(Cores.fitaGaffer));
  }

  Paint _traco(Color cor) => Paint()
    ..color = cor
    ..style = PaintingStyle.stroke
    ..strokeWidth = Medidas.espessuraArco
    ..strokeCap = StrokeCap.round;

  @override
  bool shouldRepaint(PintorFader antigo) =>
      antigo.fracao != fracao || antigo.origem != origem || antigo.cor != cor || antigo.focado != focado;
}
