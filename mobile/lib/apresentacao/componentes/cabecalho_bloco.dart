// Cabeçalho do painel: pedal, nome, família e o bypass grande.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../tema/tokens.dart';
import 'arte_bloco.dart';

class CabecalhoBloco extends ConsumerWidget {
  const CabecalhoBloco({super.key, required this.bloco, required this.definicao, required this.cena});

  final BlocoPreset bloco;
  final DefinicaoBloco definicao;
  final int cena;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final identidade = _identidade(context);
    final acoes = _acoes(ref);
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

  Widget _identidade(BuildContext context) {
    final ligado = bloco.habilitadoNaCena(cena);
    final tema = Theme.of(context).textTheme;
    return Row(children: [
      ArteBlocoWidget(definicao: definicao, tamanho: Medidas.alvoMinimo, ligado: ligado),
      const SizedBox(width: Espacos.m),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(definicao.nome, style: tema.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
          Text('${definicao.familia.rotulo} · linha ${bloco.posicao.linha}, casa ${bloco.posicao.casa}',
              style: tema.bodySmall),
          if (bloco.bypassSoNaCena(cena))
            Text('${ligado ? 'LIGADO' : 'DESLIGADO'} SÓ NA CENA $cena',
                style: tema.labelSmall?.copyWith(color: Cores.tally)),
        ]),
      ),
    ]);
  }

  Widget _acoes(WidgetRef ref) {
    final controlador = ref.read(editorProvider.notifier);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      IconButton(
        tooltip: 'Copiar bloco',
        icon: const Icon(Icons.copy_outlined),
        onPressed: () => controlador.copiarBloco(bloco.posicao),
      ),
      const SizedBox(width: Espacos.s),
      _BotaoBypass(ligado: bloco.habilitadoNaCena(cena), aoTocar: () => controlador.alternarBypass(bloco.posicao)),
    ]);
  }
}

class _BotaoBypass extends StatelessWidget {
  const _BotaoBypass({required this.ligado, required this.aoTocar});

  final bool ligado;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) => Semantics(
        toggled: ligado,
        label: 'Bloco ligado',
        child: ligado
            ? FilledButton.icon(
                key: const ValueKey('bypass'),
                onPressed: aoTocar,
                icon: const Icon(Icons.power_settings_new),
                label: const Text('LIGADO'),
              )
            : OutlinedButton.icon(
                key: const ValueKey('bypass'),
                onPressed: aoTocar,
                icon: const Icon(Icons.power_settings_new),
                label: const Text('DESLIGADO'),
              ),
      );
}
