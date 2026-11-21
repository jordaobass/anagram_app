// Escolha do modelo do gabinete: campo em que se escreve parte do nome
// ("peg" acha os Peggy), com a foto de cada um na lista, e setas ‹ › para
// passar pelos modelos um a um, ouvindo cada caixa.
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../tema/tokens.dart';

class CampoModeloGabinete extends StatefulWidget {
  const CampoModeloGabinete({
    super.key,
    required this.rotulo,
    required this.modelos,
    required this.atual,
    required this.foto,
    required this.aoEscolher,
  });

  final String rotulo;
  final List<String> modelos;
  final String? atual;
  final Widget Function(String modelo) foto;
  final void Function(String modelo) aoEscolher;

  @override
  State<CampoModeloGabinete> createState() => _EstadoCampoModelo();
}

class _EstadoCampoModelo extends State<CampoModeloGabinete> {
  late final TextEditingController _texto = TextEditingController(text: widget.atual ?? '');
  final _foco = FocusNode();

  @override
  void didUpdateWidget(CampoModeloGabinete antigo) {
    super.didUpdateWidget(antigo);
    // o modelo mudou por fora (setas, desfazer): o campo mostra o novo
    if (widget.atual != antigo.atual && !_foco.hasFocus) _texto.text = widget.atual ?? '';
  }

  @override
  void dispose() {
    _texto.dispose();
    _foco.dispose();
    super.dispose();
  }

  void _passo(int quanto) {
    final i = widget.modelos.indexOf(widget.atual ?? '');
    final destino = (i + quanto).clamp(0, widget.modelos.length - 1);
    if (destino != i) widget.aoEscolher(widget.modelos[destino]);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final i = widget.modelos.indexOf(widget.atual ?? '');
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(widget.rotulo.toUpperCase(), style: Theme.of(context).textTheme.labelMedium),
      Row(children: [
        IconButton(
          key: const ValueKey('gabinete-anterior'),
          tooltip: l.gxModeloAnterior,
          onPressed: i > 0 ? () => _passo(-1) : null,
          icon: const Icon(Icons.chevron_left),
        ),
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Medidas.larguraCampoGabinete),
            child: _busca(l),
          ),
        ),
        IconButton(
          key: const ValueKey('gabinete-proximo'),
          tooltip: l.gxProximoModelo,
          onPressed: i >= 0 && i < widget.modelos.length - 1 ? () => _passo(1) : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ]),
    ]);
  }

  Widget _busca(AppLocalizations l) => RawAutocomplete<String>(
        key: const ValueKey('gabinete-modelo'),
        textEditingController: _texto,
        focusNode: _foco,
        optionsBuilder: (valor) => _filtrar(valor.text),
        onSelected: (modelo) {
          _foco.unfocus();
          if (modelo != widget.atual) widget.aoEscolher(modelo);
        },
        fieldViewBuilder: (context, controlador, foco, aoEnviar) => TextField(
          controller: controlador,
          focusNode: foco,
          onSubmitted: (_) => aoEnviar(),
          // ao entrar, seleciona tudo: começar a escrever já busca
          onTap: () => controlador.selection = TextSelection(baseOffset: 0, extentOffset: controlador.text.length),
          decoration: InputDecoration(isDense: true, hintText: l.gxBuscarGabinete, prefixIcon: const Icon(Icons.search)),
        ),
        optionsViewBuilder: (context, aoEscolher, opcoes) => _lista(aoEscolher, opcoes),
      );

  /// Com o próprio nome no campo (nada digitado ainda), mostra todos.
  Iterable<String> _filtrar(String texto) {
    final termo = texto.trim().toLowerCase();
    if (termo.isEmpty || texto == widget.atual) return widget.modelos;
    return widget.modelos.where((m) => m.toLowerCase().contains(termo));
  }

  Widget _lista(void Function(String) aoEscolher, Iterable<String> opcoes) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: Espacos.xs,
          color: Cores.painelElevado,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Medidas.larguraCampoGabinete, maxHeight: Medidas.alturaBiblioteca / 2),
            child: ListView(shrinkWrap: true, padding: EdgeInsets.zero, children: [
              for (final modelo in opcoes)
                ListTile(
                  key: ValueKey('sugestao-$modelo'),
                  dense: true,
                  leading: widget.foto(modelo),
                  title: Text(modelo),
                  selected: modelo == widget.atual,
                  onTap: () => aoEscolher(modelo),
                ),
            ]),
          ),
        ),
      );
}
