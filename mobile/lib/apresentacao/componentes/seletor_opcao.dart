// Parâmetro de opções num botão com a escolha atual escrita: no knob, "VMT
// Turbo Midboost 2" só se lia girando. Poucas opções abrem um menu; muitas
// (os 37 drives do Entropia), uma lista com busca e grupos pela família.
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../nucleo/catalogo/arranjo_multibanda.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../tema/tokens.dart';
import 'item_de_menu.dart';
import 'dialogo_confirmar.dart';
import 'botao_giratorio.dart' show AoMudarValor;

class SeletorOpcao extends StatelessWidget {
  const SeletorOpcao({
    super.key,
    required this.parametro,
    required this.valor,
    required this.cor,
    required this.largura,
    required this.aoMudar,
    this.rotulo,
  });

  final DefinicaoParametro parametro;
  final num valor;
  final Color cor;
  final double largura;
  final AoMudarValor aoMudar;
  final String? rotulo;

  @override
  Widget build(BuildContext context) {
    final atual = parametro.indiceOpcao(valor);
    final tema = Theme.of(context).textTheme;
    return SizedBox(
      width: largura,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text((rotulo ?? parametro.nome).toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: tema.labelMedium),
        const SizedBox(height: Espacos.xs),
        Semantics(
          button: true,
          label: parametro.nome,
          value: parametro.opcoes[atual],
          child: OutlinedButton(
            key: ValueKey('abrir-${parametro.simbolo}'),
            onPressed: () => _escolher(context, atual),
            style: OutlinedButton.styleFrom(side: BorderSide(color: cor), minimumSize: const Size.fromHeight(Medidas.alvoMinimo)),
            child: Row(children: [
              Expanded(child: Text(parametro.opcoes[atual], maxLines: 1, overflow: TextOverflow.ellipsis)),
              const Icon(Icons.arrow_drop_down),
            ]),
          ),
        ),
      ]),
    );
  }

  Future<void> _escolher(BuildContext context, int atual) async {
    final escolhida = await escolherOpcao(context, parametro, atual);
    if (escolhida != null && escolhida != atual) aoMudar(parametro.valorDaOpcao(escolhida), arrastando: false);
  }
}

/// Todas as opções: poucas num menu logo embaixo de [context], com a atual
/// marcada; muitas, numa lista com busca e grupos. Nulo se a pessoa desistir.
Future<int?> escolherOpcao(BuildContext context, DefinicaoParametro parametro, int atual) =>
    parametro.opcoes.length > Medidas.opcoesSemBusca
        ? showDialog<int>(context: context, builder: (_) => _ListaComBusca(parametro: parametro, atual: atual))
        : _menu(context, parametro, atual);

Future<int?> _menu(BuildContext context, DefinicaoParametro parametro, int atual) {
  final caixa = context.findRenderObject()! as RenderBox;
  final canto = caixa.localToGlobal(Offset(0, caixa.size.height));
  return showMenu<int>(
    context: context,
    position: RelativeRect.fromLTRB(canto.dx, canto.dy, canto.dx + caixa.size.width, canto.dy),
    constraints: BoxConstraints(minWidth: caixa.size.width),
    items: [
      for (var i = 0; i < parametro.opcoes.length; i++)
        itemMarcado(i,
            key: ValueKey('opcao-${parametro.simbolo}-$i'), rotulo: parametro.opcoes[i], marcado: i == atual),
    ],
  );
}

class _ListaComBusca extends StatefulWidget {
  const _ListaComBusca({required this.parametro, required this.atual});

  final DefinicaoParametro parametro;
  final int atual;

  @override
  State<_ListaComBusca> createState() => _EstadoListaComBusca();
}

class _EstadoListaComBusca extends State<_ListaComBusca> {
  String _busca = '';

  /// A busca casa todas as palavras, em qualquer ordem: "turbo grunt".
  bool _casa(String opcao) {
    final texto = opcao.toLowerCase();
    return _busca.toLowerCase().split(' ').where((p) => p.isNotEmpty).every(texto.contains);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final grupos = agruparOpcoes(widget.parametro.opcoes);
    return AlertDialog(
      title: Text(widget.parametro.nome),
      content: SizedBox(
        width: Medidas.larguraDialogo,
        height: Medidas.alturaListaOpcoes,
        child: Column(children: [
          TextField(
            key: const ValueKey('buscar-opcao'),
            autofocus: true,
            decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l.mbBuscarOpcao),
            onChanged: (texto) => setState(() => _busca = texto),
          ),
          const SizedBox(height: Espacos.s),
          Expanded(child: ListView(children: [for (final g in grupos.entries) ..._grupo(context, g.key, g.value)])),
        ]),
      ),
      actions: [BotaoCancelarDialogo(rotulo: l.cancelar, aoTocar: () => Navigator.pop(context))],
    );
  }

  List<Widget> _grupo(BuildContext context, String nome, List<(int, String)> opcoes) {
    final visiveis = [for (final o in opcoes) if (_casa(o.$2)) o];
    if (visiveis.isEmpty) return const [];
    return [
      Padding(
        padding: const EdgeInsets.only(top: Espacos.s, bottom: Espacos.xs),
        child: Text(nome.toUpperCase(),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Cores.textoSecundario)),
      ),
      for (final (indice, opcao) in visiveis)
        ListTile(
          key: ValueKey('opcao-${widget.parametro.simbolo}-$indice'),
          dense: true,
          title: Text(opcao),
          selected: indice == widget.atual,
          trailing: indice == widget.atual ? const Icon(Icons.check) : null,
          onTap: () => Navigator.pop(context, indice),
        ),
    ];
  }
}
