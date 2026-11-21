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
import '../../nucleo/modelo/bloco_preset.dart';
import '../tema/tokens.dart';
import 'arte_bloco.dart';
import 'pintor_encaixe.dart';
import 'toque_duplo.dart';
import '../../l10n/app_localizations.dart';

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
            decoration: _moldura(),
            child: atual == null ? _vazia() : _ocupada(context, ref, atual),
          ),
        ),
      ),
    );
  }

  /// O que o leitor de tela diz: a casa vazia pela posição, a ocupada pelo bloco.
  String _rotulo(AppLocalizations l, WidgetRef ref, BlocoPreset? atual) {
    if (atual == null) return l.adicionarEfeitoNaCasa(posicao.casa, posicao.linha);
    final nome = ref.watch(definicaoBlocoProvider(atual.uri)).nome;
    return ligado ? l.blocoLigado(nome) : l.blocoDesligado(nome);
  }

  BoxDecoration _moldura() => BoxDecoration(
        color: selecionado ? Cores.painelElevado : Colors.transparent,
        borderRadius: BorderRadius.circular(Raios.controle),
        border: Border.all(
          color: selecionado ? Cores.tally : Colors.transparent,
          width: Medidas.contornoSelecao,
        ),
      );

  double get _caixa => _interno * Medidas.arteNaCasa;

  /// Encaixe tracejado do tamanho da caixa do pedal, no mesmo lugar dela.
  Widget _vazia() => SizedBox.square(
        dimension: _caixa,
        child: CustomPaint(
          painter: const PintorEncaixe(),
          child: Center(child: Icon(Icons.add, size: _caixa * Medidas.marcaCasaVazia, color: Cores.textoSecundario)),
        ),
      );

  double get _interno => largura - Espacos.xs * 2 - Medidas.contornoSelecao * 2;

  Widget _ocupada(BuildContext context, WidgetRef ref, BlocoPreset atual) {
    final definicao = ref.watch(definicaoBlocoProvider(atual.uri));
    final estilo = Theme.of(context).textTheme.labelMedium?.copyWith(
          color: ligado ? Cores.texto : Cores.textoSecundario,
          height: Medidas.entrelinhaRotuloCasa,
        );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CaixaPedal(tamanho: _caixa, child: ArteBlocoWidget(definicao: definicao, tamanho: _caixa - Espacos.xs * 2, ligado: ligado)),
        const SizedBox(height: Espacos.xs),
        Container(height: Medidas.fitaCategoria, color: Cores.daFamilia(definicao.familia)),
        const SizedBox(height: Espacos.xxs),
        SizedBox(
          height: Medidas.alturaRotuloCasa,
          child: Text(
            rotuloQueCabe(definicao.nome, definicao.abreviacao, estilo, _interno, Directionality.of(context)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: estilo,
          ),
        ),
      ],
    );
  }
}

/// O nome inteiro, como na tela da pedaleira ("SUP" não diz qual bloco é),
/// desde que nenhuma palavra precise ser partida: numa casa estreita
/// "Suppress/or" lê pior que a abreviação. Sem abreviação, fica o nome.
String rotuloQueCabe(String nome, String abreviacao, TextStyle? estilo, double largura, TextDirection direcao) {
  if (abreviacao.isEmpty) return nome;
  final pintor = TextPainter(textDirection: direcao, maxLines: 1);
  for (final palavra in nome.split(' ')) {
    pintor.text = TextSpan(text: palavra, style: estilo);
    pintor.layout();
    if (pintor.width > largura) {
      pintor.dispose();
      return abreviacao;
    }
  }
  pintor.dispose();
  return nome;
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
          color: Cores.painel,
          borderRadius: BorderRadius.circular(Raios.controle),
          border: Border.all(color: Cores.filete),
        ),
        child: child,
      );
}
