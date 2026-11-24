// Painel do Axioma Mono Synth como a tela dele na pedaleira, um aparelho em
// neon: a barra de cima (X, logotipo, Templates, abas, liga/desliga, LCD,
// Controlar e ações), a faixa de medidores e os módulos de moldura dupla —
// os três osciladores, o filtro largo com a curva, o envelope, a entrada, a
// saída e o arpejador —, com a grade de furos entre eles. No celular os
// módulos empilham. Parâmetro que o arranjo não conhece (firmware novo) cai
// em "Outros", para nunca sumir. As abas da barra rolam até a seção.
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../nucleo/catalogo/arranjo_sintetizador.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../tema/tokens.dart';
import 'secoes_sintetizador.dart';
import 'tela_pedaleira/barra_axioma.dart';
import 'tela_pedaleira/faixa_medidores.dart';
import 'tela_pedaleira/modulo_neon.dart';
import 'tela_pedaleira/neon.dart';

class PainelSintetizador extends StatefulWidget {
  const PainelSintetizador({
    super.key,
    required this.arranjo,
    required this.bloco,
    required this.definicao,
    required this.cena,
    required this.parametros,
  });

  final ArranjoSintetizador arranjo;
  final BlocoPreset bloco;
  final DefinicaoBloco definicao;
  final int cena;

  /// Os parâmetros que o painel genérico mostraria.
  final List<DefinicaoParametro> parametros;

  /// A partir daqui os módulos andam lado a lado como na tela da pedaleira.
  static const larguraLarga = 960.0;

  /// Abaixo disso (celular), um módulo por linha.
  static const larguraEstreita = 640.0;

  @override
  State<PainelSintetizador> createState() => _EstadoPainelSintetizador();
}

class _EstadoPainelSintetizador extends State<PainelSintetizador> {
  final _ancoras = {for (final s in SecaoSintetizador.values) s: GlobalKey(debugLabel: 'ax-ancora-${s.name}')};

  static const _vao = Espacos.m;

  SecoesSintetizador _secoes(BuildContext context) => SecoesSintetizador(
      arranjo: widget.arranjo, bloco: widget.bloco, definicao: widget.definicao, cena: widget.cena, cores: context.cores);

  void _irPara(SecaoSintetizador secao) {
    final alvo = _ancoras[secao]!.currentContext;
    if (alvo == null) return;
    final semMovimento = MediaQuery.disableAnimationsOf(context);
    Scrollable.ensureVisible(alvo, duration: semMovimento ? Duration.zero : const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) => PulsoNeon(
        child: LayoutBuilder(builder: (context, restricoes) {
          final largura = restricoes.maxWidth;
          final secoes = _secoes(context);
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            BarraAxioma(bloco: widget.bloco, definicao: widget.definicao, cena: widget.cena, aoIrPara: _irPara),
            const SizedBox(height: _vao),
            FaixaMedidores(entrada: secoes.comValor('sensitivity'), saida: secoes.comValor('level')),
            const SizedBox(height: _vao),
            ..._corpo(context, secoes, largura),
            ..._outros(context, secoes, largura),
          ]);
        }),
      );

  List<Widget> _corpo(BuildContext context, SecoesSintetizador secoes, double largura) {
    Widget ancorado(SecaoSintetizador s, Widget filho) => KeyedSubtree(key: _ancoras[s], child: filho);
    final osciladores = ancorado(SecaoSintetizador.osciladores, _osciladores(context, secoes, largura));
    Widget modulo(SecaoSintetizador s, [double? l]) => ancorado(s, secoes.modulo(context, s, largura: l));
    if (largura < PainelSintetizador.larguraEstreita) {
      return [
        for (final s in SecaoSintetizador.values) ...[
          s == SecaoSintetizador.osciladores ? osciladores : modulo(s),
          const SizedBox(height: _vao),
        ],
      ];
    }
    final larga = largura >= PainelSintetizador.larguraLarga;
    return [
      if (larga)
        _fileira([(osciladores, 3), (modulo(SecaoSintetizador.filtro), 2)])
      else ...[osciladores, const SizedBox(height: _vao), modulo(SecaoSintetizador.filtro)],
      const SizedBox(height: _vao),
      if (larga)
        _fileira([(modulo(SecaoSintetizador.envelope), 2), (modulo(SecaoSintetizador.entrada), 1), (modulo(SecaoSintetizador.saida), 1)])
      else ...[
        modulo(SecaoSintetizador.envelope),
        const SizedBox(height: _vao),
        _fileira([(modulo(SecaoSintetizador.entrada), 1), (modulo(SecaoSintetizador.saida), 1)]),
      ],
      const SizedBox(height: _vao),
      modulo(SecaoSintetizador.arpejador),
      const SizedBox(height: _vao),
    ];
  }

  /// Módulos lado a lado, da mesma altura, com a grade de furos entre eles.
  Widget _fileira(List<(Widget, int)> pecas) => IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (final (i, (peca, peso)) in pecas.indexed) ...[
            if (i > 0) const GradeFuros(),
            Expanded(flex: peso, child: peca),
          ],
        ]),
      );

  /// Osc 1, Osc 2 e Sub: lado a lado (com a grade) ou, no celular, empilhados.
  Widget _osciladores(BuildContext context, SecoesSintetizador secoes, double largura) {
    final lista = secoes.osciladores;
    if (largura < PainelSintetizador.larguraEstreita) {
      return Column(key: const ValueKey('ax-osciladores'), mainAxisSize: MainAxisSize.min, children: [
        for (final o in lista) ...[secoes.moduloOscilador(context, o, largura), const SizedBox(height: _vao)],
      ]);
    }
    final area = largura >= PainelSintetizador.larguraLarga ? (largura - GradeFuros.largura) * 3 / 5 : largura;
    const pesos = [4, 5, 3];
    final util = area - GradeFuros.largura * (lista.length - 1);
    return IntrinsicHeight(
      key: const ValueKey('ax-osciladores'),
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        for (final (i, o) in lista.indexed) ...[
          if (i > 0) const GradeFuros(),
          Expanded(flex: pesos[i % pesos.length], child: secoes.moduloOscilador(context, o, util * pesos[i % pesos.length] / 12)),
        ],
      ]),
    );
  }

  List<Widget> _outros(BuildContext context, SecoesSintetizador secoes, double largura) {
    final usados = widget.arranjo.simbolos;
    final resto = [for (final p in widget.parametros) if (!usados.contains(p.simbolo)) p];
    if (resto.isEmpty) return const [];
    return [
      ModuloNeon(
        key: const ValueKey('ax-outros'),
        titulo: AppLocalizations.of(context).axOutros,
        largura: largura,
        child: Wrap(spacing: Espacos.s, runSpacing: Espacos.m, children: [for (final p in resto) secoes.controleSolto(p)]),
      ),
    ];
  }
}
