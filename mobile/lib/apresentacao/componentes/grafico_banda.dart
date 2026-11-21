// Os gráficos pequenos da coluna da banda: no compressor, a curva entrada ×
// saída (reta 1:1 até o Threshold, inclinação 1/ratio depois, com o canto
// marcado); no drive, um ciclo de senoide que achata com o Drive. Só
// ilustram o ajuste e acompanham os controles ao vivo; não são medição.
import 'package:flutter/material.dart';

import '../../nucleo/catalogo/curvas_multibanda.dart';
import '../tema/tokens.dart';

class GraficoCompressor extends StatelessWidget {
  const GraficoCompressor({super.key, required this.limiarDb, required this.razao, required this.ligado, required this.cor});

  final double limiarDb;
  final double razao;
  final bool ligado;
  final Color cor;

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Threshold ${limiarDb.round()} dB, ${razao.round()}:1',
        child: SizedBox(
          height: Medidas.alturaGraficoBanda,
          child: CustomPaint(
            key: const ValueKey('grafico-compressor'),
            painter: PintorCurvaCompressor(limiarDb: limiarDb, razao: razao, ligado: ligado, cor: cor),
          ),
        ),
      );
}

class GraficoDrive extends StatelessWidget {
  const GraficoDrive({super.key, required this.drive, required this.cor});

  final double drive;
  final Color cor;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: Medidas.alturaGraficoBanda,
        child: CustomPaint(key: const ValueKey('grafico-drive'), painter: PintorOndaDrive(drive: drive, cor: cor)),
      );
}

/// Fundo comum dos dois gráficos: o quadro e a linha do meio.
void _quadro(Canvas canvas, Rect area) {
  final rr = RRect.fromRectAndRadius(area, const Radius.circular(Raios.canto));
  canvas.drawRRect(rr, Paint()..color = Cores.painel);
  canvas.drawRRect(rr, Paint()
    ..color = Cores.filete
    ..style = PaintingStyle.stroke);
}

Paint _traco(Color cor) => Paint()
  ..color = cor
  ..style = PaintingStyle.stroke
  ..strokeWidth = Medidas.tracoGraficoBanda
  ..strokeJoin = StrokeJoin.round;

class PintorCurvaCompressor extends CustomPainter {
  const PintorCurvaCompressor({required this.limiarDb, required this.razao, required this.ligado, required this.cor});

  final double limiarDb;
  final double razao;
  final bool ligado;
  final Color cor;

  static const _minimoDb = -60.0;

  @override
  void paint(Canvas canvas, Size size) {
    // quadrado: entrada e saída na mesma escala, para a reta 1:1 ficar a 45°
    final lado = size.shortestSide;
    final area = Rect.fromCenter(center: size.center(Offset.zero), width: lado, height: lado);
    _quadro(canvas, area);
    Offset ponto(double entrada, double saida) => Offset(
        area.left + (entrada - _minimoDb) / -_minimoDb * area.width,
        area.bottom - (saida - _minimoDb) / -_minimoDb * area.height);
    canvas.drawLine(ponto(_minimoDb, _minimoDb), ponto(0, 0), Paint()
      ..color = Cores.filete
      ..strokeWidth = Medidas.filete);
    final pontos = [
      for (final (e, s) in curvaDoCompressor(limiarDb: limiarDb, razao: razao, ligado: ligado, minimoDb: _minimoDb))
        ponto(e, s),
    ];
    canvas.drawPath(Path()..addPolygon(pontos, false), _traco(cor));
    if (ligado) canvas.drawCircle(ponto(limiarDb, limiarDb), Medidas.tracoGraficoBanda * 2, Paint()..color = cor);
  }

  @override
  bool shouldRepaint(PintorCurvaCompressor antigo) =>
      antigo.limiarDb != limiarDb || antigo.razao != razao || antigo.ligado != ligado || antigo.cor != cor;
}

class PintorOndaDrive extends CustomPainter {
  const PintorOndaDrive({required this.drive, required this.cor});

  final double drive;
  final Color cor;

  @override
  void paint(Canvas canvas, Size size) {
    final area = Offset.zero & size;
    _quadro(canvas, area);
    final meio = area.center.dy;
    final amplitude = area.height / 2 - Espacos.s;
    final margem = Espacos.s;
    final largura = area.width - margem * 2;
    final pontos = [
      for (final (fase, y) in ondaSaturada(drive)) Offset(margem + fase * largura, meio - y * amplitude),
    ];
    canvas.drawLine(Offset(margem, meio), Offset(area.right - margem, meio), Paint()
      ..color = Cores.filete
      ..strokeWidth = Medidas.filete);
    canvas.drawPath(Path()..addPolygon(pontos, false), _traco(cor));
  }

  @override
  bool shouldRepaint(PintorOndaDrive antigo) => antigo.drive != drive || antigo.cor != cor;
}
