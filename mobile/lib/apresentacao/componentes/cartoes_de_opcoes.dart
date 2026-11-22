// Montagem comum dos cartões de escolha (gabinete, tom do TONE3000): o
// cartão de uma lista de opções, com as setas passando para a vizinha que
// pode ser escolhida e a galeria ao tocar no meio, e a fileira que os põe
// lado a lado no computador e empilhados no celular.
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../tema/tokens.dart';
import 'cartao_escolha.dart';
import 'galeria_escolha.dart';

class CartaoDeOpcoes extends StatelessWidget {
  const CartaoDeOpcoes({
    super.key,
    required this.chave,
    required this.rotulo,
    required this.opcoes,
    required this.atual,
    required this.noCartao,
    required this.aoEscolher,
    this.visual,
    this.emGrade = false,
    this.detalhe,
    this.habilitada,
  });

  final String chave;
  final String rotulo;
  final List<String> opcoes;
  final String? atual;
  final Widget noCartao;
  final void Function(String) aoEscolher;
  final Widget Function(String)? visual;
  final bool emGrade;

  /// Linha de apoio de cada opção na galeria (autor, licença…).
  final String? Function(String)? detalhe;

  /// Opção que só se consulta: aparece na galeria sem ser escolhível e as setas pulam.
  final bool Function(String)? habilitada;

  bool _pode(String opcao) => habilitada?.call(opcao) ?? true;

  /// A vizinha escolhível de [de] no sentido [passo]; nula na ponta.
  VoidCallback? _passo(int de, int passo) {
    for (var i = de + passo; i >= 0 && i < opcoes.length; i += passo) {
      if (_pode(opcoes[i])) return () => aoEscolher(opcoes[i]);
    }
    return null;
  }

  Future<void> _abrir(BuildContext context) async {
    final escolhida = await abrirGaleriaDeEscolha(context,
        titulo: rotulo,
        opcoes: opcoes,
        atual: atual,
        visual: visual,
        emGrade: emGrade,
        detalhe: detalhe,
        habilitada: habilitada);
    if (escolhida != null && escolhida != atual && _pode(escolhida)) aoEscolher(escolhida);
  }

  @override
  Widget build(BuildContext context) {
    final i = opcoes.indexOf(atual ?? '');
    return CartaoEscolha(
      chave: chave,
      rotulo: rotulo,
      nome: atual ?? AppLocalizations.of(context).cbEscolher,
      visual: noCartao,
      aoAbrir: () => _abrir(context),
      aoAnterior: i < 0 ? null : _passo(i, -1),
      aoProximo: _passo(i, 1),
    );
  }
}

/// [vagas] cartões por linha a partir de [Medidas.larguraGabineteLadoALado]:
/// com menos cartões, os que há não esticam. Abaixo, um embaixo do outro.
class FileiraDeCartoes extends StatelessWidget {
  const FileiraDeCartoes({super.key, required this.cartoes, required this.vagas});

  final List<Widget> cartoes;
  final int vagas;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
      builder: (context, restricoes) => restricoes.maxWidth >= Medidas.larguraGabineteLadoALado ? _lado() : _empilhados());

  Widget _lado() => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (var i = 0; i < vagas; i++) ...[
          if (i > 0) const SizedBox(width: Espacos.m),
          Expanded(child: i < cartoes.length ? cartoes[i] : const SizedBox.shrink()),
        ],
      ]);

  Widget _empilhados() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        for (var i = 0; i < cartoes.length; i++) ...[
          if (i > 0) const SizedBox(height: Espacos.s),
          cartoes[i],
        ],
      ]);
}
