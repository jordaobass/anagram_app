// Menu de uma casa: adicionar efeito (vazia), copiar, colar, ligar/desligar,
// mover e remover. Abre pelo botão direito e pelo botão "mais ações" do painel;
// o "mover" serve a quem não arrasta (teclado, leitor de tela, toque difícil).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../../nucleo/catalogo/biblioteca_blocos.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../../nucleo/modelo/documento_preset.dart';
import 'acoes_roteamento.dart';
import 'biblioteca_efeitos.dart';
import '../../l10n/app_localizations.dart';

enum _AcaoMenu { adicionar, copiar, colar, bypass, esquerda, direita, outraLinha, remover }

Future<void> abrirMenuBloco(BuildContext context, WidgetRef ref, PosicaoBloco posicao, Offset ponto) async {
  final estado = ref.read(editorProvider);
  final documento = estado.atual;
  if (documento == null) return;
  final acao = await showMenu<_AcaoMenu>(
    context: context,
    position: RelativeRect.fromLTRB(ponto.dx, ponto.dy, ponto.dx, ponto.dy),
    items: _itens(AppLocalizations.of(context), documento, posicao, temCopia: estado.blocoCopiado != null),
  );
  if (acao == null || !context.mounted) return;
  await _executar(context, ref, acao, posicao);
}

List<PopupMenuEntry<_AcaoMenu>> _itens(AppLocalizations l, DocumentoPreset documento, PosicaoBloco posicao,
    {required bool temCopia}) {
  final bloco = documento.bloco(posicao);
  final temBloco = bloco != null;
  // split e merge marcam onde a linha paralela sai e volta: colar por cima
  // ou duplicá-los quebraria o roteamento sem a pessoa perceber
  final roteamento = bloco != null && ehBlocoDeRoteamento(bloco.uri);
  PopupMenuItem<_AcaoMenu> item(_AcaoMenu acao, String rotulo, {bool ativo = true}) =>
      PopupMenuItem(value: acao, enabled: ativo, child: Text(rotulo));
  bool podeIr(_AcaoMenu acao) => podeMover(documento, posicao, _destino(posicao, acao));
  return [
    if (!temBloco) item(_AcaoMenu.adicionar, l.adicionarEfeitoMenu),
    item(_AcaoMenu.copiar, l.copiarBloco, ativo: temBloco && !roteamento),
    item(_AcaoMenu.colar, l.colarAqui, ativo: temCopia && !roteamento),
    item(_AcaoMenu.bypass, l.ligarDesligar, ativo: temBloco),
    if (temBloco) ...[
      const PopupMenuDivider(),
      item(_AcaoMenu.esquerda, l.moverEsquerda, ativo: podeIr(_AcaoMenu.esquerda)),
      item(_AcaoMenu.direita, l.moverDireita, ativo: podeIr(_AcaoMenu.direita)),
      item(_AcaoMenu.outraLinha, l.moverParaLinha(posicao.linha == 1 ? 2 : 1), ativo: podeIr(_AcaoMenu.outraLinha)),
      const PopupMenuDivider(),
    ],
    item(_AcaoMenu.remover, l.removerBloco, ativo: temBloco),
  ];
}

/// Casa vizinha para onde cada "mover" leva; fora da grade vale a própria
/// casa, que [podeMover] recusa.
PosicaoBloco _destino(PosicaoBloco de, _AcaoMenu acao) {
  final destino = switch (acao) {
    _AcaoMenu.esquerda => PosicaoBloco(de.linha, de.casa - 1),
    _AcaoMenu.direita => PosicaoBloco(de.linha, de.casa + 1),
    _AcaoMenu.outraLinha => PosicaoBloco(de.linha == 1 ? 2 : 1, de.casa),
    _ => de,
  };
  return destino.casa >= 1 && destino.casa <= PosicaoBloco.casasPorLinha ? destino : de;
}

Future<void> _executar(BuildContext context, WidgetRef ref, _AcaoMenu acao, PosicaoBloco posicao) async {
  final controlador = ref.read(editorProvider.notifier);
  switch (acao) {
    case _AcaoMenu.adicionar:
      await adicionarEfeitoNaCasa(context, ref, posicao);
    case _AcaoMenu.copiar:
      controlador.copiarBloco(posicao);
    case _AcaoMenu.colar:
      await controlador.colarBloco(posicao);
    case _AcaoMenu.bypass:
      await controlador.alternarBypass(posicao);
    case _AcaoMenu.esquerda || _AcaoMenu.direita || _AcaoMenu.outraLinha:
      await controlador.moverBloco(posicao, _destino(posicao, acao));
    case _AcaoMenu.remover:
      await removerBlocoComAviso(context, ref, posicao);
  }
}
