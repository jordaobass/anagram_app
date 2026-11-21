// Lista completa de uma escolha do gabinete, aberta ao tocar no cartão: os
// modelos em grade, com a foto de cada caixa e uma busca por texto no topo
// ("peg" acha os Peggy); microfone e posição, em lista. A opção atual vem
// marcada e escolher fecha a lista devolvendo a opção.
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../tema/tokens.dart';

Future<String?> abrirGaleriaDeEscolha(
  BuildContext context, {
  required String titulo,
  required List<String> opcoes,
  required String? atual,
  Widget Function(String opcao)? visual,
  bool emGrade = false,
}) =>
    showDialog<String>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Cores.painelElevado,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Medidas.larguraBiblioteca, maxHeight: Medidas.alturaBiblioteca),
          child: _GaleriaEscolha(titulo: titulo, opcoes: opcoes, atual: atual, visual: visual, emGrade: emGrade),
        ),
      ),
    );

class _GaleriaEscolha extends StatefulWidget {
  const _GaleriaEscolha({
    required this.titulo,
    required this.opcoes,
    required this.atual,
    required this.visual,
    required this.emGrade,
  });

  final String titulo;
  final List<String> opcoes;
  final String? atual;
  final Widget Function(String opcao)? visual;
  /// Em grade vem a busca: são os modelos, a lista longa (23 no baixo).
  final bool emGrade;

  @override
  State<_GaleriaEscolha> createState() => _EstadoGaleriaEscolha();
}

class _EstadoGaleriaEscolha extends State<_GaleriaEscolha> {
  String _termo = '';

  List<String> get _visiveis {
    final termo = _termo.trim().toLowerCase();
    return termo.isEmpty ? widget.opcoes : widget.opcoes.where((o) => o.toLowerCase().contains(termo)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final visiveis = _visiveis;
    return Padding(
      padding: const EdgeInsets.all(Espacos.l),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
        Text(widget.titulo.toUpperCase(), style: Theme.of(context).textTheme.titleSmall),
        if (widget.emGrade) ...[
          const SizedBox(height: Espacos.s),
          TextField(
            key: const ValueKey('galeria-busca'),
            autofocus: true,
            onChanged: (texto) => setState(() => _termo = texto),
            decoration: InputDecoration(isDense: true, hintText: l.gvBuscar, prefixIcon: const Icon(Icons.search)),
          ),
        ],
        const SizedBox(height: Espacos.m),
        Flexible(
          child: visiveis.isEmpty
              ? Text(l.gvNadaEncontrado, textAlign: TextAlign.center)
              : widget.emGrade
                  ? _grade(visiveis)
                  : _lista(visiveis),
        ),
      ]),
    );
  }

  Widget _grade(List<String> opcoes) => GridView.extent(
        shrinkWrap: true,
        maxCrossAxisExtent: Medidas.larguraItemGaleria,
        mainAxisSpacing: Espacos.s,
        crossAxisSpacing: Espacos.s,
        childAspectRatio: Medidas.proporcaoItemGaleria,
        children: [for (final o in opcoes) _itemDaGrade(o)],
      );

  Widget _itemDaGrade(String opcao) {
    final marcada = opcao == widget.atual;
    return Semantics(
      selected: marcada,
      child: Material(
        color: marcada ? Cores.painel : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Raios.controle),
          side: BorderSide(
              color: marcada ? Cores.tally : Cores.filete,
              width: marcada ? Medidas.contornoSelecao : Medidas.filete),
        ),
        child: InkWell(
          key: ValueKey('opcao-$opcao'),
          onTap: () => Navigator.of(context).pop(opcao),
          child: Padding(
            padding: const EdgeInsets.all(Espacos.xs),
            child: Column(children: [
              Expanded(child: Center(child: widget.visual?.call(opcao))),
              Text(opcao, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _lista(List<String> opcoes) => ListView(shrinkWrap: true, children: [
        for (final o in opcoes)
          ListTile(
            key: ValueKey('opcao-$o'),
            leading: widget.visual?.call(o),
            title: Text(o),
            selected: o == widget.atual,
            selectedColor: Cores.tally,
            onTap: () => Navigator.of(context).pop(o),
          ),
      ]);
}
