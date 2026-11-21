// Knob grande: arraste (vertical ou horizontal), rodinha, setas do teclado;
// segurar volta ao padrão; clicar no número embaixo dele abre o campo para
// digitar o valor. Durante o arraste avisa "arrastando"; ao soltar, o valor final.
import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/catalogo/escala_parametro.dart';
import '../tema/tokens.dart';
import 'dialogo_valor.dart';
import 'pintor_knob.dart';
import '../../l10n/app_localizations.dart';
import '../textos.dart';

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
    final l = AppLocalizations.of(context);
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
      content: Text(l.voltouAoPadrao(widget.parametro.nome)),
      action: SnackBarAction(label: l.desfazer, onPressed: () => aoMudar(anterior, arrastando: false)),
    ));
  }

  Future<void> _digitar() async {
    final valor = await digitarValor(context, widget.parametro, widget.valor);
    if (valor != null) widget.aoMudar(valor, arrastando: false);
  }

  /// Um passo da rodinha, da seta ou do leitor de tela: 1% do curso do knob.
  static const _passoFino = 0.01;

  /// Com Shift: 10% do curso, para atravessar a faixa sem segurar a tecla.
  static const _passoGrosso = 0.1;

  void _rodinha(PointerSignalEvent evento) {
    if (evento is PointerScrollEvent) _passo(evento.scrollDelta.dy < 0 ? _passoFino : -_passoFino);
  }

  double _fracaoMais(double quanto) => (_fracao + quanto).clamp(0.0, 1.0);

  void _passo(double quanto) => widget.aoMudar(widget.parametro.valorDe(_fracaoMais(quanto)), arrastando: false);

  KeyEventResult _tecla(FocusNode _, KeyEvent evento) {
    if (evento is! KeyDownEvent && evento is! KeyRepeatEvent) return KeyEventResult.ignored;
    final grande = HardwareKeyboard.instance.isShiftPressed ? _passoGrosso : _passoFino;
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
    final l = AppLocalizations.of(context);
    final texto = l.valorDe(p, p.valorDe(_fracao));
    return Semantics(
      slider: true,
      label: p.nome,
      value: texto,
      increasedValue: l.valorDe(p, p.valorDe(_fracaoMais(_passoFino))),
      decreasedValue: l.valorDe(p, p.valorDe(_fracaoMais(-_passoFino))),
      onIncrease: () => _passo(_passoFino),
      onDecrease: () => _passo(-_passoFino),
      customSemanticsActions: {CustomSemanticsAction(label: l.voltarAoPadrao): _voltarAoPadrao},
      child: Focus(
        focusNode: _foco,
        onKeyEvent: _tecla,
        onFocusChange: (_) => setState(() {}),
        child: _gestos(Listener(onPointerSignal: _rodinha, child: _corpo(context, texto))),
      ),
    );
  }

  Widget _gestos(Widget filho) => GestureDetector(
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
        child: filho,
      );

  /// O número é um alvo próprio: o toque nele não vira foco nem arraste do knob.
  Widget _valorClicavel(BuildContext context, String texto, TextTheme tema) => Tooltip(
        message: AppLocalizations.of(context).kbDigitarDica,
        child: MouseRegion(
          cursor: SystemMouseCursors.text,
          child: GestureDetector(
            key: ValueKey('valor-${widget.parametro.simbolo}'),
            behavior: HitTestBehavior.opaque,
            onTap: _digitar,
            child: Text(texto,
                maxLines: 1,
                style: tema.titleMedium?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                  decoration: TextDecoration.underline,
                  decorationStyle: TextDecorationStyle.dotted,
                  decorationColor: Cores.textoSecundario,
                )),
          ),
        ),
      );

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
        _valorClicavel(context, texto, tema),
      ]),
    );
  }
}
