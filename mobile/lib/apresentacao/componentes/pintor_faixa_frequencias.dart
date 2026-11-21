// Desenho da faixa de frequência do multibanda e da alça de cada corte.
import 'package:flutter/material.dart';

import '../tema/tokens.dart';

/// Uma banda na faixa: de onde até onde (em fração da faixa) e se está mutada.
class RaiaBanda {
  const RaiaBanda({required this.cor, required this.de, required this.ate, required this.muda});
  final Color cor;
  final double de;
  final double ate;
  final bool muda;
}

class PintorFaixaFrequencias extends CustomPainter {
  const PintorFaixaFrequencias({required this.raias, required this.rotulos, required this.alturaRaia});

  final List<RaiaBanda> raias;

  /// Marcas da régua: posição na faixa → texto ("100", "1k").
  final Map<double, String> rotulos;
  final double alturaRaia;

  @override
  void paint(Canvas canvas, Size size) {
    final fundo = Rect.fromLTWH(0, 0, size.width, raias.length * alturaRaia);
    canvas.drawRRect(RRect.fromRectAndRadius(fundo, const Radius.circular(Raios.controle)), Paint()..color = Cores.painel);
    _marcas(canvas, size, fundo);
    for (var i = 0; i < raias.length; i++) {
      _raia(canvas, size, raias[i], i);
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(fundo, const Radius.circular(Raios.controle)),
      Paint()
        ..color = Cores.filete
        ..style = PaintingStyle.stroke,
    );
  }

  void _raia(Canvas canvas, Size size, RaiaBanda raia, int linha) {
    // corte invertido (o de baixo acima do de cima) não deixa banda nenhuma
    if (raia.ate <= raia.de) return;
    final folga = Espacos.xs;
    final caixa = Rect.fromLTRB(
        raia.de * size.width, linha * alturaRaia + folga, raia.ate * size.width, (linha + 1) * alturaRaia - folga);
    final opacidade = raia.muda ? Medidas.opacidadeRaiaMuda : Medidas.opacidadeRaiaBanda;
    canvas.drawRRect(RRect.fromRectAndRadius(caixa, const Radius.circular(Raios.canto)),
        Paint()..color = raia.cor.withValues(alpha: opacidade));
  }

  void _marcas(Canvas canvas, Size size, Rect fundo) {
    final linha = Paint()
      ..color = Cores.filete
      ..strokeWidth = Medidas.filete;
    for (final MapEntry(key: fracao, value: texto) in rotulos.entries) {
      final x = fracao * size.width;
      canvas.drawLine(Offset(x, fundo.top), Offset(x, fundo.bottom), linha);
      final pintor = TextPainter(
        text: TextSpan(text: texto, style: const TextStyle(color: Cores.textoSecundario, fontSize: _fonteRegua, fontFamily: Fontes.rotulo)),
        textDirection: TextDirection.ltr,
      )..layout();
      pintor.paint(canvas, Offset(x - pintor.width / 2, fundo.bottom + Espacos.xxs));
      pintor.dispose();
    }
  }

  static const _fonteRegua = 11.0;

  @override
  bool shouldRepaint(PintorFaixaFrequencias antigo) => antigo.raias != raias || antigo.rotulos != rotulos;
}

/// A alça: traço vertical no meio do alvo, puxador redondo e o valor ao lado.
class PintorAlcaFrequencia extends CustomPainter {
  const PintorAlcaFrequencia({required this.texto, required this.estilo, this.aEsquerda = false});

  final String texto;
  final TextStyle? estilo;
  final bool aEsquerda;

  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width / 2;
    canvas.drawLine(
      Offset(x, 0),
      Offset(x, size.height),
      Paint()
        ..color = Cores.texto
        ..strokeWidth = Medidas.tracoAlcaFrequencia,
    );
    final centro = Offset(x, size.height / 2);
    canvas.drawCircle(centro, Medidas.puxadorAlcaFrequencia / 2, Paint()..color = Cores.texto);
    canvas.drawCircle(centro, Medidas.puxadorAlcaFrequencia / 4, Paint()..color = Cores.tintaMarcador);
    final pintor = TextPainter(text: TextSpan(text: texto, style: estilo), textDirection: TextDirection.ltr)..layout();
    final dx = aEsquerda ? x - Espacos.xs - pintor.width : x + Espacos.xs;
    pintor.paint(canvas, Offset(dx, Espacos.xxs));
    pintor.dispose();
  }

  @override
  bool shouldRepaint(PintorAlcaFrequencia antigo) => antigo.texto != texto || antigo.aEsquerda != aEsquerda;
}
