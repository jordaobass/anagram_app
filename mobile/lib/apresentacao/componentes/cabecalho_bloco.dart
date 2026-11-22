// Cabeçalho do painel: pedal, nome, família e o bypass grande.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../tema/tokens.dart';
import 'arte_bloco.dart';
import 'botao_dicas.dart';
import 'casa_arrastavel.dart';
import 'menu_bloco.dart';
import 'toque_duplo.dart';
import '../../l10n/app_localizations.dart';
import '../textos.dart';

class CabecalhoBloco extends ConsumerWidget {
  const CabecalhoBloco({super.key, required this.bloco, required this.definicao, required this.cena});

  final BlocoPreset bloco;
  final DefinicaoBloco definicao;
  final int cena;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final identidade = _identidade(context, ref);
    final acoes = _acoes(context, ref);
    // estreito (celular): ações embaixo, para o nome não ser espremido
    return LayoutBuilder(
      builder: (context, restricoes) => restricoes.maxWidth < Medidas.larguraCabecalhoEmLinha
          ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              identidade,
              const SizedBox(height: Espacos.s),
              Align(alignment: Alignment.centerRight, child: acoes),
            ])
          : Row(children: [Expanded(child: identidade), acoes]),
    );
  }

  Widget _identidade(BuildContext context, WidgetRef ref) {
    final ligado = bloco.habilitadoNaCena(cena);
    return Row(children: [
      // duplo clique no pedal = o botão LIGADO, como pisar no footswitch
      ToqueDuplo(
        key: const ValueKey('icone-pedal-painel'),
        aoTocarDuas: () => ref.read(editorProvider.notifier).alternarBypass(bloco.posicao),
        child: ArteBlocoWidget(
            definicao: definicao, tamanho: Medidas.artePainelBloco, ligado: ligado, arquivoIr: bloco.arquivoDeIr),
      ),
      const SizedBox(width: Espacos.m),
      Expanded(child: _textos(context, ligado: ligado, modelo: nomeDoModeloNoBloco(ref, bloco))),
    ]);
  }

  /// Nome (com o "?" das dicas de gesto), o tom carregado e onde o bloco está.
  Widget _textos(BuildContext context, {required bool ligado, String? modelo}) {
    final tema = Theme.of(context).textTheme;
    final l = AppLocalizations.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Flexible(child: Text(l.nomeDoBloco(definicao), style: tema.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis)),
        BotaoDicas(key: const ValueKey('dicas-bloco'), dicas: _dicas(l)),
      ]),
      if (modelo != null)
        Text(modelo,
            key: const ValueKey('nome-do-modelo'),
            style: tema.titleSmall?.copyWith(color: Cores.aluminioClaro),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      Text(l.blocoPosicao(l.familia(definicao.familia), bloco.posicao.linha, bloco.posicao.casa), style: tema.bodySmall),
      if (bloco.bypassSoNaCena(cena))
        Text(ligado ? l.ligadoSoNaCena(cena) : l.desligadoSoNaCena(cena),
            style: tema.labelSmall?.copyWith(color: Cores.aluminioClaro)),
    ]);
  }

  /// Arrastar, ligar pelo pedal e o balão dos parâmetros: o balão não se
  /// descobre olhando, então a dica dele vai junto das outras.
  static List<String> _dicas(AppLocalizations l) => arrastoComMouse
      ? [l.arrasteComMouse, l.uiDicaDuploClique, l.ttDicaMouse]
      : [l.arrasteNoToque, l.uiDicaToqueDuplo, l.ttDicaToque];

  Widget _acoes(BuildContext context, WidgetRef ref) {
    final controlador = ref.read(editorProvider.notifier);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      IconButton(
        tooltip: AppLocalizations.of(context).copiarBloco,
        icon: const Icon(Icons.copy_outlined),
        onPressed: () => controlador.copiarBloco(bloco.posicao),
      ),
      _BotaoMaisAcoes(posicao: bloco.posicao),
      const SizedBox(width: Espacos.s),
      _BotaoBypass(ligado: bloco.habilitadoNaCena(cena), aoTocar: () => controlador.alternarBypass(bloco.posicao)),
    ]);
  }
}

/// O menu do bloco (mover, remover, colar) à vista: o botão direito e o toque
/// longo não se descobrem sozinhos, e no toque o longo virou arrastar.
class _BotaoMaisAcoes extends ConsumerWidget {
  const _BotaoMaisAcoes({required this.posicao});

  final PosicaoBloco posicao;

  @override
  Widget build(BuildContext context, WidgetRef ref) => IconButton(
        key: const ValueKey('mais-acoes-bloco'),
        tooltip: AppLocalizations.of(context).maisAcoesBloco,
        icon: const Icon(Icons.more_vert),
        onPressed: () {
          final caixa = context.findRenderObject()! as RenderBox;
          abrirMenuBloco(context, ref, posicao, caixa.localToGlobal(caixa.size.bottomLeft(Offset.zero)));
        },
      );
}

class _BotaoBypass extends StatelessWidget {
  const _BotaoBypass({required this.ligado, required this.aoTocar});

  final bool ligado;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Semantics(
        toggled: ligado,
        label: l.blocoLigadoSemantica,
        child: ligado
            ? FilledButton.icon(
                key: const ValueKey('bypass'),
                onPressed: aoTocar,
                icon: const Icon(Icons.power_settings_new),
                label: Text(l.ligado),
              )
            : OutlinedButton.icon(
                key: const ValueKey('bypass'),
                onPressed: aoTocar,
                icon: const Icon(Icons.power_settings_new),
                label: Text(l.desligado),
              ),
      );
  }
}
