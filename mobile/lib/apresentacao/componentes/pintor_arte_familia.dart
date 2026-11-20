// Arte própria para bloco sem miniatura: um gabinete genérico na cor da
// família, sem marca nem logo, com um glifo da função desenhado em traço.
import 'dart:math';

import 'package:flutter/rendering.dart';

import '../../nucleo/catalogo/familia_bloco.dart';
import '../tema/tokens.dart';

class PintorArteFamilia extends CustomPainter {
  const PintorArteFamilia(this.familia);

  final FamiliaBloco familia;

  @override
  void paint(Canvas canvas, Size size) {
    final cor = Cores.daFamilia(familia);
    final corpo = _corpo(size);
    canvas.drawRRect(corpo, Paint()..color = cor);
    canvas.drawRRect(
      corpo.deflate(size.width * 0.06),
      Paint()
        ..color = Cores.tintaMarcador.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.02,
    );
    final traco = Paint()
      ..color = Cores.tintaMarcador
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.045
      ..strokeCap = StrokeCap.round;
    _glifo(canvas, corpo.outerRect.deflate(size.width * 0.2), traco);
  }

  /// Amp e gabinete são "deitados"; pedais são "em pé".
  RRect _corpo(Size size) {
    final deitado = familia == FamiliaBloco.amplificador || familia == FamiliaBloco.gabinete;
    final largura = size.width * (deitado ? 0.92 : 0.7);
    final altura = size.height * (deitado ? 0.7 : 0.92);
    final retangulo = Rect.fromCenter(center: size.center(Offset.zero), width: largura, height: altura);
    return RRect.fromRectAndRadius(retangulo, Radius.circular(size.width * 0.08));
  }

  void _glifo(Canvas canvas, Rect area, Paint traco) {
    final caminho = switch (familia) {
      FamiliaBloco.drive => _onda(area, ceifada: true),
      FamiliaBloco.modulacao => _onda(area, ceifada: false),
      FamiliaBloco.compressor => _setas(area),
      FamiliaBloco.equalizador => _faders(area),
      FamiliaBloco.filtro => _curvaFiltro(area),
      FamiliaBloco.delay => _ecos(area),
      FamiliaBloco.reverb => _arcos(area),
      FamiliaBloco.amplificador => _grade(area),
      FamiliaBloco.gabinete => _falantes(area),
      FamiliaBloco.utilitario => _plugue(area),
    };
    canvas.drawPath(caminho, traco);
  }

  Path _onda(Rect a, {required bool ceifada}) {
    final caminho = Path();
    for (var i = 0; i <= 40; i++) {
      final x = a.left + a.width * i / 40;
      var y = sin(i / 40 * 2 * pi * 2);
      if (ceifada) y = y.clamp(-0.55, 0.55) / 0.55;
      final ponto = Offset(x, a.center.dy - y * a.height * 0.3);
      i == 0 ? caminho.moveTo(ponto.dx, ponto.dy) : caminho.lineTo(ponto.dx, ponto.dy);
    }
    return caminho;
  }

  Path _setas(Rect a) => Path()
    ..moveTo(a.left, a.top + a.height * 0.2)
    ..lineTo(a.center.dx, a.center.dy)
    ..lineTo(a.left, a.bottom - a.height * 0.2)
    ..moveTo(a.center.dx, a.center.dy)
    ..lineTo(a.right, a.center.dy);

  Path _faders(Rect a) {
    final caminho = Path();
    const alturas = [0.3, 0.7, 0.45, 0.6];
    for (var i = 0; i < alturas.length; i++) {
      final x = a.left + a.width * (i + 0.5) / alturas.length;
      caminho
        ..moveTo(x, a.top)
        ..lineTo(x, a.bottom)
        ..moveTo(x - a.width * 0.07, a.top + a.height * alturas[i])
        ..lineTo(x + a.width * 0.07, a.top + a.height * alturas[i]);
    }
    return caminho;
  }

  Path _curvaFiltro(Rect a) => Path()
    ..moveTo(a.left, a.top + a.height * 0.3)
    ..lineTo(a.center.dx, a.top + a.height * 0.3)
    ..quadraticBezierTo(a.right - a.width * 0.2, a.top + a.height * 0.25, a.right, a.bottom);

  Path _ecos(Rect a) {
    final caminho = Path();
    for (var i = 0; i < 4; i++) {
      final raio = a.height * (0.22 - i * 0.045);
      caminho.addOval(Rect.fromCircle(center: Offset(a.left + a.width * (0.15 + i * 0.25), a.center.dy), radius: raio));
    }
    return caminho;
  }

  Path _arcos(Rect a) {
    final caminho = Path();
    for (var i = 1; i <= 3; i++) {
      final raio = a.width * 0.16 * i;
      caminho.addArc(Rect.fromCircle(center: a.bottomLeft, radius: raio), -pi / 2, pi / 2);
    }
    return caminho;
  }

  Path _grade(Rect a) {
    final caminho = Path()..addRect(a);
    for (var i = 1; i < 4; i++) {
      final y = a.top + a.height * i / 4;
      caminho
        ..moveTo(a.left, y)
        ..lineTo(a.right, y);
    }
    return caminho;
  }

  Path _falantes(Rect a) {
    final caminho = Path();
    final raio = min(a.width, a.height) * 0.22;
    for (final dx in [-1, 1]) {
      for (final dy in [-1, 1]) {
        caminho.addOval(Rect.fromCircle(
            center: a.center + Offset(dx * a.width * 0.24, dy * a.height * 0.25), radius: raio));
      }
    }
    return caminho;
  }

  Path _plugue(Rect a) => Path()
    ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: a.center, width: a.width * 0.5, height: a.height * 0.45), Radius.circular(a.width * 0.06)))
    ..moveTo(a.center.dx - a.width * 0.1, a.center.dy - a.height * 0.22)
    ..lineTo(a.center.dx - a.width * 0.1, a.top)
    ..moveTo(a.center.dx + a.width * 0.1, a.center.dy - a.height * 0.22)
    ..lineTo(a.center.dx + a.width * 0.1, a.top)
    ..moveTo(a.center.dx, a.center.dy + a.height * 0.22)
    ..lineTo(a.center.dx, a.bottom);

  @override
  bool shouldRepaint(PintorArteFamilia antigo) => antigo.familia != familia;
}
