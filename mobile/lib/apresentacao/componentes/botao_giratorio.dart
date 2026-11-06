// Knob grande: arraste (vertical ou horizontal), rodinha, setas do teclado;
// segurar volta ao padrão. Durante o arraste avisa "arrastando"; ao soltar,
// o valor final.
import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/catalogo/escala_parametro.dart';
import '../../nucleo/catalogo/formatador_valor.dart';
import '../tema/tokens.dart';
import 'pintor_knob.dart';

typedef AoMudarValor = void Function(num valor, {required bool arrastando});

class BotaoGiratorio extends StatefulWidget {
  const BotaoGiratorio({
    super.key,
    required this.parametro,
    required this.valor,
    required this.cor,
    required this.tamanho,
    required this.aoMudar,
  });

  final DefinicaoParametro parametro;
  final num valor;
  final Color cor;
  final double tamanho;
  final AoMudarValor aoMudar;

  @override
  State<BotaoGiratorio> createState() => _BotaoGiratorioState();
}

class _BotaoGiratorioState extends State<BotaoGiratorio> {
  static const _acaoPadrao = CustomSemanticsAction(label: 'Voltar ao padrão');
  final _foco = FocusNode();
  double? _fracaoArraste;

  double get _fracao => _fracaoArraste ?? widget.parametro.fracaoDe(widget.valor);

  @override
  void dispose() {
    _foco.dispose();
    super.dispose();
  }

  void _arrastar(DragUpdateDetails d) {
    final passo = (d.delta.dx - d.delta.dy) / Medidas.arrasteFaixaInteira;
    setState(() => _fracaoArraste = (_fracao + passo).clamp(0.0, 1.0));
    widget.aoMudar(widget.parametro.valorDe(_fracaoArraste!), arrastando: true);
  }

  void _soltar() {
    final fracao = _fracaoArraste;
    setState(() => _fracaoArraste = null);
    if (fracao != null) widget.aoMudar(widget.parametro.valorDe(fracao), arrastando: false);
  }

  /// Segurar volta ao padrão, com Desfazer (que também vai ao vivo).
  void _voltarAoPadrao() {
    final anterior = widget.valor;
    final aoMudar = widget.aoMudar;
    HapticFeedback.mediumImpact();
    aoMudar(widget.parametro.padrao, arrastando: false);
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
      content: Text('${widget.parametro.nome} voltou ao padrão.'),
      action: SnackBarAction(label: 'DESFAZER', onPressed: () => aoMudar(anterior, arrastando: false)),
    ));
  }

  void _rodinha(PointerSignalEvent evento) {
    if (evento is PointerScrollEvent) _passo(evento.scrollDelta.dy < 0 ? 0.01 : -0.01);
  }

  void _passo(double quanto) =>
      widget.aoMudar(widget.parametro.valorDe((_fracao + quanto).clamp(0.0, 1.0)), arrastando: false);

  KeyEventResult _tecla(FocusNode _, KeyEvent evento) {
    if (evento is! KeyDownEvent && evento is! KeyRepeatEvent) return KeyEventResult.ignored;
    final grande = HardwareKeyboard.instance.isShiftPressed ? 0.1 : 0.01;
    final teclas = {
      LogicalKeyboardKey.arrowUp: grande,
      LogicalKeyboardKey.arrowRight: grande,
      LogicalKeyboardKey.arrowDown: -grande,
      LogicalKeyboardKey.arrowLeft: -grande,
    };
    final quanto = teclas[evento.logicalKey];
    if (quanto == null) return KeyEventResult.ignored;
    _passo(quanto);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.parametro;
    final texto = FormatadorValor.formatar(p, p.valorDe(_fracao));
    return Semantics(
      slider: true,
      label: p.nome,
      value: texto,
      increasedValue: FormatadorValor.formatar(p, p.valorDe((_fracao + 0.01).clamp(0.0, 1.0))),
      decreasedValue: FormatadorValor.formatar(p, p.valorDe((_fracao - 0.01).clamp(0.0, 1.0))),
      onIncrease: () => _passo(0.01),
      onDecrease: () => _passo(-0.01),
      customSemanticsActions: {_acaoPadrao: _voltarAoPadrao},
      child: Focus(
        focusNode: _foco,
        onKeyEvent: _tecla,
        onFocusChange: (_) => setState(() {}),
        child: GestureDetector(
          onTap: _foco.requestFocus,
          // segurar (não toque duplo, fácil de dar sem querer) volta ao padrão
          onLongPress: _voltarAoPadrao,
          // arraste vertical vence o rolar da tela; horizontal também gira
          onVerticalDragUpdate: _arrastar,
          onVerticalDragEnd: (_) => _soltar(),
          onVerticalDragCancel: _soltar,
          onHorizontalDragUpdate: _arrastar,
          onHorizontalDragEnd: (_) => _soltar(),
          onHorizontalDragCancel: _soltar,
          child: Listener(onPointerSignal: _rodinha, child: _corpo(context, texto)),
        ),
      ),
    );
  }

  Widget _corpo(BuildContext context, String texto) {
    final tema = Theme.of(context).textTheme;
    return SizedBox(
      width: widget.tamanho + Espacos.l,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(widget.parametro.nome.toUpperCase(),
            maxLines: 1, overflow: TextOverflow.ellipsis, style: tema.labelMedium),
        const SizedBox(height: Espacos.xs),
        SizedBox.square(
          dimension: widget.tamanho,
          child: CustomPaint(painter: PintorKnob(fracao: _fracao, cor: widget.cor, focado: _foco.hasFocus)),
        ),
        Text(texto, maxLines: 1, style: tema.titleMedium?.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
      ]),
    );
  }
}
