// Os enfeites desenhados da tela do Axioma: as molas de neon da barra, as
// minimontanhas em arame, o medidor de barras e as linhas de varredura com
// grão da tela. Puramente visuais (fora da semântica), em código.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../tema/paletas_painel.dart';
import 'neon.dart';

/// Bobinas inclinadas, rosa por dentro e ciano por fora, como as da barra.
class PintorMolas extends CustomPainter {
  const PintorMolas({required this.brilho, this.quantidade = 4});

  final double brilho;
  final int quantidade;

  @override
  void paint(Canvas canvas, Size size) {
    final passo = size.width / quantidade;
    for (var i = 0; i < quantidade; i++) {
      final mola = Path();
      final x0 = passo * i + passo * 0.3;
      for (var volta = 0; volta < 5; volta++) {
        final y = size.height * (0.18 + volta * 0.15);
        mola.addOval(Rect.fromCenter(center: Offset(x0 + volta * passo * 0.1, y), width: passo * 0.55, height: size.height * 0.12));
      }
      tracoNeon(canvas, mola, CoresNeon.rosa, largura: 2.2, brilho: brilho);
      tracoNeon(canvas, mola, CoresNeon.ciano, largura: 0.8, brilho: brilho * 0.4);
    }
  }

  @override
  bool shouldRepaint(PintorMolas antigo) => antigo.brilho != brilho || antigo.quantidade != quantidade;
}

/// Minimontanha em arame sobre um chão em grade, na caixinha do medidor.
class PintorMontanhaArame extends CustomPainter {
  const PintorMontanhaArame({required this.brilho, this.espelhada = false});

  final double brilho;
  final bool espelhada;

  @override
  void paint(Canvas canvas, Size size) {
    if (espelhada) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }
    final (w, h) = (size.width, size.height);
    final chao = Path();
    for (var i = 0; i <= 3; i++) {
      final y = h * (0.62 + i * 0.12);
      chao
        ..moveTo(0, y)
        ..lineTo(w, y);
    }
    for (var i = 0; i <= 6; i++) {
      chao
        ..moveTo(w / 2, h * 0.62)
        ..lineTo(w * i / 6, h);
    }
    tracoNeon(canvas, chao, CoresNeon.rosa.withValues(alpha: 0.7), largura: 0.7, brilho: brilho * 0.4);
    final serra = Path()..moveTo(0, h * 0.62);
    for (final (x, y) in [(0.15, 0.3), (0.3, 0.5), (0.48, 0.12), (0.64, 0.45), (0.8, 0.25), (1.0, 0.62)]) {
      serra.lineTo(w * x, h * y);
    }
    serra
      ..moveTo(w * 0.48, h * 0.12)
      ..lineTo(w * 0.5, h * 0.62);
    tracoNeon(canvas, serra, CoresNeon.ciano, largura: 1, brilho: brilho * 0.7);
  }

  @override
  bool shouldRepaint(PintorMontanhaArame antigo) => antigo.brilho != brilho || antigo.espelhada != espelhada;
}

/// Medidor de barras verticais: acende até a [fracao] do parâmetro.
class PintorMedidor extends CustomPainter {
  const PintorMedidor({required this.fracao, required this.apagado, required this.brilho});

  final double fracao;
  final Color apagado;
  final double brilho;

  static const _barras = 12;

  @override
  void paint(Canvas canvas, Size size) {
    final largura = size.width / _barras;
    final acesas = (fracao.clamp(0.0, 1.0) * _barras).round();
    for (var i = 0; i < _barras; i++) {
      final altura = size.height * (0.35 + 0.65 * i / (_barras - 1));
      final barra = Rect.fromLTWH(i * largura + 1, size.height - altura, largura - 2, altura);
      final acesa = i < acesas;
      if (acesa) {
        canvas.drawRect(barra.inflate(1.5), Paint()
          ..color = CoresNeon.ciano.withValues(alpha: 0.45 * brilho)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 * brilho));
      }
      canvas.drawRect(barra, Paint()..color = acesa ? CoresNeon.ciano : apagado);
    }
  }

  @override
  bool shouldRepaint(PintorMedidor antigo) => antigo.fracao != fracao || antigo.apagado != apagado || antigo.brilho != brilho;
}

/// Linhas de varredura e grão bem leves por cima da tela inteira.
class PintorVarredura extends CustomPainter {
  const PintorVarredura();

  static const _passo = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    final linha = Paint()..color = CoresNeon.varredura;
    for (var y = 0.0; y < size.height; y += _passo) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), linha);
    }
    final grao = Paint()..color = CoresNeon.grao;
    final pontos = (size.width * size.height / 900).floor();
    for (var i = 0; i < pontos; i++) {
      final x = (math.sin(i * 12.9898) * 0.5 + 0.5) * size.width;
      final y = (math.sin(i * 78.233) * 0.5 + 0.5) * size.height;
      canvas.drawRect(Rect.fromLTWH(x, y, 1, 1), grao);
    }
  }

  @override
  bool shouldRepaint(PintorVarredura antigo) => false;
}
