// Painel da bateria (Auto Drummer) e do metrônomo (Cognate Metro) como a tela
// da Anagram: um cartão por controle, lado a lado numa fileira, na ordem do
// visor, com o visual do app. A página 2 do metrônomo vira a fileira de baixo
// (Treino). Sem espaço, a fileira quebra. Parâmetro que o arranjo não conhece
// (firmware novo) cai em "Outros".
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../nucleo/catalogo/arranjo_utilitario.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../tema/tokens.dart';
import 'cartao_secao_synth.dart';
import 'controle_no_painel.dart';
import 'controles_utilitario.dart';

class PainelUtilitario extends StatelessWidget {
  const PainelUtilitario({
    super.key,
    required this.arranjo,
    required this.bloco,
    required this.definicao,
    required this.cena,
    required this.parametros,
    required this.tamanhoKnob,
  });

  final ArranjoUtilitario arranjo;
  final BlocoPreset bloco;
  final DefinicaoBloco definicao;
  final int cena;
  final double tamanhoKnob;

  /// Os parâmetros que o painel genérico mostraria.
  final List<DefinicaoParametro> parametros;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, restricoes) {
        final controles = _ControlesDoBloco(bloco: bloco, definicao: definicao, cena: cena, tamanhoKnob: tamanhoKnob);
        final largura = _larguraDoCartao(restricoes.maxWidth);
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (final s in arranjo.secoes) ...[_fileira(context, controles, s, largura), const SizedBox(height: Espacos.m)],
          ..._outros(context, controles),
        ]);
      });

  /// No celular, dois cartões por fileira em vez de um sobrando espaço.
  static double _larguraDoCartao(double disponivel) =>
      math.min(Medidas.larguraCartaoUtilitario, math.max(Medidas.larguraMinimaCartaoUtilitario, (disponivel - Espacos.s) / 2));

  /// Uma página do visor: os cartões lado a lado; o Treino leva o título.
  Widget _fileira(BuildContext context, _ControlesDoBloco controles, SecaoUtil secao, double largura) {
    final l = AppLocalizations.of(context);
    return Column(key: ValueKey('ut-${secao.secao.name}'), crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (secao.secao == SecaoUtilitario.treino) ...[
        Text(l.utTreino.toUpperCase(), style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: Espacos.s),
      ],
      Wrap(alignment: WrapAlignment.center, spacing: Espacos.s, runSpacing: Espacos.s, children: [
        for (final c in secao.controles)
          if (controles.de(c) case final controle?)
            _CartaoControle(
                key: ValueKey('cartao-${c.simbolo}'), largura: largura, ajuda: _ajudaDe(l, c.simbolo), filho: controle),
      ]),
    ]);
  }

  /// O que o controle faz no plugin, quando o nome não basta (o Action).
  static String? _ajudaDe(AppLocalizations l, String simbolo) => simbolo == 'action' ? l.utAcaoChave : null;

  List<Widget> _outros(BuildContext context, _ControlesDoBloco controles) {
    final usados = arranjo.simbolos;
    final resto = [for (final p in parametros) if (!usados.contains(p.simbolo)) p];
    if (resto.isEmpty) return const [];
    return [
      CartaoSecaoSynth(
        key: const ValueKey('ut-outros'),
        titulo: AppLocalizations.of(context).axOutros,
        largura: double.infinity,
        filhos: [for (final p in resto) controles.noPainel(p, Medidas.knobSynth)],
      ),
    ];
  }
}

/// Um cartão do visor: o controle no meio, todos da mesma altura na fileira,
/// e o "?" no canto quando há o que explicar.
class _CartaoControle extends StatelessWidget {
  const _CartaoControle({super.key, required this.largura, required this.filho, this.ajuda});

  final double largura;
  final Widget filho;
  final String? ajuda;

  @override
  Widget build(BuildContext context) => Container(
        constraints: BoxConstraints(minWidth: largura, maxWidth: largura, minHeight: Medidas.alturaCartaoUtilitario),
        padding: const EdgeInsets.all(Espacos.s),
        decoration: BoxDecoration(
          color: Cores.painel,
          borderRadius: BorderRadius.circular(Raios.painel),
          border: Border.all(color: Cores.filete),
        ),
        child: Stack(alignment: Alignment.center, children: [
          filho,
          if (ajuda case final texto?) Positioned(top: 0, right: 0, child: _Ajuda(texto: texto)),
        ]),
      );
}

