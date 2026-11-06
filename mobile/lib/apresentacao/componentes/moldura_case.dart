// Painel com cantoneiras de alumínio, como as quinas de um case de
// estrada. Só o desenho das quinas: o resto é filete de 1px.
import 'package:flutter/material.dart';

import '../tema/tokens.dart';

class MolduraCase extends StatelessWidget {
  const MolduraCase({super.key, required this.child, this.preenchimento = const EdgeInsets.all(Espacos.l)});

  final Widget child;
  final EdgeInsets preenchimento;

  @override
  Widget build(BuildContext context) => CustomPaint(
        foregroundPainter: const _PintorCantoneiras(),
        child: Container(
          padding: preenchimento,
          decoration: BoxDecoration(
            color: Cores.painel,
            border: Border.all(color: Cores.filete, width: Medidas.filete),
            borderRadius: BorderRadius.circular(Raios.canto),
          ),
          child: child,
        ),
      );
}

class _PintorCantoneiras extends CustomPainter {
  const _PintorCantoneiras();

  @override
  void paint(Canvas canvas, Size size) {
    final tinta = Paint()
      ..color = Cores.aluminio
      ..style = PaintingStyle.stroke
      ..strokeWidth = Medidas.contornoSelecao;
    const t = Medidas.cantoneira;
    final cantos = [
      (Offset.zero, const Offset(1, 1)),
      (Offset(size.width, 0), const Offset(-1, 1)),
      (Offset(0, size.height), const Offset(1, -1)),
      (Offset(size.width, size.height), const Offset(-1, -1)),
    ];
    for (final (canto, sentido) in cantos) {
      final caminho = Path()
        ..moveTo(canto.dx + sentido.dx * t, canto.dy)
        ..lineTo(canto.dx, canto.dy)
        ..lineTo(canto.dx, canto.dy + sentido.dy * t);
      canvas.drawPath(caminho, tinta);
    }
  }

  @override
  bool shouldRepaint(_PintorCantoneiras antigo) => false;
}
