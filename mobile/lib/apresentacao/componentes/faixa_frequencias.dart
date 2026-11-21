// Faixa de frequência do multibanda: 20 Hz a 20 kHz em escala log, a curva
// de resposta de cada banda (com a altura do Level dela) e uma alça em cada
// corte, na linha da banda que ele limita. Arrastar a alça move o corte (ao vivo, como o knob); tocar abre o
// campo para digitar. Banda mutada fica apagada na raia.
import 'dart:math';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../nucleo/catalogo/arranjo_multibanda.dart';
import '../../nucleo/catalogo/curvas_multibanda.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../tema/tokens.dart';
import '../textos.dart';
import 'barras_ganho.dart';
import 'botao_giratorio.dart' show AoMudarValor;
import 'dialogo_valor.dart';
import 'escalas_grafico.dart';
import 'pintor_faixa_frequencias.dart';

export '../../nucleo/catalogo/curvas_multibanda.dart' show fracaoDaFrequencia, frequenciaDaFracao, minimoFaixa, maximoFaixa;

/// O valor de um corte como a pedaleira escreve: passa-baixas no máximo
/// (20 kHz) não corta nada e aparece "OFF".
String textoDoCorte(AppLocalizations l, DefinicaoParametro p, num valor) =>
    p.nome.toLowerCase().contains('lo-pass') && valor >= p.maximo ? l.mbOff : l.valorDe(p, valor);

class FaixaFrequencias extends StatefulWidget {
  const FaixaFrequencias({
    super.key,
    required this.arranjo,
    required this.parametro,
    required this.valor,
    required this.mudas,
    required this.aoMudar,
  });

  final ArranjoMultibanda arranjo;
  final DefinicaoParametro? Function(String simbolo) parametro;
  final num Function(DefinicaoParametro parametro) valor;
  final Set<BandaMultibanda> mudas;
  final AoMudarValor Function(DefinicaoParametro parametro) aoMudar;

  @override
  State<FaixaFrequencias> createState() => _EstadoFaixaFrequencias();
}

class _EstadoFaixaFrequencias extends State<FaixaFrequencias> {
  /// Posição da alça durante o arraste (o valor do editor vem em seguida).
  final _arrastando = <String, double>{};

  double _fracao(String? simbolo, {required bool inferior}) {
    if (simbolo == null) return inferior ? 0 : 1;
    final p = widget.parametro(simbolo);
    if (p == null) return inferior ? 0 : 1;
    return _arrastando[simbolo] ?? fracaoDaFrequencia(widget.valor(p));
  }

  /// O corte em Hz (o da alça durante o arraste); nulo é a borda do áudio.
  double? _corte(String? simbolo) {
    final p = simbolo == null ? null : widget.parametro(simbolo);
    if (p == null) return null;
    return frequenciaDaFracao(_fracao(simbolo, inferior: true)).toDouble();
  }

  double _nivel(String? simbolo) {
    final p = simbolo == null ? null : widget.parametro(simbolo);
    return p == null ? 0 : widget.valor(p).toDouble();
  }

  List<RaiaBanda> get _raias => [
        for (final b in widget.arranjo.bandas)
          RaiaBanda(
            cor: Cores.daBanda(b.banda, b.paleta),
            inferior: _corte(b.inferior),
            superior: _corte(b.superior),
            nivelDb: _nivel(b.nivel),
            muda: widget.mudas.contains(b.banda),
          ),
      ];

  /// Os parâmetros dos traços (Threshold e Level de cada banda).
  Iterable<DefinicaoParametro> get _parametrosDosTracos => [
        for (final b in widget.arranjo.bandas)
          for (final simbolo in [b.limiar, b.nivel])
            if (simbolo != null) ?widget.parametro(simbolo),
      ];

