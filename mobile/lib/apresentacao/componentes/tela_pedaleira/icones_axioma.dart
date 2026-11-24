// Os ícones da barra do Axioma, desenhados como tubo de neon num quadrado de
// 1 × 1 (escala para o botão): fechar, as cinco abas (mixer, onda, envelope,
// arpejo em escada, ajustes) e as ações (remover, trocar de linha, menu).
// Desenho próprio: nenhuma arte da Darkglass.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'neon.dart';

enum IconeAxioma { fechar, mixer, onda, envelope, escada, engrenagem, lixeira, troca, menu }

class PintorIconeAxioma extends CustomPainter {
  const PintorIconeAxioma({required this.icone, required this.cor, this.brilho = 1});

  final IconeAxioma icone;
  final Color cor;
  final double brilho;

  static const _espessura = 0.075;
  static const _halo = 0.5;

  @override
  void paint(Canvas canvas, Size size) {
    // escala o caminho, não o canvas: o desfoque do halo é em pixels
    final s = size.shortestSide;
    final escala = Matrix4.translationValues((size.width - s) / 2, (size.height - s) / 2, 0)
      ..multiply(Matrix4.diagonal3Values(s, s, 1));
    tracoNeon(canvas, _caminho().transform(escala.storage), cor, largura: s * _espessura, brilho: brilho * _halo);
  }

  Path _caminho() => switch (icone) {
        IconeAxioma.fechar => Path()
          ..moveTo(0.22, 0.22)
          ..lineTo(0.78, 0.78)
          ..moveTo(0.78, 0.22)
          ..lineTo(0.22, 0.78),
        IconeAxioma.mixer => _mixer(),
        IconeAxioma.onda => _seno(),
        IconeAxioma.envelope => Path()
          ..moveTo(0.12, 0.8)
          ..lineTo(0.3, 0.22)
          ..lineTo(0.48, 0.5)
          ..lineTo(0.72, 0.5)
          ..lineTo(0.88, 0.8),
        IconeAxioma.escada => Path()
          ..moveTo(0.14, 0.82)
          ..lineTo(0.14, 0.64)..lineTo(0.38, 0.64)..lineTo(0.38, 0.46)
          ..lineTo(0.62, 0.46)..lineTo(0.62, 0.28)..lineTo(0.86, 0.28),
        IconeAxioma.engrenagem => _engrenagem(),
        IconeAxioma.lixeira => Path()
          ..moveTo(0.22, 0.3)..lineTo(0.78, 0.3)
          ..moveTo(0.4, 0.3)..lineTo(0.42, 0.18)..lineTo(0.58, 0.18)..lineTo(0.6, 0.3)
          ..moveTo(0.28, 0.3)..lineTo(0.34, 0.84)..lineTo(0.66, 0.84)..lineTo(0.72, 0.3),
        IconeAxioma.troca => Path()
          ..moveTo(0.18, 0.36)..lineTo(0.8, 0.36)..moveTo(0.66, 0.22)..lineTo(0.8, 0.36)..lineTo(0.66, 0.5)
          ..moveTo(0.82, 0.66)..lineTo(0.2, 0.66)..moveTo(0.34, 0.52)..lineTo(0.2, 0.66)..lineTo(0.34, 0.8),
        IconeAxioma.menu => Path()
          ..addOval(Rect.fromCircle(center: const Offset(0.5, 0.24), radius: 0.05))
          ..addOval(Rect.fromCircle(center: const Offset(0.5, 0.5), radius: 0.05))
          ..addOval(Rect.fromCircle(center: const Offset(0.5, 0.76), radius: 0.05)),
      };

  /// Três faders com os cursores em alturas diferentes.
  Path _mixer() {
    final p = Path();
    for (final (x, y) in [(0.26, 0.38), (0.5, 0.62), (0.74, 0.3)]) {
      p
        ..moveTo(x, 0.16)
        ..lineTo(x, 0.84)
        ..moveTo(x - 0.08, y)
        ..lineTo(x + 0.08, y);
    }
    return p;
  }

  Path _seno() {
    final p = Path()..moveTo(0.1, 0.5);
    for (var i = 1; i <= 24; i++) {
      final x = i / 24;
      p.lineTo(0.1 + x * 0.8, 0.5 - math.sin(x * 2 * math.pi) * 0.26);
    }
    return p;
  }

  Path _engrenagem() {
    final p = Path()..addOval(Rect.fromCircle(center: const Offset(0.5, 0.5), radius: 0.13));
    final dentes = Path();
    for (var i = 0; i <= 16; i++) {
      final raio = i.isEven ? 0.34 : 0.26;
      final ponto = const Offset(0.5, 0.5) + Offset.fromDirection(i * math.pi / 8, raio);
      i == 0 ? dentes.moveTo(ponto.dx, ponto.dy) : dentes.lineTo(ponto.dx, ponto.dy);
    }
    return p..addPath(dentes, Offset.zero);
  }

  @override
  bool shouldRepaint(PintorIconeAxioma antigo) => antigo.icone != icone || antigo.cor != cor || antigo.brilho != brilho;
}
