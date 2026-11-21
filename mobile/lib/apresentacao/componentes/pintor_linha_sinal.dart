// O caminho do sinal na cadeia, como num pedalboard: sai do jaque IN, passa
// pelos pedais na ordem e chega ao OUT. Depois do último pedal o fio segue
// tracejado até o OUT (o sinal passa, mas não há nada ali). A linha 2 só
// existe com split: desce em 45° no split e sobe no merge, como derivação.
// As caixas dos pedais e os encaixes vazios são opacos e cobrem o fio.
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
  });

  final double larguraCasa;
  final double vao;
  final double alturaLinha;

  /// Distância do topo da linha até o centro da arte.
  final double centroArte;

  /// Espaço antes da casa 1 e depois da 12, onde ficam os jaques IN e OUT.
  final double margem;

  double xDaCasa(int casa) => margem + (casa - 1) * (larguraCasa + vao) + larguraCasa / 2;
  double yDaLinha(int linha) => (linha - 1) * (alturaLinha + vao) + centroArte;
  double get larguraTotal => margem * 2 + PosicaoBloco.casasPorLinha * larguraCasa + (PosicaoBloco.casasPorLinha - 1) * vao;
}

class PintorLinhaSinal extends CustomPainter {
  const PintorLinhaSinal({required this.geometria, required this.ocupadas, this.casaSplit, this.casaMerge});

  final GeometriaGrade geometria;

  /// Casas ocupadas da linha 1, em ordem.
  final List<int> ocupadas;
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
    if (casaSplit != null) canvas.drawPath(_derivacao(saida), _fio);
    _jaque(canvas, Offset(entrada, y1), 'IN');
    _jaque(canvas, Offset(saida, y1), 'OUT');
  }

  void _tracejado(Canvas canvas, Offset de, Offset ate) {
    for (var x = de.dx; x < ate.dx; x += Medidas.tracoEncaixe * 2) {
      final fim = (x + Medidas.tracoEncaixe).clamp(x, ate.dx);
      canvas.drawLine(Offset(x, de.dy), Offset(fim, de.dy), _fioVazio);
    }
  }

  /// Do split desce à linha 2 e volta à linha 1 no merge (sem merge, no OUT).
  Path _derivacao(double saida) {
    final y1 = geometria.yDaLinha(1);
    final y2 = geometria.yDaLinha(2);
    final queda = y2 - y1;
    final inicio = geometria.xDaCasa(casaSplit!);
    final fim = casaMerge == null ? saida : geometria.xDaCasa(casaMerge!);
    return Path()
      ..moveTo(inicio, y1)
      ..lineTo(inicio + queda, y2)
      ..lineTo(fim - queda, y2)
      ..lineTo(fim, y1);
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
      antigo.geometria.larguraCasa != geometria.larguraCasa || !_mesmas(antigo.ocupadas, ocupadas);

  static bool _mesmas(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
