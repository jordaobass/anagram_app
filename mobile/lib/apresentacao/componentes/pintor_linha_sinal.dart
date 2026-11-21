// O caminho do sinal na cadeia, como num pedalboard: sai do jaque IN, passa
// pelos pedais na ordem e chega ao OUT. Depois do último pedal o fio segue
// tracejado até o OUT (o sinal passa, mas não há nada ali). Com split, a
// derivação faz o que a pedaleira faz: o Split manda o sinal para o COMEÇO da
// linha 2 (a primeira casa ocupada dela, em qualquer coluna), o sinal passa
// pelos blocos da linha 2 e o fim dela volta no Merge. Entre as linhas o fio
// corre num corredor e desce/sobe pelos vãos entre as casas, para não cruzar
// pedal nem nome. As caixas dos pedais e os encaixes vazios cobrem o fio.
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
    if (casaSplit != null) {
      final pontos = pontosDaDerivacao(geometria,
          casaSplit: casaSplit!, casaMerge: casaMerge, ocupadas2: ocupadas2, saida: saida);
      canvas.drawPath(Path()..addPolygon(pontos, false), _fio);
    }
    _jaque(canvas, Offset(entrada, y1), 'IN');
    _jaque(canvas, Offset(saida, y1), 'OUT');
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

/// O caminho da derivação: do Split, pelo vão à direita dele, desce ao
/// corredor entre as linhas; vai até o vão antes do PRIMEIRO bloco da linha 2,
/// desce, atravessa os blocos dela até o ÚLTIMO, sobe pelo vão depois dele e
/// volta pelo corredor até o vão antes do Merge (sem Merge, o OUT), subindo
/// até ele. Sem bloco na linha 2, vai direto pelo corredor.
List<Offset> pontosDaDerivacao(GeometriaGrade g,
    {required int casaSplit, int? casaMerge, required List<int> ocupadas2, required double saida}) {
  final y1 = g.yDaLinha(1);
  final y2 = g.yDaLinha(2);
  final corredor = g.yCorredor;
  final descida = g.vaoDepois(casaSplit);
  final chegada = casaMerge == null ? saida : g.vaoAntes(casaMerge);
  final destino = casaMerge == null ? saida : g.xDaCasa(casaMerge);
  final pontos = [Offset(g.xDaCasa(casaSplit), y1), Offset(descida, y1), Offset(descida, corredor)];
  if (ocupadas2.isNotEmpty) {
    final primeiro = ocupadas2.reduce((a, b) => a < b ? a : b);
    final ultimo = ocupadas2.reduce((a, b) => a > b ? a : b);
    pontos.addAll([
      Offset(g.vaoAntes(primeiro), corredor),
      Offset(g.vaoAntes(primeiro), y2),
      Offset(g.xDaCasa(ultimo), y2),
      Offset(g.vaoDepois(ultimo), y2),
      Offset(g.vaoDepois(ultimo), corredor),
    ]);
  }
  pontos.addAll([Offset(chegada, corredor), Offset(chegada, y1), Offset(destino, y1)]);
  return pontos;
}

