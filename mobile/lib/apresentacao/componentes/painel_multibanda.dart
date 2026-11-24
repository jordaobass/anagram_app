// Painel do Ignissor e do Entropia, como a Darkglass apresenta os blocos de
// 3 bandas: a faixa de frequência com os cortes em cima, uma coluna por banda
// embaixo e os níveis de saída à parte. Em tela estreita as bandas viram
// abas. Parâmetro que o arranjo não conhece (firmware novo) vai para
// "Outros", para nunca sumir.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../nucleo/catalogo/arranjo_multibanda.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../tema/tokens.dart';
import '../textos.dart';
import 'cartao_banda.dart';
import 'coluna_banda.dart';
import 'controle_no_painel.dart';
import 'botoes_banda.dart' show mutesDoArranjo;
import 'faixa_frequencias.dart';
import 'tela_pedaleira/barra_metal.dart';

class PainelMultibanda extends ConsumerStatefulWidget {
  const PainelMultibanda({
    super.key,
    required this.arranjo,
    required this.bloco,
    required this.definicao,
    required this.cena,
    required this.parametros,
  });

  final ArranjoMultibanda arranjo;
  final BlocoPreset bloco;
  final DefinicaoBloco definicao;
  final int cena;

  /// Os parâmetros que o painel genérico mostraria: os que o arranjo não
  /// usa vão para "Outros".
  final List<DefinicaoParametro> parametros;

  @override
  ConsumerState<PainelMultibanda> createState() => _EstadoPainelMultibanda();
}

class _EstadoPainelMultibanda extends ConsumerState<PainelMultibanda> {
  var _aba = BandaMultibanda.graves;

  num _valor(DefinicaoParametro p) => ControleNoPainel.valorNaCena(widget.bloco, p, widget.cena);

  Set<BandaMultibanda> get _mudas => {
        for (final b in widget.arranjo.bandas)
          if (widget.definicao.parametro(b.mudo) case final p? when DefinicaoParametro.estaLigado(_valor(p))) b.banda,
      };

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, restricoes) {
        final largura = restricoes.maxWidth;
        final lado = widget.arranjo.bandas.length;
        final cabem = largura >= lado * Medidas.larguraColunaBanda + (lado - 1) * Espacos.m;
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _topo(context),
          const SizedBox(height: Espacos.m),
          FaixaFrequencias(
            arranjo: widget.arranjo,
            parametro: widget.definicao.parametro,
            valor: _valor,
            mudas: _mudas,
            aoMudar: (p) => ControleNoPainel.alterar(ref, p, widget.bloco),
          ),
          const SizedBox(height: Espacos.l),
          if (cabem) _lado(largura) else ..._abas(context, largura),
          ..._globais(context),
          ..._outros(context),
        ]);
      });

  ColunaBanda _coluna(ArranjoBanda banda, double largura) => ColunaBanda(
      arranjo: banda,
      bloco: widget.bloco,
      definicao: widget.definicao,
      cena: widget.cena,
      largura: largura,
      mutes: mutesDoArranjo(widget.arranjo));

  /// A barra da tela da pedaleira: nome, Templates, a legenda das linhas da
  /// faixa (só as que o bloco tem: o Entropia não tem Threshold) e o
  /// liga/desliga.
  Widget _topo(BuildContext context) {
    final temLimiar = widget.arranjo.bandas.any((b) => b.limiar != null);
    return BarraPainelMetal(
      bloco: widget.bloco,
      definicao: widget.definicao,
      cena: widget.cena,
      legendas: [
        if (temLimiar) _legenda(context, 'Threshold', context.cores.linhaThreshold),
        _legenda(context, 'Level', context.cores.linhaLevel),
      ],
    );
  }

  Widget _legenda(BuildContext context, String texto, Color cor) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: Espacos.l, height: Medidas.tracoCurvaBanda, color: cor),
        const SizedBox(width: Espacos.xs),
        Text(texto.toUpperCase(), style: Theme.of(context).textTheme.labelSmall),
      ]);

  /// Três colunas do mesmo tamanho, lado a lado.
  Widget _lado(double largura) {
    final bandas = widget.arranjo.bandas;
    final cada = (largura - (bandas.length - 1) * Espacos.m) / bandas.length;
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        for (var i = 0; i < bandas.length; i++) ...[
          if (i > 0) const SizedBox(width: Espacos.m),
          _coluna(bandas[i], cada),
        ],
      ]),
    );
  }

  /// No celular: uma banda por vez, escolhida nas abas.
  List<Widget> _abas(BuildContext context, double largura) {
    final l = AppLocalizations.of(context);
    final atual = widget.arranjo.bandas.firstWhere((b) => b.banda == _aba, orElse: () => widget.arranjo.bandas.first);
    return [
      SegmentedButton<BandaMultibanda>(
        key: const ValueKey('abas-bandas'),
        showSelectedIcon: false,
        segments: [
          for (final b in widget.arranjo.bandas)
            ButtonSegment(value: b.banda, label: Text(l.mbNomeDaBanda(b.banda).toUpperCase())),
        ],
        selected: {atual.banda},
        onSelectionChanged: (escolha) => setState(() => _aba = escolha.single),
      ),
      const SizedBox(height: Espacos.m),
      _coluna(atual, largura),
    ];
  }

  List<Widget> _globais(BuildContext context) {
    final globais = [
      for (final g in widget.arranjo.globais)
        if (widget.definicao.parametro(g.simbolo) case final p?) (g, p),
    ];
    if (globais.isEmpty) return const [];
    final l = AppLocalizations.of(context);
    return [
      const SizedBox(height: Espacos.l),
      CartaoBanda(
        key: const ValueKey('mb-saida'),
        titulo: l.mbSaida,
        chave: null,
        ligada: true,
        controles: [
          for (final (g, p) in globais) _controleSolto(p, g.rotulo),
          if (widget.arranjo.temMisturaLimpa) _explicacao(context, l.mbExplicaMisturaLimpa),
        ],
      ),
    ];
  }

  Widget _explicacao(BuildContext context, String texto) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Medidas.larguraColunaBanda),
        child: Text(texto, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.cores.textoSecundario)),
      );

  List<Widget> _outros(BuildContext context) {
    final usados = widget.arranjo.simbolos;
    final resto = [for (final p in widget.parametros) if (!usados.contains(p.simbolo)) p];
    if (resto.isEmpty) return const [];
    return [
      const SizedBox(height: Espacos.l),
      CartaoBanda(
        key: const ValueKey('mb-outros'),
        titulo: AppLocalizations.of(context).mbOutros,
        chave: null,
        ligada: true,
        controles: [for (final p in resto) _controleSolto(p, null)],
      ),
    ];
  }

  Widget _controleSolto(DefinicaoParametro p, String? rotulo) => ControleNoPainel(
      parametro: p,
      rotulo: rotulo,
      bloco: widget.bloco,
      definicao: widget.definicao,
      cena: widget.cena,
      tamanho: Medidas.knobCompacto);
}
