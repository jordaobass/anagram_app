// O fundo da moldura temática, pintado (nenhuma imagem): no metal, o
// gradiente do alumínio, o escovado fino e duas ondas largas de reflexo; no
// neon, os trilhos magenta, o chão em grade synthwave e uma serra de
// montanhas em arame. Tudo estático: não há movimento para "reduzir".
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tema/tema_painel.dart';

class PintorFundoPainel extends CustomPainter {
  const PintorFundoPainel(this.tema);

  final TemaPainel tema;

  @override
  void paint(Canvas canvas, Size size) {
    final area = Offset.zero & size;
    canvas.drawRect(
        area,
        Paint()
          ..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: tema.fundo)
              .createShader(area));
    if (tema.ehNeon) {
      _grade(canvas, size);
      _montanhas(canvas, size);
      _trilhos(canvas, size);
    } else {
      _escovado(canvas, size);
      _ondas(canvas, size);
    }
  }

  /// Riscos horizontais finos, de comprimento e altura que parecem soltos
  /// mas são fixos (seno), para a captura não variar.
  void _escovado(Canvas canvas, Size size) {
    final risco = Paint()
      ..color = tema.reflexo
      ..strokeWidth = 1;
    for (var i = 0; i < size.height / _passoEscovado; i++) {
      final y = i * _passoEscovado + 1;
      final inicio = (math.sin(i * 12.9898) * 0.5 + 0.5) * size.width * 0.6;
      final comprimento = (math.sin(i * 78.233) * 0.5 + 0.5) * size.width * 0.5 + size.width * 0.15;
      canvas.drawLine(Offset(inicio, y), Offset(math.min(size.width, inicio + comprimento), y), risco);
    }
  }

  static const _passoEscovado = 3.0;

  /// As duas ondas de luz da tela do Ignissor: uma faixa em S à esquerda e
  /// um arco à direita.
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

  /// O chão de grade no terço de baixo: horizontais cada vez mais juntas no
  /// horizonte e verticais que fogem para o centro.
  void _grade(Canvas canvas, Size size) {
    final linha = Paint()
      ..color = tema.reflexo
      ..strokeWidth = 1;
    final horizonte = size.height * 0.68;
    final chao = size.height - horizonte;
    for (var i = 1; i <= _linhasChao; i++) {
      final y = horizonte + chao * math.pow(i / _linhasChao, 2);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linha);
    }
    final fuga = Offset(size.width / 2, horizonte);
    for (var i = -_colunasChao; i <= _colunasChao; i++) {
      canvas.drawLine(fuga, Offset(size.width / 2 + i * size.width / _colunasChao, size.height), linha);
    }
  }

  static const _linhasChao = 9;
  static const _colunasChao = 10;

  /// A serra em arame logo acima do horizonte, nos dois cantos.
  void _montanhas(Canvas canvas, Size size) {
    final arame = Paint()
      ..color = tema.reflexo
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final base = size.height * 0.68;
    for (final (de, ate) in [(0.0, 0.26), (0.74, 1.0)]) {
      final picos = [for (var i = 0; i <= 6; i++) de + (ate - de) * i / 6];
      final serra = Path()..moveTo(picos.first * size.width, base);
      for (var i = 1; i < picos.length; i++) {
        final altura = (i.isOdd ? 0.16 : 0.07) * size.height;
        serra.lineTo((picos[i - 1] + picos[i]) / 2 * size.width, base - altura);
        serra.lineTo(picos[i] * size.width, base);
      }
      canvas.drawPath(serra, arame);
    }
  }

  /// Os dois trilhos magenta da tela do Axioma, em cima e embaixo.
  void _trilhos(Canvas canvas, Size size) {
    final trilho = Paint()
      ..color = tema.friso
      ..strokeWidth = _espessuraTrilho;
    for (final y in [_recuoTrilho, size.height - _recuoTrilho]) {
      canvas.drawLine(Offset(TemaPainel.chanfro, y), Offset(size.width - TemaPainel.chanfro, y), trilho);
    }
  }

  static const _espessuraTrilho = 2.0;
  static const _recuoTrilho = 4.0;

  @override
  bool shouldRepaint(PintorFundoPainel antigo) => antigo.tema != tema;
}
