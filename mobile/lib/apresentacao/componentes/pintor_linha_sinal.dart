// O caminho do sinal na cadeia, como num pedalboard: sai do jaque IN, passa
// pelos pedais na ordem e chega ao OUT. Depois do último pedal o fio segue
// tracejado até o OUT (o sinal passa, mas não há nada ali). Com split, a
// derivação faz o que a pedaleira faz: o Split liga SEMPRE na casa 1 da
// linha 2, o sinal corre a linha 2 inteira e o Merge recebe SEMPRE da casa 12
// — a ida em amarelo, a volta em verde-água, como a fita do Split e a do
// Merge; na linha 2 o fio é o da cadeia (cheio até o último bloco, tracejado
// depois). Entre as linhas o fio corre num corredor e desce/sobe pelos vãos
// entre as casas, para não cruzar pedal nem nome. As caixas dos pedais e os
// encaixes vazios cobrem o fio.
import 'package:flutter/rendering.dart';

import '../../nucleo/modelo/bloco_preset.dart';
import '../tema/tokens.dart';

class GeometriaGrade {
  const GeometriaGrade({
    required this.larguraCasa,
    required this.vao,
    required this.alturaLinha,
    required this.centroArte,
    this.margem = Medidas.margemJaque,
    this.vaoEntreLinhas = Espacos.s,
  });

  final double larguraCasa;
  final double vao;
  final double alturaLinha;

  /// Distância do topo da linha até o centro da arte.
  final double centroArte;

  /// Espaço antes da casa 1 e depois da 12, onde ficam os jaques IN e OUT.
  final double margem;

  /// O espaço entre a linha 1 e a 2 na grade (não o vão entre as casas).
  final double vaoEntreLinhas;

  double xDaCasa(int casa) => margem + (casa - 1) * (larguraCasa + vao) + larguraCasa / 2;
  double yDaLinha(int linha) => (linha - 1) * (alturaLinha + vaoEntreLinhas) + centroArte;

  /// Meio do espaço entre as duas linhas: o corredor da derivação.
  double get yCorredor => alturaLinha + vaoEntreLinhas / 2;

  /// Os vãos à esquerda e à direita da casa, por onde o fio desce e sobe.
  double vaoAntes(int casa) => xDaCasa(casa) - larguraCasa / 2 - vao / 2;
  double vaoDepois(int casa) => xDaCasa(casa) + larguraCasa / 2 + vao / 2;
  double get larguraTotal => margem * 2 + PosicaoBloco.casasPorLinha * larguraCasa + (PosicaoBloco.casasPorLinha - 1) * vao;
}

class PintorLinhaSinal extends CustomPainter {
  const PintorLinhaSinal({
    required this.geometria,
    required this.ocupadas,
    this.ocupadas2 = const [],
    this.casaSplit,
    this.casaMerge,
  });

  final GeometriaGrade geometria;

  /// Casas ocupadas da linha 1 e da linha 2, em ordem.
  final List<int> ocupadas;
  final List<int> ocupadas2;
  final int? casaSplit;
  final int? casaMerge;

  static final _fio = Paint()
    ..color = Cores.aluminio
    ..style = PaintingStyle.stroke
    ..strokeWidth = Medidas.linhaSinal
    ..strokeJoin = StrokeJoin.round;

  static final _fioDoSplit = Paint()
    ..color = Cores.sinalSplit
    ..style = PaintingStyle.stroke
    ..strokeWidth = Medidas.linhaSinal
    ..strokeJoin = StrokeJoin.round;

  static final _fioDoMerge = Paint()
    ..color = Cores.sinalMerge
    ..style = PaintingStyle.stroke
    ..strokeWidth = Medidas.linhaSinal
    ..strokeJoin = StrokeJoin.round;

  static final _fioVazio = Paint()
    ..color = Cores.filete
    ..style = PaintingStyle.stroke
    ..strokeWidth = Medidas.linhaSinal;

  @override
  void paint(Canvas canvas, Size size) {
    final y1 = geometria.yDaLinha(1);
    final entrada = geometria.margem / 2;
    final saida = size.width - geometria.margem / 2;
    final fimDoSinal = ocupadas.isEmpty ? entrada : geometria.xDaCasa(ocupadas.last);
    canvas.drawLine(Offset(entrada, y1), Offset(fimDoSinal, y1), _fio);
    _tracejado(canvas, Offset(fimDoSinal, y1), Offset(saida, y1));
    if (casaSplit != null) _derivacao(canvas, saida);
    _jaque(canvas, Offset(entrada, y1), 'IN');
    _jaque(canvas, Offset(saida, y1), 'OUT');
  }

