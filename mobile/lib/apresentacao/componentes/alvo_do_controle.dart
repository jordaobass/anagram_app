// O alvo de um controle da pedaleira como a tela o mostra: o bloco (nome e
// cor da família), o parâmetro com a faixa do catálogo e a faixa gravada.
// O cartão do painel e o diálogo de edição leem o alvo daqui.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/provedores.dart';
import '../../l10n/app_localizations.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/modelo/controles_pedaleira.dart';
import '../../nucleo/modelo/documento_preset.dart';
import '../../nucleo/modelo/edicao_controles.dart';
import '../tema/tokens.dart';
import '../textos.dart';

class AlvoNaTela {
  const AlvoNaTela({required this.alvo, required this.parametro, this.bloco});

  final AlvoControle alvo;

  /// Nula quando a casa apontada está vazia (preset editado à mão).
  final DefinicaoBloco? bloco;

  /// O parâmetro com a faixa do catálogo; sem catálogo, a faixa gravada.
  final DefinicaoParametro parametro;

  /// Sem faixa no arquivo vale a do parâmetro (o controle varre tudo).
  num get minimo => alvo.minimo ?? parametro.minimo;
  num get maximo => alvo.maximo ?? parametro.maximo;

  /// A fita da família só existe onde há bloco.
  Color? get cor => bloco == null ? null : Cores.daFamilia(bloco!.familia);

  /// "Wah · Position", ou a casa vazia.
  String descricao(AppLocalizations l) {
    final definicao = bloco;
    if (definicao == null) return l.ctlCasaVazia(alvo.posicao.linha, alvo.posicao.casa);
    final nomeParametro = alvo.ehBypass ? l.ctlLigaDesliga : parametro.nome;
    return '${l.nomeDoBloco(definicao)} · $nomeParametro';
  }

  static AlvoNaTela de(WidgetRef ref, DocumentoPreset documento, AlvoControle alvo) {
    final uri = documento.bloco(alvo.posicao)?.uri;
    final bloco = uri == null ? null : ref.watch(definicaoBlocoProvider(uri));
    final doCatalogo = alvo.ehBypass ? parametroBypass : bloco?.parametro(alvo.simbolo);
    return AlvoNaTela(alvo: alvo, bloco: bloco, parametro: doCatalogo ?? _faixaGravada(alvo));
  }

  /// Parâmetro fora do catálogo (bloco do Marketplace): a faixa é a gravada.
  static DefinicaoParametro _faixaGravada(AlvoControle alvo) {
    final minimo = alvo.minimo ?? 0;
    final maximo = alvo.maximo ?? 1;
    return DefinicaoParametro(
        simbolo: alvo.simbolo,
        nome: alvo.simbolo,
        minimo: math.min(minimo, maximo),
        maximo: math.max(minimo, maximo),
        padrao: minimo);
  }
}

/// A fita de 4 px na cor da família, com a descrição do alvo embaixo.
class FitaDoAlvo extends StatelessWidget {
  const FitaDoAlvo({super.key, required this.alvo, this.estilo});

  final AlvoNaTela alvo;
  final TextStyle? estilo;

  @override
  Widget build(BuildContext context) {
    final cor = alvo.cor;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
      if (cor != null) Container(height: Medidas.fitaCategoria, color: cor),
      const SizedBox(height: Espacos.xxs),
      Text(alvo.descricao(AppLocalizations.of(context)),
          maxLines: 2, overflow: TextOverflow.ellipsis, style: estilo ?? Theme.of(context).textTheme.labelSmall),
    ]);
  }
}
