// Uma casa da grade: o pedal numa caixa de tamanho fixo (as fotos da
// pedaleira têm proporções diferentes e na caixa ficam alinhadas), o nome que
// a pedaleira informa e a fita de cor da família. A casa vazia é um encaixe
// tracejado com "+". Toque seleciona na hora (na vazia, abre a biblioteca de
// efeitos); toque duplo liga/desliga; botão direito abre o menu do bloco. No
// toque, o toque longo da casa ocupada é o arrasto, então o menu dela fica no
// botão visível do painel; na vazia, o toque longo ainda abre o menu (colar).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/provedores.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../tema/tokens.dart';
import 'arte_bloco.dart';
import 'pintor_encaixe.dart';
import 'toque_duplo.dart';
import '../../l10n/app_localizations.dart';
import '../textos.dart';

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
    return Semantics(
      button: true,
      selected: selecionado,
      label: _rotulo(AppLocalizations.of(context), ref, atual),
      child: ToqueDuplo(
        aoTocar: aoTocar,
        aoTocarDuas: atual == null ? null : aoTocarDuas,
        child: GestureDetector(
          onLongPressStart: atual == null ? (d) => aoPedirMenu(d.globalPosition) : null,
          onSecondaryTapUp: (d) => aoPedirMenu(d.globalPosition),
          child: AnimatedContainer(
            duration: Duracoes.curta,
            width: largura,
            padding: const EdgeInsets.all(Espacos.xs),
            decoration: _moldura(context.cores),
            child: atual == null ? _vazia(context.cores) : _ocupada(context, ref, atual),
          ),
        ),
      ),
    );
  }

  /// O que o leitor de tela diz: a casa vazia pela posição, a ocupada pelo bloco.
  String _rotulo(AppLocalizations l, WidgetRef ref, BlocoPreset? atual) {
    if (atual == null) return l.adicionarEfeitoNaCasa(posicao.casa, posicao.linha);
    final modelo = nomeDoModeloNoBloco(ref, atual);
    final bloco = l.nomeDoBloco(ref.watch(definicaoBlocoProvider(atual.uri)));
    final nome = modelo == null ? bloco : '$bloco · $modelo';
    return ligado ? l.blocoLigado(nome) : l.blocoDesligado(nome);
  }

  BoxDecoration _moldura(Paleta cores) => BoxDecoration(
        color: selecionado ? cores.painelElevado : Colors.transparent,
        borderRadius: BorderRadius.circular(Raios.controle),
        border: Border.all(
          color: selecionado ? cores.tallyTinta : Colors.transparent,
          width: Medidas.contornoSelecao,
        ),
      );

  double get _caixa => _interno * Medidas.arteNaCasa;

  /// Encaixe tracejado do tamanho da caixa do pedal, no mesmo lugar dela.
  Widget _vazia(Paleta cores) => SizedBox.square(
        dimension: _caixa,
        child: CustomPaint(
          painter: PintorEncaixe(cores: cores),
          child: Center(child: Icon(Icons.add, size: _caixa * Medidas.marcaCasaVazia, color: cores.textoSecundario)),
        ),
      );

  double get _interno => largura - Espacos.xs * 2 - Medidas.contornoSelecao * 2;

  Widget _ocupada(BuildContext context, WidgetRef ref, BlocoPreset atual) {
    final definicao = ref.watch(definicaoBlocoProvider(atual.uri));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CaixaPedal(
            tamanho: _caixa,
            child: ArteBlocoWidget(
                definicao: definicao,
                tamanho: _caixa - Medidas.folgaArteNaCaixa * 2,
                ligado: ligado,
                arquivoIr: atual.arquivoDeIr)),
        const SizedBox(height: Espacos.xs),
        Container(height: Medidas.fitaCategoria, color: context.cores.daFita(definicao.uri, definicao.familia)),
        const SizedBox(height: Espacos.xxs),
        SizedBox(
            height: Medidas.alturaRotuloCasa,
            child: _nomeEmbaixo(context, definicao, nomeDoModeloNoBloco(ref, atual))),
      ],
    );
  }

  /// O nome do bloco embaixo da arte, no maior tamanho em que cabe. Bloco que
  /// carrega arquivo (TONE3000, neural) mostra o tom: o tipo já está na arte.
  Widget _nomeEmbaixo(BuildContext context, DefinicaoBloco definicao, String? modelo) {
    final estilo = Theme.of(context).textTheme.labelMedium?.copyWith(
          color: ligado ? context.cores.texto : context.cores.textoSecundario,
          height: Medidas.entrelinhaRotuloCasa,
        );
    final l = AppLocalizations.of(context);
    final (rotulo, estiloRotulo) = rotuloQueCabe(modelo ?? l.nomeCurtoDoBloco(definicao),
        modelo ?? l.nomeCurtoDoBloco(definicao, abreviado: true), estilo, _interno, Directionality.of(context));
    return Text(rotulo, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: estiloRotulo);
  }
}

/// O nome inteiro, como na tela da pedaleira ("SUP" não diz qual bloco é),
/// desde que nenhuma palavra precise ser partida: numa casa estreita
/// "Suppress/or" lê pior que a abreviação. Sem abreviação, fica o nome.
(String, TextStyle?) rotuloQueCabe(String nome, String abreviacao, TextStyle? estilo, double largura, TextDirection direcao) {
  // o nome inteiro vem primeiro (como na tela da pedaleira): a letra diminui
  // em passos antes de desistir; a abreviação só sobra em casa muito estreita
  for (final escala in Medidas.reducoesRotuloCasa) {
    final tamanho = (estilo?.fontSize ?? Medidas.fonteRotuloCasaPadrao) * escala;
    final reduzido = estilo?.copyWith(fontSize: tamanho) ?? TextStyle(fontSize: tamanho);
    if (_cabeEmDuasLinhas(nome, reduzido, largura, direcao)) return (nome, reduzido);
  }
  return abreviacao.isEmpty ? (nome, estilo) : (abreviacao, estilo);
}

/// Cada palavra cabe numa linha (nada de "Suppress/or") e o todo, em duas.
bool _cabeEmDuasLinhas(String texto, TextStyle estilo, double largura, TextDirection direcao) {
  final pintor = TextPainter(textDirection: direcao, maxLines: 1);
  try {
    for (final palavra in texto.split(' ')) {
      pintor.text = TextSpan(text: palavra, style: estilo);
      pintor.layout();
      if (pintor.width > largura) return false;
    }
    pintor
      ..maxLines = 2
      ..text = TextSpan(text: texto, style: estilo)
      ..layout(maxWidth: largura);
    return !pintor.didExceedMaxLines;
  } finally {
    pintor.dispose();
  }
}

/// Caixa fixa do pedal na cadeia: fundo de painel opaco (a linha do sinal
/// passa por trás) e a foto, de qualquer proporção, centrada dentro dela.
class CaixaPedal extends StatelessWidget {
  const CaixaPedal({super.key, required this.tamanho, required this.child});

  final double tamanho;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        width: tamanho,
        height: tamanho,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.cores.painel,
          borderRadius: BorderRadius.circular(Raios.controle),
          border: Border.all(color: context.cores.filete),
        ),
        child: child,
      );
}
