// Uma casa da grade: o pedal, o nome que a pedaleira informa e a fita de
// cor da família. Toque seleciona; toque duplo liga/desliga; toque longo
// (ou botão direito) abre copiar/colar.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/provedores.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../tema/tokens.dart';
import 'arte_bloco.dart';

class CasaBloco extends ConsumerWidget {
  const CasaBloco({
    super.key,
    required this.posicao,
    required this.bloco,
    required this.ligado,
    required this.selecionado,
    required this.largura,
    required this.aoTocar,
    required this.aoTocarDuas,
    required this.aoPedirMenu,
  });

  final PosicaoBloco posicao;
  final BlocoPreset? bloco;
  final bool ligado;
  final bool selecionado;
  final double largura;
  final VoidCallback aoTocar;
  final VoidCallback aoTocarDuas;
  final void Function(Offset global) aoPedirMenu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final atual = bloco;
    final rotulo = atual == null
        ? 'Casa vazia ${posicao.casa}, linha ${posicao.linha}'
        : '${ref.watch(definicaoBlocoProvider(atual.uri)).nome}, ${ligado ? 'ligado' : 'desligado'}';
    return Semantics(
      button: true,
      selected: selecionado,
      label: rotulo,
      child: GestureDetector(
        onTap: aoTocar,
        onDoubleTap: atual == null ? null : aoTocarDuas,
        onLongPressStart: (d) => aoPedirMenu(d.globalPosition),
        onSecondaryTapUp: (d) => aoPedirMenu(d.globalPosition),
        child: AnimatedContainer(
          duration: Duracoes.curta,
          width: largura,
          padding: const EdgeInsets.all(Espacos.xs),
          decoration: BoxDecoration(
            color: selecionado ? Cores.painelElevado : Colors.transparent,
            borderRadius: BorderRadius.circular(Raios.controle),
            border: Border.all(
              color: selecionado ? Cores.tally : Colors.transparent,
              width: Medidas.contornoSelecao,
            ),
          ),
          child: atual == null ? _vazia() : _ocupada(context, ref, atual),
        ),
      ),
    );
  }

  Widget _vazia() => AspectRatio(
        aspectRatio: 1,
        child: Center(
          child: Container(
            width: largura * 0.22,
            height: largura * 0.22,
            decoration: BoxDecoration(
              color: Cores.fundoCase,
              shape: BoxShape.circle,
              border: Border.all(color: Cores.filete, width: Medidas.contornoSelecao),
            ),
          ),
        ),
      );

  Widget _ocupada(BuildContext context, WidgetRef ref, BlocoPreset atual) {
    final definicao = ref.watch(definicaoBlocoProvider(atual.uri));
    final interno = largura - Espacos.xs * 2 - Medidas.contornoSelecao * 2;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ArteBlocoWidget(definicao: definicao, tamanho: interno * Medidas.arteNaCasa, ligado: ligado),
        const SizedBox(height: Espacos.xs),
        Container(height: Medidas.fitaCategoria, color: Cores.daFamilia(definicao.familia)),
        const SizedBox(height: Espacos.xxs),
        Text(
          definicao.abreviacao.isNotEmpty && interno < Medidas.casaRotuloCompleto ? definicao.abreviacao : definicao.nome,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(color: ligado ? Cores.texto : Cores.textoSecundario),
        ),
      ],
    );
  }
}
