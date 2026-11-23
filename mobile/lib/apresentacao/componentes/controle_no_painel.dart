// Um parâmetro do bloco selecionado no painel: lê o valor na cena ativa,
// manda a mudança pelo editor (ao vivo, desfazer, cena) e marca quando a
// cena sobrepõe o valor. O painel genérico e o do multibanda usam o mesmo.
// Botão direito atribui o parâmetro a um pot ou ao pedal de expressão, e a
// marca embaixo ("POT 2") diz que ele já está num controle da pedaleira.
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../../aplicacao/estado/estado_editor.dart';
import '../../l10n/app_localizations.dart';
import '../../nucleo/catalogo/arranjo_parametros.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../../nucleo/modelo/controles_pedaleira.dart';
import '../tema/tokens.dart';
import '../textos.dart';
import 'botao_giratorio.dart' show AoMudarValor;
import 'controle_parametro.dart';
import 'menu_atribuir.dart';
import 'seletor_opcao.dart';

/// Um controle desenhado pelo painel do bloco (a lista rolante, o rolo do
/// compasso), com o valor da cena e a mudança pelo caminho comum.
typedef ConstrutorControle = Widget Function(num valor, Color cor, AoMudarValor aoMudar);

class ControleNoPainel extends ConsumerWidget {
  const ControleNoPainel({
    super.key,
    required this.parametro,
    required this.bloco,
    required this.definicao,
    required this.cena,
    required this.tamanho,
    this.rotulo,
    this.forma,
    this.seletor = false,
    this.corChip,
    this.construtor,
  });

  /// Nulo: knob, chave, botões ou seletor, conforme o parâmetro.
  final ConstrutorControle? construtor;

  /// O valor num chip dessa cor (modo do equalizador); nulo, o número comum.
  final Color? corChip;

  final DefinicaoParametro parametro;
  final BlocoPreset bloco;
  final DefinicaoBloco definicao;
  final int cena;
  final double tamanho;
  final String? rotulo;

  /// Nula: a do catálogo (fader nas bandas do GEQ, knob no resto).
  final FormaControle? forma;

  /// Opções num botão que abre a lista, em vez de knob ou botões empilhados.
  final bool seletor;

  /// O valor que o painel mostra: o da cena ativa, ou o padrão do catálogo.
  static num valorNaCena(BlocoPreset bloco, DefinicaoParametro p, int cena) =>
      bloco.valorNaCena(p.simbolo, cena) ?? p.padrao;

  /// A mudança pelo mesmo caminho de todo controle do editor.
  static AoMudarValor alterar(WidgetRef ref, DefinicaoParametro p, BlocoPreset bloco) =>
      (valor, {required arrastando}) => ref
          .read(editorProvider.notifier)
          .alterarParametro(p.simbolo, valor,
              arrastando: arrastando, nome: p.nome, posicao: bloco.posicao, padrao: p.padrao);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final marca = Theme.of(context).textTheme.labelSmall?.copyWith(color: context.cores.aluminioClaro);
    final chaves = ref.watch(editorProvider.select(_controlesDoParametro));
    final controles = [
      for (final chave in chaves.split(' '))
        if (IdControle.daChave(chave) case final id?) l.rotuloControle(id),
    ].join(' · ');
    return Semantics(
      customSemanticsActions: {CustomSemanticsAction(label: l.ctlAcaoAtribuir): () => _atribuir(context, ref, null)},
      child: GestureDetector(
        onSecondaryTapUp: (detalhes) => _atribuir(context, ref, detalhes.globalPosition),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _controle(context, ref),
          // como o valor "atribuído ao snapshot" do HX: esta cena sobrepõe
          // (neutro: o âmbar é da ação e da seleção, não de marca informativa)
          if (bloco.valorSoNaCena(parametro.simbolo, cena)) Text(l.soNaCena(cena), style: marca),
          if (controles.isNotEmpty)
            Semantics(
              label: l.ctlAtribuidoA(controles),
              child: ExcludeSemantics(
                  child: Text(controles, key: ValueKey('marca-controle-${parametro.simbolo}'), style: marca)),
            ),
        ]),
      ),
    );
  }

  /// "POT 2", "POT 2 · EXP": os controles que movem este parâmetro. Texto, e
  /// não lista, para o select só reconstruir quando a marca muda.
  String _controlesDoParametro(EstadoEditor estado) {
    final controles = estado.atual?.controles ?? const {};
    return controlesDoParametro(controles, bloco.posicao, parametro.simbolo).map((id) => id.chave).join(' ');
  }

  void _atribuir(BuildContext context, WidgetRef ref, Offset? ponto) {
    final caixa = context.findRenderObject()! as RenderBox;
    final origem = ponto ?? caixa.localToGlobal(caixa.size.bottomCenter(Offset.zero));
    abrirMenuAtribuir(context, ref, bloco.posicao, parametro, origem);
  }

  Widget _controle(BuildContext context, WidgetRef ref) {
    final p = parametro;
    final cor = context.cores.daFamilia(definicao.familia);
    final valor = valorNaCena(bloco, p, cena);
    if (construtor case final desenhar?) {
      return KeyedSubtree(key: ValueKey('param-${p.simbolo}'), child: desenhar(valor, cor, alterar(ref, p, bloco)));
    }
    if (seletor) {
      return SeletorOpcao(
          key: ValueKey('param-${p.simbolo}'),
          parametro: p,
          rotulo: rotulo,
          valor: valor,
          cor: cor,
          largura: tamanho,
          aoMudar: alterar(ref, p, bloco));
    }
    return ControleParametro(
      key: ValueKey('param-${p.simbolo}'),
      parametro: p,
      rotulo: rotulo,
      forma: forma ?? formaDoControle(definicao, p),
      corChip: corChip,
      valor: valor,
      cor: cor,
      tamanho: tamanho,
      aoMudar: alterar(ref, p, bloco),
    );
  }
}