  @override
  Widget build(BuildContext context) {
    final escala = EscalaGanho.paraCobrir(_parametrosDosTracos);
    final altura = widget.arranjo.bandas.length * Medidas.alturaRaiaBanda + Medidas.alturaReguaFrequencias;
    return LayoutBuilder(builder: (context, restricoes) {
      final largura = restricoes.maxWidth;
      return SizedBox(
        key: const ValueKey('faixa-frequencias'),
        height: altura,
        child: Stack(clipBehavior: Clip.none, children: [
          Positioned.fill(
            child: CustomPaint(
                painter: PintorFaixaFrequencias(
                    raias: _raias, rotulos: _rotulosDaRegua(), alturaRaia: Medidas.alturaRaiaBanda, escala: escala)),
          ),
          ..._tracos(largura, escala),
          for (final MapEntry(key: simbolo, value: bandas) in widget.arranjo.alcas.entries)
            if (widget.parametro(simbolo) case final p?) _alca(context, p, bandas, largura),
        ]),
      );
    });
  }

  /// Threshold e Level de cada banda, de um corte ao outro (banda com corte
  /// invertido não tem largura e fica sem traço).
  List<Widget> _tracos(double largura, EscalaGanho escala) {
    final altura = widget.arranjo.bandas.length * Medidas.alturaRaiaBanda;
    return [
      for (final b in widget.arranjo.bandas)
        for (final (simbolo, cor) in [(b.limiar, Cores.linhaThreshold), (b.nivel, Cores.linhaLevel)])
          if (simbolo != null && widget.parametro(simbolo) != null)
            if (_traco(b, widget.parametro(simbolo)!, cor) case final t when t.ate > t.de)
              Positioned(
                left: t.de * largura,
                width: (t.ate - t.de) * largura,
                top: topoDoTraco(widget.valor(t.parametro), altura, escala),
                height: Medidas.alvoTracoGanho,
                child: BarraGanho(
                  key: ValueKey('traco-${t.parametro.simbolo}'),
                  traco: t,
                  valor: widget.valor(t.parametro),
                  alturaFaixa: altura,
                  escala: escala,
                  aoMudar: widget.aoMudar(t.parametro),
                ),
              ),
    ];
  }

  TracoGanho _traco(ArranjoBanda b, DefinicaoParametro p, Color cor) => TracoGanho(
      parametro: p,
      cor: cor,
      de: _fracao(b.inferior, inferior: true),
      ate: _fracao(b.superior, inferior: false),
      rotulo: p.nome);

  /// Perto do fim da faixa o valor da alça vai para a esquerda do traço.
  static const _rotuloVira = 0.8;

  Map<double, String> _rotulosDaRegua() => {
        for (final hz in marcasDeFrequencia) fracaoDaFrequencia(hz): rotuloDaFrequencia(hz),
      };

  Widget _alca(BuildContext context, DefinicaoParametro p, List<BandaMultibanda> bandas, double largura) {
    final linhas = [for (final b in bandas) widget.arranjo.bandas.indexWhere((a) => a.banda == b)];
    final topo = linhas.reduce(min) * Medidas.alturaRaiaBanda;
    final altura = (linhas.reduce(max) - linhas.reduce(min) + 1) * Medidas.alturaRaiaBanda;
    final total = widget.arranjo.bandas.length * Medidas.alturaRaiaBanda;
    final fracao = _fracao(p.simbolo, inferior: true);
    final valor = widget.valor(p);
    return Positioned(
      left: fracao * largura - Medidas.larguraAlcaFrequencia / 2,
      top: topo,
      width: Medidas.larguraAlcaFrequencia,
      height: altura,
      child: AlcaFrequencia(
        key: ValueKey('alca-${p.simbolo}'),
        parametro: p,
        texto: textoDoCorte(AppLocalizations.of(context), p, _arrastando.containsKey(p.simbolo) ? _valorDaFracao(p, fracao) : valor),
        aoArrastar: (dx) => _arrastar(p, dx / largura),
        aoSoltar: () => _soltar(p),
        aoTocar: () => _digitar(context, p, valor),
        aoPassar: (passo) => widget.aoMudar(p)(_valorDaFracao(p, fracao + passo), arrastando: false),
        textoDoPasso: (passo) => AppLocalizations.of(context).valorDe(p, _valorDaFracao(p, fracao + passo)),
        rotuloAEsquerda: fracao > _rotuloVira,
        acima: topo,
        abaixo: total - topo - altura,
      ),
    );
  }