  void _derivacao(Canvas canvas, double saida) {
    final (ida, volta) = trechosDaDerivacao(geometria, casaSplit: casaSplit!, casaMerge: casaMerge, saida: saida);
    final inicio2 = ida.last;
    final fim2 = volta.first;
    final ultimo = ocupadas2.isEmpty ? inicio2.dx : geometria.xDaCasa(ocupadas2.last);
    canvas.drawLine(inicio2, Offset(ultimo, inicio2.dy), _fio);
    _tracejado(canvas, Offset(ultimo, inicio2.dy), fim2);
    canvas.drawPath(Path()..addPolygon(ida, false), _fioDoSplit);
    canvas.drawPath(Path()..addPolygon(volta, false), _fioDoMerge);
  }

  void _tracejado(Canvas canvas, Offset de, Offset ate) {
    for (var x = de.dx; x < ate.dx; x += Medidas.tracoEncaixe * 2) {
      final fim = (x + Medidas.tracoEncaixe).clamp(x, ate.dx);
      canvas.drawLine(Offset(x, de.dy), Offset(fim, de.dy), _fioVazio);
    }
  }

  /// O jaque: um anel no fim do fio e o rótulo acima.
  void _jaque(Canvas canvas, Offset centro, String rotulo) {
    canvas.drawCircle(centro, Medidas.raioJaque, Paint()..color = Cores.fundoCase);
    canvas.drawCircle(centro, Medidas.raioJaque, _fio);
    final texto = TextPainter(
      text: TextSpan(
        text: rotulo,
        style: const TextStyle(
            fontFamily: Fontes.rotulo, fontSize: Medidas.rotuloJaque, fontWeight: FontWeight.w700, color: Cores.aluminio),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    texto.paint(canvas, centro - Offset(texto.width / 2, Medidas.raioJaque + Espacos.xxs + texto.height));
    texto.dispose();
  }

  @override
  bool shouldRepaint(PintorLinhaSinal antigo) =>
      antigo.casaSplit != casaSplit || antigo.casaMerge != casaMerge ||
      antigo.geometria.larguraCasa != geometria.larguraCasa || !_mesmas(antigo.ocupadas, ocupadas) ||
      !_mesmas(antigo.ocupadas2, ocupadas2);

  static bool _mesmas(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// A derivação em dois trechos, como a pedaleira roteia: a ida sai do Split,
/// desce pelo vão à direita dele ao corredor entre as linhas, corre até antes
/// da casa 1 e entra na linha 2 por ela; a volta sai depois da casa 12, sobe
/// ao corredor e corre até o vão antes do Merge (sem Merge, o OUT), subindo
/// até ele. Entre os dois trechos fica a linha 2 inteira. Com o Merge colado
/// no Split os dois usam o mesmo vão; então cada fio se afasta para um lado
/// dele, para a ida e a volta não se sobreporem.
(List<Offset>, List<Offset>) trechosDaDerivacao(GeometriaGrade g,
    {required int casaSplit, int? casaMerge, required double saida}) {
  final y1 = g.yDaLinha(1);
  final y2 = g.yDaLinha(2);
  final corredor = g.yCorredor;
  final colados = casaMerge == casaSplit + 1;
  final afastamento = colados ? g.vao / 4 : 0.0;
  final descida = g.vaoDepois(casaSplit) - afastamento;
  final entrada2 = g.vaoAntes(1);
  final saida2 = g.vaoDepois(PosicaoBloco.casasPorLinha);
  final chegada = casaMerge == null ? saida : g.vaoAntes(casaMerge) + afastamento;
  final destino = casaMerge == null ? saida : g.xDaCasa(casaMerge);
  final ida = [
    Offset(g.xDaCasa(casaSplit), y1),
    Offset(descida, y1),
    Offset(descida, corredor),
    Offset(entrada2, corredor),
    Offset(entrada2, y2),
  ];
  final volta = [
    Offset(saida2, y2),
    Offset(saida2, corredor),
    Offset(chegada, corredor),
    Offset(chegada, y1),
    Offset(destino, y1),
  ];
  return (ida, volta);
}
