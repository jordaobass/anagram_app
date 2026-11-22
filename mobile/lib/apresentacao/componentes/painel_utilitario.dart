// Painel da bateria (Auto Drummer) e do metrônomo (Cognate Metro), na ordem
// e no agrupamento da tela original de cada plugin, com o visual do app: um
// cartão embaixo do outro, os controles do cartão numa fileira só quando cabem.
// Parâmetro que o arranjo não conhece (firmware novo) cai em "Outros".
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
        final largura = restricoes.maxWidth;
        final controles = _ControlesDoBloco(bloco: bloco, definicao: definicao, cena: cena, tamanhoKnob: tamanhoKnob);
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (final s in arranjo.secoes) ...[_cartao(context, controles, s, largura), const SizedBox(height: Espacos.m)],
          ..._outros(context, controles, largura),
        ]);
      });

  Widget _cartao(BuildContext context, _ControlesDoBloco controles, SecaoUtil secao, double largura) {
    final nota = _notaDa(AppLocalizations.of(context), secao.secao);
    return CartaoSecaoSynth(
      key: ValueKey('ut-${secao.secao.name}'),
      titulo: tituloDaSecaoUtilitario(AppLocalizations.of(context), secao.secao),
      largura: largura,
      filhos: [
        for (final c in secao.controles) ?controles.de(c),
        if (nota != null) SizedBox(width: double.infinity, child: notaDoCartao(context, nota)),
      ],
    );
  }

  /// O que a tela original mostra e não chega pelo USB (saídas do plugin).
  static String? _notaDa(AppLocalizations l, SecaoUtilitario secao) => switch (secao) {
        SecaoUtilitario.acao => l.utEstadoNoVisor,
        SecaoUtilitario.metronomo => l.utPrecisaoNoVisor,
        _ => null,
      };

  List<Widget> _outros(BuildContext context, _ControlesDoBloco controles, double largura) {
    final usados = arranjo.simbolos;
    final resto = [for (final p in parametros) if (!usados.contains(p.simbolo)) p];
    if (resto.isEmpty) return const [];
    return [
      CartaoSecaoSynth(
        key: const ValueKey('ut-outros'),
        titulo: AppLocalizations.of(context).axOutros,
        largura: largura,
        filhos: [for (final p in resto) controles.noPainel(p, Medidas.knobSynth)],
      ),
    ];
  }
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

  Widget? de(ControleUtil c) {
    final doCatalogo = definicao.parametro(c.simbolo);
    if (doCatalogo == null) return null;
    final p = c.unidade == null ? doCatalogo : doCatalogo.comUnidade(c.unidade!, inteiro: true);
    final apagado = _apagado(c);
    final controle = _controle(c, p, apagado);
    return apagado ? Opacity(opacity: Medidas.opacidadeBandaDesligada, child: controle) : controle;
  }

  Widget _controle(ControleUtil c, DefinicaoParametro p, bool apagado) => switch (c.tipo) {
        TipoControleUtil.lista => noPainel(p, Medidas.larguraSeletorSynth, seletor: true),
        TipoControleUtil.knob => noPainel(p, Medidas.knobSynth),
        // a chave não tem knob: o tamanho só dá largura ao nome ("Use Host Tempo")
        TipoControleUtil.chave => noPainel(p, Medidas.knobAmplo),
        TipoControleUtil.knobGrande => _knobGrande(c, p, apagado),
        TipoControleUtil.botoes =>
          BotoesDeOpcao(parametro: p, bloco: bloco, valor: _valor(p), cor: Cores.daFamilia(definicao.familia)),
        TipoControleUtil.pulso =>
          SizedBox(width: Medidas.larguraAcaoUtilitario, child: BotaoPulso(parametro: p, bloco: bloco)),
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

  Widget noPainel(DefinicaoParametro p, double tamanho, {bool seletor = false}) => ControleNoPainel(
      parametro: p, bloco: bloco, definicao: definicao, cena: cena, tamanho: tamanho, seletor: seletor);
}

String tituloDaSecaoUtilitario(AppLocalizations l, SecaoUtilitario secao) => switch (secao) {
      SecaoUtilitario.bateria => l.utBateria,
      SecaoUtilitario.acao => l.utAcao,
      SecaoUtilitario.metronomo => l.utMetronomo,
      SecaoUtilitario.treino => l.utTreino,
    };
