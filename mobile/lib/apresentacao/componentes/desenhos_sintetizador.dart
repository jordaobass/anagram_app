// Os desenhos do painel do synth: a onda do oscilador, a curva do filtro com
// o pico da ressonância e o envelope. A geometria vem pronta do núcleo
// (desenho_sintetizador.dart); aqui só se escala para a caixa e se pinta.
import 'package:flutter/material.dart';

import '../../nucleo/catalogo/desenho_sintetizador.dart';
import '../tema/tema_painel.dart';
import '../tema/tokens.dart';
import 'tela_pedaleira/neon.dart';

/// A caixa onde cada desenho mora: fundo do case, filete e a linha de centro.
class CaixaDesenho extends StatelessWidget {
  const CaixaDesenho({super.key, required this.pintor, this.largura, this.altura = Medidas.alturaDesenhoSynth});

  final CustomPainter pintor;
  final double? largura;

  /// No neon a onda do oscilador é a tela do módulo, maior que a do case.
  final double altura;

  @override
  Widget build(BuildContext context) => Container(
        width: largura,
        height: altura,
        decoration: decoracaoCartao(context, cor: context.cores.fundoCase, raio: Raios.controle),
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

/// O traço da curva: chapado no case; tubo de neon com halo no Axioma.
void _curva(Canvas canvas, Path caminho, Color cor, double brilho) => brilho > 0
    ? tracoNeon(canvas, caminho, cor, largura: Medidas.tracoDesenhoSynth * 1.25, brilho: brilho)
    : canvas.drawPath(caminho, _traco(cor));

Paint _guia(Paleta cores) => Paint()
  ..color = cores.filete
  ..strokeWidth = Medidas.filete;

/// A onda escolhida, dois ciclos, em volta da linha de centro.
class PintorOnda extends CustomPainter {
  const PintorOnda({required this.cores, required this.forma, required this.cor, this.brilho = 0});

  final Paleta cores;

  final FormaOnda forma;
  final Color cor;

  /// 0 = traço chapado (case); acima disso, o halo do neon.
  final double brilho;

  @override
  void paint(Canvas canvas, Size size) {
    final meio = size.height / 2;
    canvas.drawLine(Offset(0, meio), Offset(size.width, meio), _guia(cores));
    final margem = Espacos.s;
    final amplitude = meio - margem;
    final pontos = [
      for (final (x, y) in pontosDaOnda(forma))
        Offset(margem + x * (size.width - margem * 2), meio - y * amplitude),
    ];
    _curva(canvas, Path()..addPolygon(pontos, false), cor, brilho);
  }

  @override
  bool shouldRepaint(PintorOnda antigo) =>
      antigo.cores != cores || antigo.forma != forma || antigo.cor != cor || antigo.brilho != brilho;
}

/// O passa-baixas: 0 dB no terço de cima, o pico da ressonância acima dele,
/// a queda depois do corte; preenchido por baixo como na tela de um synth.
class PintorFiltro extends CustomPainter {
  const PintorFiltro({required this.cores, required this.corte, required this.ressonancia, required this.cor, this.brilho = 0});

  final Paleta cores;

  final num corte;
  final num ressonancia;
  final Color cor;
  final double brilho;

  /// De +24 dB (topo) a −36 dB (base): cabe o pico máximo e a queda.
  static const _topoDb = 24.0;
  static const _baseDb = -36.0;

  double _y(double db, Size size) => (_topoDb - db.clamp(_baseDb, _topoDb)) / (_topoDb - _baseDb) * size.height;

  @override
  void paint(Canvas canvas, Size size) {
    final zero = _y(0, size);
    canvas.drawLine(Offset(0, zero), Offset(size.width, zero), _guia(cores));
    final pontos = [
      for (final (x, db) in respostaDoFiltro(corte: corte, ressonancia: ressonancia)) Offset(x * size.width, _y(db, size)),
    ];
    final area = Path()
      ..moveTo(0, size.height)
      ..addPolygon(pontos, false)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(area, _preenchimento(cor));
    _curva(canvas, Path()..addPolygon(pontos, false), cor, brilho);
  }

  @override
  bool shouldRepaint(PintorFiltro antigo) =>
      antigo.cores != cores || antigo.corte != corte || antigo.ressonancia != ressonancia || antigo.cor != cor ||
      antigo.brilho != brilho;
}

/// Attack, Decay, a nota segurada e o Release, do silêncio ao silêncio.
class PintorEnvelope extends CustomPainter {
  const PintorEnvelope(
      {required this.cores, required this.ataque, required this.decaimento, required this.liberacao, required this.cor, this.brilho = 0});

  final Paleta cores;

  final num ataque;
  final num decaimento;
  final num liberacao;
  final Color cor;
  final double brilho;

  @override
  void paint(Canvas canvas, Size size) {
    final margem = Espacos.s;
    final altura = size.height - margem * 2;
    final pontos = [
      for (final (x, y) in curvaDoEnvelope(ataque: ataque, decaimento: decaimento, liberacao: liberacao))
        Offset(margem + x * (size.width - margem * 2), margem + (1 - y) * altura),
    ];
    final base = margem + altura;
    canvas.drawLine(Offset(0, base), Offset(size.width, base), _guia(cores));
    canvas.drawPath(Path()..addPolygon([...pontos, Offset(pontos.first.dx, base)], true), _preenchimento(cor));
    _curva(canvas, Path()..addPolygon(pontos, false), cor, brilho);
  }

  @override
  bool shouldRepaint(PintorEnvelope antigo) =>
      antigo.cores != cores || antigo.ataque != ataque || antigo.decaimento != decaimento || antigo.liberacao != liberacao ||
      antigo.cor != cor || antigo.brilho != brilho;
}

/// A tela do módulo sem desenho (o Sub, que não tem forma de onda no
/// catálogo): só a linha de centro, como a tela apagada da pedaleira.
class PintorTelaVazia extends CustomPainter {
  const PintorTelaVazia({required this.cores});

  final Paleta cores;

  @override
  void paint(Canvas canvas, Size size) =>
      canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), _guia(cores));

  @override
  bool shouldRepaint(PintorTelaVazia antigo) => antigo.cores != cores;
}
