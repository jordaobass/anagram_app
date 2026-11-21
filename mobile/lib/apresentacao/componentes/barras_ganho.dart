// As linhas da tela principal da pedaleira sobre a faixa de frequência: em
// cada banda, o Threshold (rosa) e o Level (verde) como traços horizontais na
// altura do valor em dB, de um corte ao outro. Arrastar para cima/baixo muda
// o valor ao vivo; tocar abre o campo para digitar; com o foco, as setas
// (Shift = passo grosso) e o leitor de tela andam um passo, como no knob.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../tema/tokens.dart';
import '../textos.dart';
import 'botao_giratorio.dart' show AoMudarValor;
import 'dialogo_valor.dart';
import 'passo_controle.dart';
import 'escalas_grafico.dart';

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
  const BarraGanho(
      {super.key,
      required this.traco,
      required this.valor,
      required this.alturaFaixa,
      required this.aoMudar,
      this.escala = const EscalaGanho()});

  final TracoGanho traco;
  final num valor;
  final double alturaFaixa;

  /// A mesma escala da faixa desenhada: o traço anda junto com o ponteiro.
  final EscalaGanho escala;
  final AoMudarValor aoMudar;

  @override
  State<BarraGanho> createState() => _EstadoBarraGanho();
}

class _EstadoBarraGanho extends State<BarraGanho> {
  final _foco = FocusNode();
  double? _arrastando;

  double get _db => _arrastando ?? widget.valor.toDouble();

  @override
  void dispose() {
    _foco.dispose();
    super.dispose();
  }

  void _arrastar(double dy) {
    final porPixel = widget.escala.faixaDb / widget.alturaFaixa;
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

  /// Seta, leitor de tela: o mesmo passo do knob (Shift = passo grosso).
  num _valorMais(double quanto) => widget.traco.parametro.valorDepoisDoPasso(widget.valor, quanto);

  void _passo(double quanto) => widget.aoMudar(_valorMais(quanto), arrastando: false);

  KeyEventResult _tecla(FocusNode _, KeyEvent evento) {
    if (evento is! KeyDownEvent && evento is! KeyRepeatEvent) return KeyEventResult.ignored;
    final passo = HardwareKeyboard.instance.isShiftPressed ? fracaoPassoGrosso : fracaoPassoFino;
    final sentido = switch (evento.logicalKey) {
      LogicalKeyboardKey.arrowUp => 1,
      LogicalKeyboardKey.arrowDown => -1,
      _ => 0,
    };
    if (sentido == 0) return KeyEventResult.ignored;
    _passo(passo * sentido);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = widget.traco.parametro;
    final texto = l.valorDe(p, _db);
    return Semantics(
      slider: true,
      label: widget.traco.rotulo,
      value: texto,
      increasedValue: l.valorDe(p, _valorMais(fracaoPassoFino)),
      decreasedValue: l.valorDe(p, _valorMais(-fracaoPassoFino)),
      onIncrease: () => _passo(fracaoPassoFino),
      onDecrease: () => _passo(-fracaoPassoFino),
      child: Focus(
        focusNode: _foco,
        onKeyEvent: _tecla,
        onFocusChange: (_) => setState(() {}),
        child: Tooltip(message: '${widget.traco.rotulo}: $texto', child: _gestos()),
      ),
    );
  }

  Widget _gestos() => MouseRegion(
        cursor: SystemMouseCursors.resizeRow,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragUpdate: (d) => _arrastar(d.delta.dy),
          onVerticalDragEnd: (_) => _soltar(),
          onVerticalDragCancel: _soltar,
          onTap: _digitar,
          child: CustomPaint(painter: _PintorTraco(widget.traco.cor, focado: _foco.hasFocus)),
        ),
      );
}

/// Topo do alvo de toque de um traço na faixa, centrado na altura do valor.
double topoDoTraco(num valorDb, double alturaFaixa, EscalaGanho escala) =>
    escala.altura(valorDb.toDouble()) * alturaFaixa - Medidas.alvoTracoGanho / 2;

class _PintorTraco extends CustomPainter {
  const _PintorTraco(this.cor, {required this.focado});
  final Color cor;

  /// Com o foco do teclado, o alvo inteiro ganha o realce de foco do app.
  final bool focado;

  @override
  void paint(Canvas canvas, Size size) {
    if (focado) canvas.drawRect(Offset.zero & size, Paint()..color = Cores.tally.withValues(alpha: Opacidades.foco));
    final y = size.height / 2;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), Paint()
      ..color = cor
      ..strokeWidth = Medidas.tracoCurvaBanda
      ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_PintorTraco antigo) => antigo.cor != cor || antigo.focado != focado;
}