class _Ajuda extends StatelessWidget {
  const _Ajuda({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) => Tooltip(
        key: const ValueKey('ajuda-action'),
        message: texto,
        triggerMode: TooltipTriggerMode.tap,
        child: const SizedBox.square(
          dimension: Medidas.alvoMinimo,
          child: Icon(Icons.help_outline, size: Medidas.iconeMenu, color: Cores.textoSecundario),
        ),
      );
}

/// Saída do plugin (Status, Accuracy): o estado não chega pelo USB, então o
/// cartão diz onde ver, sem inventar valor.
class _Saida extends StatelessWidget {
  const _Saida({required this.nome});

  final String nome;

  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
        Text(nome.toUpperCase(), style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: Espacos.s),
        Text(AppLocalizations.of(context).utSoNoVisor,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Cores.textoSecundario)),
      ]);
}

/// Cada controle do arranjo no widget dele, lendo os valores da cena ativa.
class _ControlesDoBloco {
  const _ControlesDoBloco({required this.bloco, required this.definicao, required this.cena, required this.tamanhoKnob});

  final BlocoPreset bloco;
  final DefinicaoBloco definicao;
  final int cena;
  final double tamanhoKnob;

  num _valor(DefinicaoParametro p) => ControleNoPainel.valorNaCena(bloco, p, cena);

  bool _apagado(ControleUtil c) {
    final regra = c.apagamento;
    final quem = regra == null ? null : definicao.parametro(regra.simbolo);
    return quem != null && regra!.apaga(_valor(quem));
  }

  /// A saída não está no catálogo: o arranjo dá o nome do visor.
  DefinicaoParametro? _parametro(ControleUtil c) =>
      definicao.parametro(c.simbolo) ??
      (c.nome == null ? null : DefinicaoParametro(simbolo: c.simbolo, nome: c.nome!, minimo: 0, maximo: 0, padrao: 0));

  Widget? de(ControleUtil c) {
    final doCatalogo = _parametro(c);
    if (doCatalogo == null) return null;
    final p = c.unidade == null ? doCatalogo : doCatalogo.comUnidade(c.unidade!, inteiro: true);
    final apagado = _apagado(c);
    final controle = _controle(c, p, apagado);
    return apagado ? Opacity(opacity: Medidas.opacidadeBandaDesligada, child: controle) : controle;
  }

  Widget _controle(ControleUtil c, DefinicaoParametro p, bool apagado) => switch (c.tipo) {
        TipoControleUtil.lista => noPainel(p, Medidas.larguraCartaoUtilitario,
            construtor: (valor, cor, aoMudar) => ListaRolante(parametro: p, valor: valor, cor: cor, aoMudar: aoMudar)),
        TipoControleUtil.rolo => noPainel(p, Medidas.larguraCartaoUtilitario,
            construtor: (valor, cor, aoMudar) => RoloOpcoes(parametro: p, valor: valor, cor: cor, aoMudar: aoMudar)),
        TipoControleUtil.knob => noPainel(p, Medidas.knobSynth),
        // a chave não tem knob: o tamanho só dá largura ao nome ("Use Host Tempo")
        TipoControleUtil.chave => noPainel(p, Medidas.knobAmplo),
        TipoControleUtil.knobGrande => _knobGrande(c, p, apagado),
        TipoControleUtil.saida => _Saida(nome: p.nome),
      };

  /// O tempo: o knob maior e, no metrônomo, o BATER embaixo.
  Widget _knobGrande(ControleUtil c, DefinicaoParametro p, bool apagado) {
    final knob = noPainel(p, tamanhoKnob);
    if (!c.comToque) return knob;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      knob,
      const SizedBox(height: Espacos.s),
      BotaoToque(parametro: p, bloco: bloco, habilitado: !apagado),
    ]);
  }

  Widget noPainel(DefinicaoParametro p, double tamanho, {ConstrutorControle? construtor}) => ControleNoPainel(
      parametro: p, bloco: bloco, definicao: definicao, cena: cena, tamanho: tamanho, construtor: construtor);
}
