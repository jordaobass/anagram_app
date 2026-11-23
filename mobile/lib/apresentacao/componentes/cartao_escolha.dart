// Cartão de uma escolha do gabinete (modelo, microfone ou posição): o rótulo
// em cima, a foto ou o ícone no meio entre as setas ‹ › e o nome embaixo.
// Os três cartões têm a mesma altura, para ficarem alinhados lado a lado.
// Tocar no meio abre a lista completa; com o cartão em foco, as setas do
// teclado passam de uma opção para a outra.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../tema/tokens.dart';

class CartaoEscolha extends StatefulWidget {
  const CartaoEscolha({
    super.key,
    required this.chave,
    required this.rotulo,
    required this.nome,
    required this.visual,
    required this.aoAbrir,
    this.aoAnterior,
    this.aoProximo,
  });

  /// Prefixo das chaves do cartão: `cartao-<chave>`, `<chave>-anterior`…
  final String chave;
  final String rotulo;
  final String nome;
  final Widget visual;
  final VoidCallback aoAbrir;
  /// Nulos na ponta da lista: a seta fica apagada.
  final VoidCallback? aoAnterior;
  final VoidCallback? aoProximo;

  @override
  State<CartaoEscolha> createState() => _EstadoCartaoEscolha();
}

class _PassoIntent extends Intent {
  const _PassoIntent(this.quanto);
  final int quanto;
}

class _EstadoCartaoEscolha extends State<CartaoEscolha> {
  bool _emFoco = false;

  static const _atalhos = {
    SingleActivator(LogicalKeyboardKey.arrowLeft): _PassoIntent(-1),
    SingleActivator(LogicalKeyboardKey.arrowRight): _PassoIntent(1),
  };

  @override
  Widget build(BuildContext context) => FocusableActionDetector(
        shortcuts: _atalhos,
        actions: {
          _PassoIntent: CallbackAction<_PassoIntent>(
              onInvoke: (passo) => (passo.quanto < 0 ? widget.aoAnterior : widget.aoProximo)?.call()),
        },
        onFocusChange: (emFoco) => setState(() => _emFoco = emFoco),
        child: Container(
          key: ValueKey('cartao-${widget.chave}'),
          height: Medidas.alturaCartaoGabinete,
          padding: const EdgeInsets.all(Espacos.s),
          decoration: BoxDecoration(
            color: context.cores.painel,
            borderRadius: BorderRadius.circular(Raios.painel),
            border: Border.all(
                color: _emFoco ? context.cores.tallyTinta : context.cores.filete,
                width: _emFoco ? Medidas.contornoSelecao : Medidas.filete),
          ),
          child: _conteudo(context),
        ),
      );

  Widget _conteudo(BuildContext context) {
    final l = AppLocalizations.of(context);
    final texto = Theme.of(context).textTheme;
    return Column(children: [
      Text(widget.rotulo.toUpperCase(), style: texto.labelMedium),
      Expanded(
        child: Row(children: [
          _seta('anterior', Icons.chevron_left, l.gvAnterior(widget.rotulo), widget.aoAnterior),
          Expanded(child: _meio(l)),
          _seta('proximo', Icons.chevron_right, l.gvProximo(widget.rotulo), widget.aoProximo),
        ]),
      ),
      SizedBox(
        height: Medidas.alturaNomeCartaoGabinete,
        child: Text(widget.nome,
            key: ValueKey('${widget.chave}-nome'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: texto.bodyMedium?.copyWith(color: context.cores.texto)),
      ),
    ]);
  }

  Widget _seta(String lado, IconData icone, String dica, VoidCallback? aoTocar) => IconButton(
        key: ValueKey('${widget.chave}-$lado'),
        tooltip: dica,
        onPressed: aoTocar,
        icon: Icon(icone),
      );

  /// A foto/ícone é o botão que abre a lista completa.
  Widget _meio(AppLocalizations l) => Semantics(
        button: true,
        label: l.gvAbrirLista(widget.rotulo, widget.nome),
        excludeSemantics: true,
        child: InkWell(
          key: ValueKey('${widget.chave}-abrir'),
          borderRadius: BorderRadius.circular(Raios.controle),
          onTap: widget.aoAbrir,
          child: Center(child: widget.visual),
        ),
      );
}
