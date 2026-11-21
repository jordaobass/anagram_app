// Os desenhos do painel do synth: a onda do oscilador, a curva do filtro com
// o pico da ressonância e o envelope. A geometria vem pronta do núcleo
// (desenho_sintetizador.dart); aqui só se escala para a caixa e se pinta.
import 'package:flutter/material.dart';

import '../../nucleo/catalogo/desenho_sintetizador.dart';
import '../tema/tokens.dart';

/// A caixa onde cada desenho mora: fundo do case, filete e a linha de centro.
class CaixaDesenho extends StatelessWidget {
  const CaixaDesenho({super.key, required this.pintor, this.largura});

  final CustomPainter pintor;
  final double? largura;

  @override
  Widget build(BuildContext context) => Container(
        width: largura,
        height: Medidas.alturaDesenhoSynth,
        decoration: BoxDecoration(
          color: Cores.fundoCase,
          borderRadius: BorderRadius.circular(Raios.controle),
          border: Border.all(color: Cores.filete),
        ),
        clipBehavior: Clip.antiAlias,
        child: CustomPaint(painter: pintor),
      );
}

Paint _traco(Color cor) => Paint()
  ..color = cor
  ..style = PaintingStyle.stroke
  ..strokeWidth = Medidas.tracoDesenhoSynth
  ..strokeJoin = StrokeJoin.round;

Paint _preenchimento(Color cor) => Paint()..color = cor.withValues(alpha: Medidas.opacidadePreenchimentoSynth);

final _guia = Paint()
  ..color = Cores.filete
  ..strokeWidth = Medidas.filete;

/// A onda escolhida, dois ciclos, em volta da linha de centro.
class PintorOnda extends CustomPainter {
  const PintorOnda({required this.forma, required this.cor});

  final FormaOnda forma;
  final Color cor;

  @override
  void paint(Canvas canvas, Size size) {
    final meio = size.height / 2;
    canvas.drawLine(Offset(0, meio), Offset(size.width, meio), _guia);
    final margem = Espacos.s;
    final amplitude = meio - margem;
    final pontos = [
      for (final (x, y) in pontosDaOnda(forma))
        Offset(margem + x * (size.width - margem * 2), meio - y * amplitude),
    ];
    canvas.drawPath(Path()..addPolygon(pontos, false), _traco(cor));
  }

  @override
  bool shouldRepaint(PintorOnda antigo) => antigo.forma != forma || antigo.cor != cor;
}

/// O passa-baixas: 0 dB no terço de cima, o pico da ressonância acima dele,
/// a queda depois do corte; preenchido por baixo como na tela de um synth.
class PintorFiltro extends CustomPainter {
  const PintorFiltro({required this.corte, required this.ressonancia, required this.cor});

  final num corte;
  final num ressonancia;
  final Color cor;

  /// De +24 dB (topo) a −36 dB (base): cabe o pico máximo e a queda.
  static const _topoDb = 24.0;
  static const _baseDb = -36.0;

  double _y(double db, Size size) => (_topoDb - db.clamp(_baseDb, _topoDb)) / (_topoDb - _baseDb) * size.height;

  @override
  void paint(Canvas canvas, Size size) {
    final zero = _y(0, size);
    canvas.drawLine(Offset(0, zero), Offset(size.width, zero), _guia);
    final pontos = [
      for (final (x, db) in respostaDoFiltro(corte: corte, ressonancia: ressonancia)) Offset(x * size.width, _y(db, size)),
    ];
    final area = Path()
      ..moveTo(0, size.height)
      ..addPolygon(pontos, false)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(area, _preenchimento(cor));
    canvas.drawPath(Path()..addPolygon(pontos, false), _traco(cor));
  }

  @override
  bool shouldRepaint(PintorFiltro antigo) =>
      antigo.corte != corte || antigo.ressonancia != ressonancia || antigo.cor != cor;
}

/// Attack, Decay, a nota segurada e o Release, do silêncio ao silêncio.
class PintorEnvelope extends CustomPainter {
  const PintorEnvelope({required this.ataque, required this.decaimento, required this.liberacao, required this.cor});

  final num ataque;
  final num decaimento;
  final num liberacao;
  final Color cor;

  @override
  void paint(Canvas canvas, Size size) {
    final margem = Espacos.s;
    final altura = size.height - margem * 2;
    final pontos = [
      for (final (x, y) in curvaDoEnvelope(ataque: ataque, decaimento: decaimento, liberacao: liberacao))
        Offset(margem + x * (size.width - margem * 2), margem + (1 - y) * altura),
    ];
    final base = margem + altura;
    canvas.drawLine(Offset(0, base), Offset(size.width, base), _guia);
    canvas.drawPath(Path()..addPolygon([...pontos, Offset(pontos.first.dx, base)], true), _preenchimento(cor));
    canvas.drawPath(Path()..addPolygon(pontos, false), _traco(cor));
  }

  @override
  bool shouldRepaint(PintorEnvelope antigo) =>
      antigo.ataque != ataque || antigo.decaimento != decaimento || antigo.liberacao != liberacao || antigo.cor != cor;
}
