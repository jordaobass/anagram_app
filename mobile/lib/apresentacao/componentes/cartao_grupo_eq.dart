// Partes do painel do Parametric EQ que o Global EQ não tem: a chave de cada
// seção (LSsec, sec1–4, HSsec, HighPass, LowPass) e o cartão de um grupo com
// a chave no título e os knobs de nome curto (os cortes e o ganho geral).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../nucleo/catalogo/arranjo_parametros.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../tema/tokens.dart';
import '../textos.dart';
import 'cartao_banda.dart';
import 'controle_no_painel.dart';
import 'controle_parametro.dart';

/// Liga/desliga de uma seção do bloco, pelo mesmo caminho dos knobs.
class ChaveDaSecao extends ConsumerWidget {
  const ChaveDaSecao(
      {super.key,
      required this.chave,
      required this.bloco,
      required this.definicao,
      required this.cena,
      this.empilhada = false});

  final DefinicaoParametro chave;

  /// Na coluna estreita da banda, o estado vai embaixo da chave.
  final bool empilhada;
  final BlocoPreset bloco;
  final DefinicaoBloco definicao;
  final int cena;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ligada = DefinicaoParametro.estaLigado(ControleNoPainel.valorNaCena(bloco, chave, cena));
    final l = AppLocalizations.of(context);
    return ChaveParametro(
      chave: ValueKey('chave-${chave.simbolo}'),
      nome: chave.nome,
      parametro: chave,
      ligado: ligada,
      cor: context.cores.daFamilia(definicao.familia),
      texto: ligada ? l.valorLigado : l.valorDesligado,
      empilhada: empilhada,
      aoMudar: (novo) => ControleNoPainel.alterar(ref, chave, bloco)(novo ? 1 : 0, arrastando: false),
    );
  }
}

/// Um grupo com título, chave e knobs de nome curto; desligado, os knobs
/// ficam apagados mas ainda se ajustam.
class CartaoGrupoEq extends StatelessWidget {
  const CartaoGrupoEq(
      {super.key, required this.grupo, required this.bloco, required this.definicao, required this.cena});

  final GrupoParametros grupo;
  final BlocoPreset bloco;
  final DefinicaoBloco definicao;
  final int cena;

  @override
  Widget build(BuildContext context) {
    final chave = grupo.chave;
    final ligada = chave == null || DefinicaoParametro.estaLigado(ControleNoPainel.valorNaCena(bloco, chave, cena));
    return CartaoBanda(
      key: ValueKey('banda-${grupo.banda?.name ?? 'outros'}'),
      titulo: grupo.banda == null ? null : AppLocalizations.of(context).nomeDaBanda(grupo.banda!),
      chave: chave == null ? null : ChaveDaSecao(chave: chave, bloco: bloco, definicao: definicao, cena: cena),
      ligada: ligada,
      controles: [
        for (final p in grupo.parametros)
          ControleNoPainel(
            parametro: p.parametro,
            rotulo: p.rotulo,
            bloco: bloco,
            definicao: definicao,
            cena: cena,
            tamanho: Medidas.knobCompacto,
          ),
      ],
    );
  }
}
