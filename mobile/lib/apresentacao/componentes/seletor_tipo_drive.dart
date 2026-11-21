// O Drive TypeMode do Entropia em dois botões, como na pedaleira: o tipo
// (B3K, VMT, Alpha…) e o modo daquele tipo (Flat, Grunt, Both…). Os dois
// gravam o mesmo parâmetro, pelo índice da opção do catálogo.
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/catalogo/tipos_de_drive.dart';
import '../tema/tokens.dart';
import 'botao_giratorio.dart' show AoMudarValor;

class SeletorTipoDrive extends StatelessWidget {
  const SeletorTipoDrive({
    super.key,
    required this.parametro,
    required this.valor,
    required this.cor,
    required this.largura,
    required this.aoMudar,
  });

  final DefinicaoParametro parametro;
  final num valor;
  final Color cor;
  final double largura;
  final AoMudarValor aoMudar;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tipos = TiposDeDrive(parametro.opcoes);
    final atual = parametro.indiceOpcao(valor);
    final (tipo, modo) = tipos.doIndice(atual);
    final modos = tipos.modos(tipo);
    void gravar(int indice) {
      if (indice != atual) aoMudar(parametro.valorDaOpcao(indice), arrastando: false);
    }

    return SizedBox(
      width: largura,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
        _BotaoMenu(
          chave: 'tipo-${parametro.simbolo}',
          rotulo: l.mbTipoDrive,
          opcoes: tipos.tipos,
          atual: tipo,
          cor: cor,
          aoEscolher: (novo) => gravar(tipos.trocarTipo(atual, novo)),
        ),
        const SizedBox(height: Espacos.s),
        _BotaoMenu(
          chave: 'modo-${parametro.simbolo}',
          rotulo: l.mbModoDrive,
          opcoes: modos,
          atual: modo ?? '—',
          cor: cor,
          aoEscolher: modos.isEmpty ? null : (novo) => gravar(tipos.indice(tipo, novo)!),
        ),
      ]),
    );
  }
}

/// Um seletor: o rótulo em cima e um botão com a escolha que abre o menu.
class _BotaoMenu extends StatelessWidget {
  const _BotaoMenu({
    required this.chave,
    required this.rotulo,
    required this.opcoes,
    required this.atual,
    required this.cor,
    required this.aoEscolher,
  });

  final String chave;
  final String rotulo;
  final List<String> opcoes;
  final String atual;
  final Color cor;

  /// Nulo: sem escolha (o Bypass não tem modo).
  final ValueChanged<String>? aoEscolher;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text(rotulo.toUpperCase(), style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: Espacos.xs),
        Semantics(
          button: true,
          label: rotulo,
          value: atual,
          child: OutlinedButton(
            key: ValueKey('abrir-$chave'),
            onPressed: aoEscolher == null ? null : () => _abrir(context),
            style: OutlinedButton.styleFrom(side: BorderSide(color: cor), minimumSize: const Size.fromHeight(Medidas.alvoMinimo)),
            child: Row(children: [
              Expanded(child: Text(atual, maxLines: 1, overflow: TextOverflow.ellipsis)),
              const Icon(Icons.arrow_drop_down),
            ]),
          ),
        ),
      ]);

  Future<void> _abrir(BuildContext context) async {
    final caixa = context.findRenderObject()! as RenderBox;
    final canto = caixa.localToGlobal(Offset(0, caixa.size.height));
    final escolha = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(canto.dx, canto.dy, canto.dx + caixa.size.width, canto.dy),
      constraints: BoxConstraints(minWidth: caixa.size.width),
      items: [
        for (final o in opcoes)
          CheckedPopupMenuItem<String>(key: ValueKey('$chave-$o'), value: o, checked: o == atual, child: Text(o)),
      ],
    );
    if (escolha != null && escolha != atual) aoEscolher?.call(escolha);
  }
}
