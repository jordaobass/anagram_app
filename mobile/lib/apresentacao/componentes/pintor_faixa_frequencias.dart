// Desenho da faixa de frequência do multibanda e da alça de cada corte. Cada
// banda é a curva de resposta dela (passa-baixas, passa-banda ou passa-altas)
// sobreposta às outras, preenchida na cor da banda e com a altura do Level
// dela, como os analisadores de EQ desenham.
import 'package:flutter/material.dart';

import '../../nucleo/catalogo/curvas_multibanda.dart';
import '../tema/tokens.dart';
import 'escalas_grafico.dart';

/// Uma banda na faixa: os cortes (nulo = borda do áudio), o nível e se está mutada.
class RaiaBanda {
  const RaiaBanda({required this.cor, this.inferior, this.superior, this.nivelDb = 0, required this.muda});
  final Color cor;
  final double? inferior;
  final double? superior;
  final double nivelDb;
  final bool muda;

  @override
  bool operator ==(Object other) =>
      other is RaiaBanda && other.cor == cor && other.inferior == inferior && other.superior == superior &&
      other.nivelDb == nivelDb && other.muda == muda;

  @override
  int get hashCode => Object.hash(cor, inferior, superior, nivelDb, muda);
}

class PintorFaixaFrequencias extends CustomPainter {
  const PintorFaixaFrequencias({required this.cores, required this.raias, required this.rotulos, required this.alturaRaia, this.escala = const EscalaGanho()});

  final Paleta cores;

  final List<RaiaBanda> raias;
  final EscalaGanho escala;

  /// Marcas da régua: posição na faixa → texto ("100", "1k").
  final Map<double, String> rotulos;
  final double alturaRaia;

  @override
  void paint(Canvas canvas, Size size) {
    final fundo = Rect.fromLTWH(0, 0, size.width, raias.length * alturaRaia);
    canvas.drawRRect(RRect.fromRectAndRadius(fundo, const Radius.circular(Raios.controle)), Paint()..color = cores.painel);
    _marcas(canvas, size, fundo);
    _eixo(canvas, size);
    for (final raia in raias) {
      _raia(canvas, size, raia);
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(fundo, const Radius.circular(Raios.controle)),
      Paint()
        ..color = cores.filete
        ..style = PaintingStyle.stroke,
    );
  }

  void _raia(Canvas canvas, Size size, RaiaBanda raia) {
    final altura = raias.length * alturaRaia;
    final pontos = [
      for (final (x, db) in curvaDaBanda(inferior: raia.inferior, superior: raia.superior, nivelDb: raia.nivelDb))
        Offset(x * size.width, escala.altura(db) * altura),
    ];
    final contorno = Path()..addPolygon(pontos, false);
    final area = Path.from(contorno)
      ..lineTo(size.width, altura)
      ..lineTo(0, altura)
      ..close();
    final opacidade = raia.muda ? Medidas.opacidadeRaiaMuda : Medidas.opacidadeCurvaBanda;
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, altura), const Radius.circular(Raios.controle)));
    canvas.drawPath(area, Paint()..color = raia.cor.withValues(alpha: opacidade));
    canvas.drawPath(
        contorno,
        Paint()
          ..color = raia.cor.withValues(alpha: raia.muda ? Medidas.opacidadeRaiaMuda : 1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = Medidas.tracoCurvaBanda);
    canvas.restore();
  }

  /// A escala em dB (+12, 0, −12, −24, −36 e, se preciso, até −60): linhas
  /// discretas e o número na borda esquerda; a de 0 dB um pouco mais forte.
  void _eixo(Canvas canvas, Size size) {
    final altura = raias.length * alturaRaia;
    for (final db in escala.marcas) {
      final y = escala.altura(db) * altura;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), Paint()
        ..color = cores.filete.withValues(alpha: db == 0 ? 1 : Opacidades.gradeSecundaria)
        ..strokeWidth = Medidas.filete);
      pintarRotuloDoEixo(canvas, cores, rotuloDoDb(db), Medidas.fonteReguaFrequencias,
          (texto) => Offset(Espacos.xs, (y - texto.height / 2).clamp(0.0, altura - texto.height)));
    }
  }

  void _marcas(Canvas canvas, Size size, Rect fundo) {
    final linha = Paint()
      ..color = cores.filete
      ..strokeWidth = Medidas.filete;
    for (final MapEntry(key: fracao, value: texto) in rotulos.entries) {
      final x = fracao * size.width;
      canvas.drawLine(Offset(x, fundo.top), Offset(x, fundo.bottom), linha);
      pintarRotuloDoEixo(canvas, cores, texto, Medidas.fonteReguaFrequencias,
          (tamanho) => Offset(x - tamanho.width / 2, fundo.bottom + Espacos.xxs));
    }
  }

  @override
  bool shouldRepaint(PintorFaixaFrequencias antigo) =>
      antigo.cores != cores || !_mesmas(antigo.raias, raias) || antigo.rotulos.length != rotulos.length || antigo.escala != escala;

  static bool _mesmas(List<RaiaBanda> a, List<RaiaBanda> b) =>
      a.length == b.length && [for (var i = 0; i < a.length; i++) a[i] == b[i]].every((igual) => igual);
}

/// A alça: traço vertical no meio do alvo, puxador redondo e o valor ao lado.
class PintorAlcaFrequencia extends CustomPainter {
  const PintorAlcaFrequencia({required this.cores, required this.texto, required this.estilo, this.aEsquerda = false, this.acima = 0, this.abaixo = 0});

  final Paleta cores;

  final String texto;
  final TextStyle? estilo;
  final bool aEsquerda;

  /// Quanto o traço passa do alvo para cima e para baixo: ele corta as
  /// curvas da faixa inteira, mesmo com o alvo só na linha da banda.
  final double acima;
  final double abaixo;

  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width / 2;
    canvas.drawLine(
      Offset(x, -acima),
      Offset(x, size.height + abaixo),
      Paint()
        ..color = cores.texto
        ..strokeWidth = Medidas.tracoAlcaFrequencia,
    );
    final centro = Offset(x, size.height / 2);
    canvas.drawCircle(centro, Medidas.puxadorAlcaFrequencia / 2, Paint()..color = cores.texto);
    canvas.drawCircle(centro, Medidas.puxadorAlcaFrequencia / 4, Paint()..color = cores.mioloAlca);
    final pintor = TextPainter(text: TextSpan(text: texto, style: estilo), textDirection: TextDirection.ltr)..layout();
    final dx = aEsquerda ? x - Espacos.xs - pintor.width : x + Espacos.xs;
    pintor.paint(canvas, Offset(dx, Espacos.xxs));
    pintor.dispose();
  }

  @override
  bool shouldRepaint(PintorAlcaFrequencia antigo) => antigo.cores != cores || antigo.texto != texto || antigo.aEsquerda != aEsquerda || antigo.acima != acima || antigo.abaixo != abaixo;
}
