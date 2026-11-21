// As linhas da tela principal da pedaleira sobre a faixa de frequência: em
// cada banda, o Threshold (rosa) e o Level (verde) como traços horizontais na
// altura do valor em dB, de um corte ao outro. Arrastar para cima/baixo muda
// o valor ao vivo; tocar abre o campo para digitar.
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../tema/tokens.dart';
import '../textos.dart';
import 'botao_giratorio.dart' show AoMudarValor;
import 'dialogo_valor.dart';
import 'pintor_faixa_frequencias.dart' show alturaDoGanho, topoCurvaDb, baseCurvaDb;

/// Um traço: o parâmetro, a cor e de onde até onde vai (fração da faixa).
class TracoGanho {
  const TracoGanho({required this.parametro, required this.cor, required this.de, required this.ate, required this.rotulo});
  final DefinicaoParametro parametro;
  final Color cor;
  final double de;
  final double ate;

  /// "Low Threshold", "Mid Level": como a pedaleira escreve no topo.
  final String rotulo;
}

class BarraGanho extends StatefulWidget {
  const BarraGanho({super.key, required this.traco, required this.valor, required this.alturaFaixa, required this.aoMudar});

  final TracoGanho traco;
  final num valor;
  final double alturaFaixa;
  final AoMudarValor aoMudar;

  @override
  State<BarraGanho> createState() => _EstadoBarraGanho();
}

class _EstadoBarraGanho extends State<BarraGanho> {
  double? _arrastando;

  double get _db => _arrastando ?? widget.valor.toDouble();

  void _arrastar(double dy) {
    final porPixel = (topoCurvaDb - baseCurvaDb) / widget.alturaFaixa;
    final novo = widget.traco.parametro.limitar(_db - dy * porPixel).toDouble();
    setState(() => _arrastando = novo);
    widget.aoMudar(novo, arrastando: true);
  }

  void _soltar() {
    final valor = _arrastando;
    setState(() => _arrastando = null);
    if (valor != null) widget.aoMudar(valor, arrastando: false);
  }

  Future<void> _digitar() async {
    final valor = await digitarValor(context, widget.traco.parametro, widget.valor);
    if (valor != null) widget.aoMudar(valor, arrastando: false);
  }

  @override
  Widget build(BuildContext context) {
    final texto = AppLocalizations.of(context).valorDe(widget.traco.parametro, _db);
    return Semantics(
      slider: true,
      label: widget.traco.rotulo,
      value: texto,
      child: Tooltip(
        message: '${widget.traco.rotulo}: $texto',
        child: MouseRegion(
          cursor: SystemMouseCursors.resizeRow,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragUpdate: (d) => _arrastar(d.delta.dy),
            onVerticalDragEnd: (_) => _soltar(),
            onVerticalDragCancel: _soltar,
            onTap: _digitar,
            child: CustomPaint(painter: _PintorTraco(widget.traco.cor)),
          ),
        ),
      ),
    );
  }
}

/// Topo do alvo de toque de um traço na faixa, centrado na altura do valor.
double topoDoTraco(num valorDb, double alturaFaixa) =>
    alturaDoGanho(valorDb.toDouble()) * alturaFaixa - Medidas.alvoTracoGanho / 2;

class _PintorTraco extends CustomPainter {
  const _PintorTraco(this.cor);
  final Color cor;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), Paint()
      ..color = cor
      ..strokeWidth = Medidas.tracoCurvaBanda
      ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_PintorTraco antigo) => antigo.cor != cor;
}
