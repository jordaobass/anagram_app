// Um parâmetro do bloco selecionado no painel: lê o valor na cena ativa,
// manda a mudança pelo editor (ao vivo, desfazer, cena) e marca quando a
// cena sobrepõe o valor. O painel genérico e o do multibanda usam o mesmo.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../../l10n/app_localizations.dart';
import '../../nucleo/catalogo/arranjo_parametros.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../tema/tokens.dart';
import 'botao_giratorio.dart' show AoMudarValor;
import 'controle_parametro.dart';
import 'seletor_opcao.dart';

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
  });

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
          .alterarParametro(p.simbolo, valor, arrastando: arrastando, nome: p.nome, posicao: bloco.posicao);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = parametro;
    final cor = Cores.daFamilia(definicao.familia);
    final valor = valorNaCena(bloco, p, cena);
    return Column(mainAxisSize: MainAxisSize.min, children: [
      if (seletor)
        SeletorOpcao(
            key: ValueKey('param-${p.simbolo}'),
            parametro: p,
            rotulo: rotulo,
            valor: valor,
            cor: cor,
            largura: tamanho,
            aoMudar: alterar(ref, p, bloco))
      else
        ControleParametro(
          key: ValueKey('param-${p.simbolo}'),
          parametro: p,
          rotulo: rotulo,
          forma: forma ?? formaDoControle(definicao, p),
          valor: valor,
          cor: cor,
          tamanho: tamanho,
          aoMudar: alterar(ref, p, bloco),
        ),
      // como o valor "atribuído ao snapshot" do HX: esta cena sobrepõe
      if (bloco.sobreposicaoDaCena(p.simbolo, cena) != null)
        // neutro: o âmbar é da ação e da seleção, não de marca informativa
        Text(AppLocalizations.of(context).soNaCena(cena),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Cores.aluminioClaro)),
    ]);
  }
}
