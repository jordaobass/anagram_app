// Ícone desenhado de microfone por tipo (dinâmico, condensador, fita): as
// fotos dos microfones que a pedaleira mostra ficam no firmware dela e não
// vêm no Darkglass Suite, então o app desenha a silhueta de cada tipo.
import 'package:flutter/material.dart';

import '../../nucleo/catalogo/catalogo_gabinetes.dart';
import '../tema/tokens.dart';

class IconeMicrofone extends StatelessWidget {
  const IconeMicrofone({super.key, required this.tipo, required this.cor, this.tamanho = Medidas.iconeMicrofone});

  final TipoMicrofone tipo;
  final Color cor;
  final double tamanho;

  @override
  Widget build(BuildContext context) =>
      SizedBox.square(dimension: tamanho, child: CustomPaint(painter: _PintorMicrofone(tipo, cor)));
}

class _PintorMicrofone extends CustomPainter {
  _PintorMicrofone(this.tipo, this.cor);

  final TipoMicrofone tipo;
  final Color cor;

  @override
  void paint(Canvas canvas, Size size) {
    final traco = Paint()
      ..color = cor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * Medidas.tracoMicrofone
      ..strokeCap = StrokeCap.round;
    final w = size.width;
    final h = size.height;
    switch (tipo) {
      case TipoMicrofone.dinamico:
        _dinamico(canvas, traco, w, h);
      case TipoMicrofone.condensador:
        _condensador(canvas, traco, w, h);
      case TipoMicrofone.fita:
        _fita(canvas, traco, w, h);
      case TipoMicrofone.outro:
        canvas.drawCircle(Offset(w / 2, h / 2), w * 0.32, traco);
    }
  }

  /// Cabeça redonda com grade, sobre um cabo curto (silhueta de um 57/421).
  void _dinamico(Canvas canvas, Paint traco, double w, double h) {
    final cabeca = Rect.fromCenter(center: Offset(w / 2, h * 0.32), width: w * 0.46, height: h * 0.46);
    canvas.drawOval(cabeca, traco);
    canvas.drawLine(Offset(cabeca.left, cabeca.center.dy), Offset(cabeca.right, cabeca.center.dy), traco);
    canvas.drawLine(Offset(w / 2, cabeca.bottom), Offset(w / 2, h * 0.9), traco);
  }

  /// Corpo comprido com a cápsula larga em cima (silhueta de um 103/414).
  void _condensador(Canvas canvas, Paint traco, double w, double h) {
    final capsula = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.3, h * 0.08, w * 0.4, h * 0.38), Radius.circular(w * 0.2));
    canvas.drawRRect(capsula, traco);
    canvas.drawRect(Rect.fromLTWH(w * 0.38, h * 0.46, w * 0.24, h * 0.44), traco);
  }

  /// Caixa retangular com a fita vertical (silhueta de um 121/160).
  void _fita(Canvas canvas, Paint traco, double w, double h) {
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.24, h * 0.1, w * 0.52, h * 0.62), Radius.circular(w * 0.08)),
        traco);
    canvas.drawLine(Offset(w / 2, h * 0.2), Offset(w / 2, h * 0.62), traco);
    canvas.drawLine(Offset(w / 2, h * 0.72), Offset(w / 2, h * 0.9), traco);
  }

  @override
  bool shouldRepaint(_PintorMicrofone antigo) => antigo.tipo != tipo || antigo.cor != cor;
}
