// O chassi e a tela do aparelho, pintados (nenhuma imagem). O chassi é
// alumínio escovado com bisel, reflexo especular, ranhura usinada em volta
// da tela e parafusos Philips nos cantos; a tela fica encaixada (baixo-
// relevo). Dentro dela: no metal, o anodizado escuro escovado com duas ondas
// de reflexo; no neon, o chão em grade synthwave, a serra em arame, os
// trilhos magenta e as linhas de varredura.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tema/desenho_metal.dart';
import '../tema/paletas_painel.dart';
import '../tema/tema_painel.dart';
import 'tela_pedaleira/neon.dart';

/// O alumínio escovado em volta da tela.
class PintorChassi extends CustomPainter {
  const PintorChassi({required this.recuoTela});

  /// Onde a tela começa, a partir da borda do chassi.
  final double recuoTela;

  static const raio = 10.0;

  @override
  void paint(Canvas canvas, Size size) {
    final area = Offset.zero & size;
    final borda = RRect.fromRectAndRadius(area, const Radius.circular(raio));
    canvas.drawRRect(borda, Paint()
      ..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: CoresChassi.gradiente)
          .createShader(area));
    canvas.save();
    canvas.clipRRect(borda);
    pintarEscovado(canvas, area, claro: CoresChassi.riscoClaro, escuro: CoresChassi.riscoEscuro, passo: 1.2);
    pintarEspecular(canvas, area, CoresChassi.especular);
    canvas.restore();
    pintarBisel(canvas, borda, luz: CoresChassi.biselLuz, sombra: CoresChassi.biselSombra, largura: 2.5);
    final tela = area.deflate(recuoTela);
    final sulco = RRect.fromRectAndRadius(tela.inflate(4), const Radius.circular(6));
    pintarBisel(canvas, sulco, luz: CoresChassi.biselLuz, sombra: CoresChassi.biselSombra, largura: 2, afundado: true);
    pintarParafusosNosCantos(canvas, area, recuoTela / 2, recuoTela / 4,
        corpo: CoresChassi.parafuso, fenda: CoresChassi.fendaParafuso);
  }

  @override
  bool shouldRepaint(PintorChassi antigo) => antigo.recuoTela != recuoTela;
}

/// O fundo da tela dentro do chassi.
class PintorTela extends CustomPainter {
  const PintorTela(this.tema, {this.brilho = 1});

  final TemaPainel tema;
  final double brilho;

  @override
  void paint(Canvas canvas, Size size) {
    final area = Offset.zero & size;
    canvas.drawRect(area, Paint()
      ..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: tema.tela).createShader(area));
    if (tema.ehNeon) {
      _grade(canvas, size);
      _montanhas(canvas, size);
      return;
    }
    pintarEscovado(canvas, area, claro: CoresChassi.escovadoPlacaClaro, escuro: CoresChassi.escovadoPlacaEscuro, passo: 2);
    _ondas(canvas, size);
  }

  /// As duas ondas de luz da tela do Ignissor: faixa em S e arco.
  void _ondas(Canvas canvas, Size size) {
    final luz = Paint()..color = tema.reflexo;
    final (w, h) = (size.width, size.height);
    canvas.drawPath(
        Path()
          ..moveTo(0, 0)
          ..lineTo(w * 0.30, 0)
          ..cubicTo(w * 0.22, h * 0.35, w * 0.42, h * 0.65, w * 0.34, h)
          ..lineTo(0, h)
          ..close(),
        luz);
    canvas.drawPath(
        Path()
          ..moveTo(w, h * 0.08)
          ..cubicTo(w * 0.86, h * 0.25, w * 0.84, h * 0.75, w * 0.93, h)
          ..lineTo(w, h)
          ..close(),
        luz);
  }

  /// O chão de grade no quarto de baixo, com o horizonte e as fugas.
  void _grade(Canvas canvas, Size size) {
    final linha = Paint()
      ..color = tema.reflexo
      ..strokeWidth = 1;
    final horizonte = size.height * 0.72;
    for (var i = 1; i <= 10; i++) {
      final y = horizonte + (size.height - horizonte) * math.pow(i / 10, 2);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linha);
    }
    for (var i = -12; i <= 12; i++) {
      canvas.drawLine(Offset(size.width / 2, horizonte), Offset(size.width / 2 + i * size.width / 12, size.height), linha);
    }
  }

  /// A serra em arame acima do horizonte, nos dois cantos.
  void _montanhas(Canvas canvas, Size size) {
    final base = size.height * 0.72;
    for (final (de, ate) in [(0.0, 0.22), (0.78, 1.0)]) {
      final serra = Path()..moveTo(de * size.width, base);
      for (var i = 1; i <= 6; i++) {
        final x0 = de + (ate - de) * (i - 1) / 6;
        final x1 = de + (ate - de) * i / 6;
        serra
          ..lineTo((x0 + x1) / 2 * size.width, base - (i.isOdd ? 0.12 : 0.05) * size.height)
          ..lineTo(x1 * size.width, base);
      }
      tracoNeon(canvas, serra, CoresNeon.ciano.withValues(alpha: 0.35), largura: 1, brilho: brilho * 0.4);
    }
  }

  @override
  bool shouldRepaint(PintorTela antigo) => antigo.tema != tema || antigo.brilho != brilho;
}
