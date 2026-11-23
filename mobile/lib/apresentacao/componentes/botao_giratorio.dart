// Knob grande: arraste (vertical ou horizontal), rodinha, setas do teclado;
// segurar volta ao padrão; clicar no número embaixo dele abre o campo para
// digitar o valor. Durante o arraste avisa "arrastando"; ao soltar, o valor final.
// Sem [BotaoGiratorio.aoMudar] é só leitura: desenha o valor e nada o mexe.
import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../nucleo/catalogo/arranjo_parametros.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/catalogo/escala_parametro.dart';
import '../tema/tokens.dart';
import 'dialogo_valor.dart';
import 'explicacao_parametro.dart';
import 'pintor_fader.dart';
import 'passo_controle.dart';
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
    this.aoMudar,
    this.rotulo,
    this.forma = FormaControle.knob,
    this.corChipValor,
  });

  final DefinicaoParametro parametro;

  /// Nome mostrado em cima, quando o grupo já diz o resto ("Gain" na banda 1);
  /// o aviso de voltar ao padrão continua com o nome inteiro.
  final String? rotulo;
  final FormaControle forma;

  /// O valor num chip dessa cor (o Global EQ, como na tela da pedaleira);
  /// nulo = o número sublinhado de sempre.
  final Color? corChipValor;
  final num valor;
  final Color cor;
  final double tamanho;

  /// Nulo = só leitura (os ajustes globais que a pedaleira não aplica ao som).
  final AoMudarValor? aoMudar;

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

  /// Só chamado nos gestos do controle editável.
  void _mudar(num valor, {required bool arrastando}) => widget.aoMudar!(valor, arrastando: arrastando);

  void _arrastar(DragUpdateDetails d) {
    final passo = (d.delta.dx - d.delta.dy) / Medidas.arrasteFaixaInteira;
    setState(() => _fracaoArraste = (_fracao + passo).clamp(0.0, 1.0));
    _mudar(widget.parametro.valorDe(_fracaoArraste!), arrastando: true);
  }

  void _soltar() {
    final fracao = _fracaoArraste;
    setState(() => _fracaoArraste = null);
    if (fracao != null) _mudar(widget.parametro.valorDe(fracao), arrastando: false);
  }

  /// Segurar volta ao padrão, com Desfazer (que também vai ao vivo).
  void _voltarAoPadrao() {
    final anterior = widget.valor;
    final aoMudar = widget.aoMudar!;
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
    if (valor != null) _mudar(valor, arrastando: false);
  }

  void _rodinha(PointerSignalEvent evento) {
    if (evento is PointerScrollEvent) _passo(evento.scrollDelta.dy < 0 ? fracaoPassoFino : -fracaoPassoFino);
  }

  /// O valor depois de um passo: nos discretos, sempre ao menos uma posição.
  num _valorMais(double quanto) => widget.parametro.valorDepoisDoPasso(widget.parametro.valorDe(_fracao), quanto);

  void _passo(double quanto) => _mudar(_valorMais(quanto), arrastando: false);

  KeyEventResult _tecla(FocusNode _, KeyEvent evento) {
    if (evento is! KeyDownEvent && evento is! KeyRepeatEvent) return KeyEventResult.ignored;
    final grande = HardwareKeyboard.instance.isShiftPressed ? fracaoPassoGrosso : fracaoPassoFino;
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
    if (widget.aoMudar == null) {
      return Semantics(
        readOnly: true,
        label: p.nome,
        value: texto,
        child: ExcludeSemantics(child: _corpo(context, texto)),
      );
    }
    return Semantics(
      slider: true,
      label: p.nome,
      value: texto,
      hint: ContextoExplicacao.de(context, p),
      increasedValue: l.valorDe(p, _valorMais(fracaoPassoFino)),
      decreasedValue: l.valorDe(p, _valorMais(-fracaoPassoFino)),
      onIncrease: () => _passo(fracaoPassoFino),
      onDecrease: () => _passo(-fracaoPassoFino),
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
            child: _valor(texto, tema),
          ),
        ),
      );

  Widget _valor(String texto, TextTheme tema) =>
      widget.corChipValor == null ? _numero(texto, tema) : _chip(texto, tema, widget.corChipValor!);

  /// Sublinhado pontilhado só quando tocar nele abre o campo de digitar.
  Widget _numero(String texto, TextTheme tema) => Text(texto,
      maxLines: 1,
      style: tema.titleMedium?.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
        decoration: widget.aoMudar == null ? null : TextDecoration.underline,
        decorationStyle: TextDecorationStyle.dotted,
        decorationColor: context.cores.textoSecundario,
      ));

  Widget _chip(String texto, TextTheme tema, Color cor) => Container(
        padding: const EdgeInsets.symmetric(horizontal: Espacos.s, vertical: Espacos.xxs),
        decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(Raios.controle)),
        child: Text(texto,
            maxLines: 1,
            style: tema.labelLarge?.copyWith(
                color: context.cores.textoSobreModoEq, fontFeatures: const [FontFeature.tabularFigures()])),
      );

  Widget _desenho() {
    final origem = widget.parametro.fracaoDaOrigem;
    if (widget.forma == FormaControle.fader) {
      return SizedBox(
        width: Medidas.larguraFader,
        height: widget.tamanho * Medidas.alturaFaderPorKnob,
        child: CustomPaint(
            painter: PintorFader(cores: context.cores, fracao: _fracao, origem: origem, cor: widget.cor, focado: _foco.hasFocus)),
      );
    }
    return SizedBox.square(
      dimension: widget.tamanho,
      child: CustomPaint(painter: PintorKnob(cores: context.cores, fracao: _fracao, origem: origem, cor: widget.cor, focado: _foco.hasFocus)),
    );
  }

  /// O fader é estreito: a coluna só alarga para o número caber.
  double get _largura => widget.forma == FormaControle.fader ? Medidas.larguraFader + Espacos.l : widget.tamanho + Espacos.l;

  Widget _corpo(BuildContext context, String texto) {
    final tema = Theme.of(context).textTheme;
    return SizedBox(
      width: _largura,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        RotuloParametro(parametro: widget.parametro, texto: widget.rotulo ?? widget.parametro.nome),
        const SizedBox(height: Espacos.xs),
        _desenho(),
        if (widget.aoMudar == null)
          KeyedSubtree(key: ValueKey('valor-${widget.parametro.simbolo}'), child: _valor(texto, tema))
        else
          _valorClicavel(context, texto, tema),
      ]),
    );
  }
}
