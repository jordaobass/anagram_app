// Curva do Global EQ como na tela da Anagram: grade de frequência (log,
// 20 Hz–20 kHz), eixo de +15 a −15 dB, a soma das 6 bandas preenchida na cor
// do modo (ganho verde, frequência roxa, largura laranja) e um ponto por
// banda, que o dedo arrasta em frequência × ganho.
import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../../nucleo/ajustes/curva_global_eq.dart';
import '../tema/tokens.dart';

class GeometriaGlobalEq {
  const GeometriaGlobalEq(this.tamanho);

  final Size tamanho;
  static const fMin = 20.0;
  static const fMax = 20000.0;

  /// O eixo da tela da pedaleira; o ganho vai a ±18, o ponto para na borda.
  static const dbVisivel = Medidas.dbVisivelGlobalEq;

  double x(double f) => tamanho.width * math.log(f / fMin) / math.log(fMax / fMin);
  double y(double db) => tamanho.height / 2 * (1 - db / dbVisivel);
  double frequencia(double x) => fMin * math.pow(fMax / fMin, (x / tamanho.width).clamp(0.0, 1.0));
  double ganho(double y) => (1 - y / (tamanho.height / 2)) * dbVisivel;
  Offset ponto(BandaGlobalEq b) => Offset(x(b.frequencia), y(b.ganho.clamp(-dbVisivel, dbVisivel)));
}

class PintorGlobalEq extends CustomPainter {
  const PintorGlobalEq(this.bandas, {required this.cor, this.ativa});

  final List<BandaGlobalEq> bandas;
  final Color cor;

  /// Índice da banda sendo arrastada (desenhada em destaque).
  final int? ativa;

  @override
  void paint(Canvas canvas, Size size) {
    final g = GeometriaGlobalEq(size);
    _grade(canvas, size, g);
    final curva = Path();
    for (var px = 0.0; px <= size.width; px += 2) {
      final ponto = Offset(px, g.y(respostaEmDb(bandas, g.frequencia(px))));
      px == 0 ? curva.moveTo(ponto.dx, ponto.dy) : curva.lineTo(ponto.dx, ponto.dy);
    }
    final preenchida = Path.from(curva)
      ..lineTo(size.width, g.y(0))
      ..lineTo(0, g.y(0))
      ..close();
    canvas.drawPath(preenchida, Paint()..color = cor.withValues(alpha: Medidas.opacidadeCurvaBanda));
    canvas.drawPath(curva, _traco(cor, Medidas.filete * 2));
    for (var i = 0; i < bandas.length; i++) {
      _ponto(canvas, g.ponto(bandas[i]), destaque: i == ativa);
    }
  }

  void _grade(Canvas canvas, Size size, GeometriaGlobalEq g) {
    final fina = _traco(Cores.filete, Medidas.filete);
    for (final f in const [50.0, 100.0, 200.0, 500.0, 1000.0, 2000.0, 5000.0, 10000.0]) {
      canvas.drawLine(Offset(g.x(f), 0), Offset(g.x(f), size.height), fina);
    }
    for (final db in const [-15.0, -10.0, -5.0, 5.0, 10.0, 15.0]) {
      canvas.drawLine(Offset(0, g.y(db)), Offset(size.width, g.y(db)), fina);
    }
    canvas.drawLine(Offset(0, g.y(0)), Offset(size.width, g.y(0)), _traco(Cores.aluminio, Medidas.filete));
    _rotulo(canvas, '+15', Offset(Espacos.xs, g.y(15)));
    _rotulo(canvas, '-15', Offset(Espacos.xs, g.y(-15) - Medidas.fonteEixoEq - Espacos.xs));
  }

  void _rotulo(Canvas canvas, String texto, Offset onde) {
    final pintor = TextPainter(
      text: TextSpan(
          text: texto,
          style: const TextStyle(fontFamily: Fontes.rotulo, color: Cores.textoSecundario, fontSize: Medidas.fonteEixoEq)),
      textDirection: TextDirection.ltr,
    )..layout();
    pintor.paint(canvas, onde);
    pintor.dispose();
  }

  void _ponto(Canvas canvas, Offset centro, {required bool destaque}) {
    canvas.drawCircle(centro, Medidas.raioPontoEq, Paint()..color = Cores.fitaGaffer);
    canvas.drawCircle(centro, Medidas.raioPontoEq,
        _traco(destaque ? Cores.tally : Cores.painel, destaque ? Medidas.contornoSelecao : Medidas.filete));
  }

  Paint _traco(Color cor, double espessura) => Paint()
    ..color = cor
    ..style = PaintingStyle.stroke
    ..strokeWidth = espessura;

  @override
  bool shouldRepaint(PintorGlobalEq antigo) {
    if (antigo.ativa != ativa || antigo.cor != cor || antigo.bandas.length != bandas.length) return true;
    for (var i = 0; i < bandas.length; i++) {
      final (a, b) = (antigo.bandas[i], bandas[i]);
      if (a.frequencia != b.frequencia || a.ganho != b.ganho || a.largura != b.largura) return true;
    }
    return false;
  }
}