  /// O corte segue o dedo, mas fica na faixa que a pedaleira aceita.
  num _valorDaFracao(DefinicaoParametro p, double fracao) => p.limitar(frequenciaDaFracao(fracao));

  void _arrastar(DefinicaoParametro p, double passo) {
    // no limite do parâmetro a alça para, em vez de se afastar do valor
    final nova = (_fracao(p.simbolo, inferior: true) + passo)
        .clamp(fracaoDaFrequencia(p.minimo), fracaoDaFrequencia(p.maximo));
    setState(() => _arrastando[p.simbolo] = nova);
    widget.aoMudar(p)(_valorDaFracao(p, nova), arrastando: true);
  }

  void _soltar(DefinicaoParametro p) {
    final fracao = _arrastando[p.simbolo];
    setState(() => _arrastando.remove(p.simbolo));
    if (fracao != null) widget.aoMudar(p)(_valorDaFracao(p, fracao), arrastando: false);
  }

  Future<void> _digitar(BuildContext context, DefinicaoParametro p, num atual) async {
    final valor = await digitarValor(context, p, atual);
    if (valor != null) widget.aoMudar(p)(valor, arrastando: false);
  }
}

/// A alça de um corte: o traço da frequência com um puxador, o valor escrito
/// ao lado e o alvo de toque mais largo que o traço.
class AlcaFrequencia extends StatelessWidget {
  const AlcaFrequencia({
    super.key,
    required this.parametro,
    required this.texto,
    required this.aoArrastar,
    required this.aoSoltar,
    required this.aoTocar,
    required this.aoPassar,
    required this.textoDoPasso,
    this.rotuloAEsquerda = false,
    this.acima = 0,
    this.abaixo = 0,
  });

  final DefinicaoParametro parametro;
  final String texto;
  final ValueChanged<double> aoArrastar;
  final VoidCallback aoSoltar;
  final VoidCallback aoTocar;

  /// Passo do leitor de tela, em fração da faixa, e o valor que ele daria.
  final ValueChanged<double> aoPassar;
  final String Function(double passo) textoDoPasso;

  /// Perto do fim da faixa o valor vai para a esquerda do traço.
  final bool rotuloAEsquerda;

  /// Quanto o traço passa do alvo, para cortar as curvas da faixa inteira.
  final double acima;
  final double abaixo;

  static const _passo = 0.01;

  @override
  Widget build(BuildContext context) => Semantics(
        slider: true,
        label: parametro.nome,
        value: texto,
        increasedValue: textoDoPasso(_passo),
        decreasedValue: textoDoPasso(-_passo),
        onIncrease: () => aoPassar(_passo),
        onDecrease: () => aoPassar(-_passo),
        child: Tooltip(
          message: '${parametro.nome}: $texto',
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: (d) => aoArrastar(d.delta.dx),
              onHorizontalDragEnd: (_) => aoSoltar(),
              onHorizontalDragCancel: aoSoltar,
              onTap: aoTocar,
              child: CustomPaint(painter: PintorAlcaFrequencia(
                  texto: texto, estilo: _estilo(context), aEsquerda: rotuloAEsquerda, acima: acima, abaixo: abaixo)),
            ),
          ),
        ),
      );

  TextStyle? _estilo(BuildContext context) => Theme.of(context).textTheme.labelSmall?.copyWith(
      color: Cores.texto, fontFeatures: const [FontFeature.tabularFigures()]);
}
