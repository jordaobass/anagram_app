// Painel do Axioma Mono Synth arrumado como um sintetizador: entrada,
// osciladores (com a onda desenhada), filtro (com a curva), envelope (com a
// curva), arpejador e saída, cada um num cartão. No computador os cartões
// pequenos andam em pares; no celular, empilham. Parâmetro que o arranjo não
// conhece (firmware novo) cai em "Outros", para nunca sumir.
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../nucleo/catalogo/arranjo_sintetizador.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../tema/tokens.dart';
import 'cartao_secao_synth.dart';
import 'secoes_sintetizador.dart';

class PainelSintetizador extends StatelessWidget {
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

  /// Em duas colunas, os cartões menores dividem a fileira; os largos
  /// (osciladores e arpejador) ocupam a fileira inteira.
  static const _pares = [
    [SecaoSintetizador.entrada, SecaoSintetizador.saida],
    [SecaoSintetizador.osciladores],
    [SecaoSintetizador.filtro, SecaoSintetizador.envelope],
    [SecaoSintetizador.arpejador],
  ];

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, restricoes) {
        final largura = restricoes.maxWidth;
        final duas = largura >= Medidas.larguraCartaoSynth * 2 + Espacos.m;
        final secoes = SecoesSintetizador(arranjo: arranjo, bloco: bloco, definicao: definicao, cena: cena);
        final fileiras = duas ? _pares : [for (final s in SecaoSintetizador.values) [s]];
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (final fileira in fileiras) ...[
            _fileira(context, secoes, fileira, largura),
            const SizedBox(height: Espacos.m),
          ],
          ..._outros(context, secoes, largura),
        ]);
      });

  Widget _fileira(BuildContext context, SecoesSintetizador secoes, List<SecaoSintetizador> fileira, double largura) {
    final cada = (largura - (fileira.length - 1) * Espacos.m) / fileira.length;
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        for (var i = 0; i < fileira.length; i++) ...[
          if (i > 0) const SizedBox(width: Espacos.m),
          secoes.cartao(context, fileira[i], cada),
        ],
      ]),
    );
  }

  List<Widget> _outros(BuildContext context, SecoesSintetizador secoes, double largura) {
    final usados = arranjo.simbolos;
    final resto = [for (final p in parametros) if (!usados.contains(p.simbolo)) p];
    if (resto.isEmpty) return const [];
    return [
      CartaoSecaoSynth(
        key: const ValueKey('ax-outros'),
        titulo: AppLocalizations.of(context).axOutros,
        largura: largura,
        filhos: [for (final p in resto) secoes.controleSolto(p)],
      ),
    ];
  }
}
