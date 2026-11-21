// Um alvo no diálogo do controle: o bloco e o parâmetro na fita da família,
// o mínimo e o máximo no mesmo controle de valor do painel (knob, chave ou
// opções, com a escala do parâmetro) e o botão de tirar o alvo.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../../l10n/app_localizations.dart';
import '../../nucleo/modelo/controles_pedaleira.dart';
import '../../nucleo/modelo/edicao_controles.dart';
import '../tema/tokens.dart';
import 'alvo_do_controle.dart';
import 'controle_parametro.dart';

class LinhaAlvoControle extends ConsumerStatefulWidget {
  const LinhaAlvoControle({super.key, required this.id, required this.indice, required this.alvo});

  final IdControle id;
  final int indice;
  final AlvoNaTela alvo;

  @override
  ConsumerState<LinhaAlvoControle> createState() => _EstadoLinhaAlvo();
}

class _EstadoLinhaAlvo extends ConsumerState<LinhaAlvoControle> {
  RecusaFaixa? _recusa;

  Future<void> _mudar(num minimo, num maximo) async {
    final recusa = await ref
        .read(editorProvider.notifier)
        .mudarFaixa(widget.id, widget.indice, widget.alvo.parametro, minimo, maximo);
    if (mounted) setState(() => _recusa = recusa);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tema = Theme.of(context).textTheme;
    final recusa = _recusa;
    return Padding(
      key: ValueKey('alvo-${widget.indice}'),
      padding: const EdgeInsets.only(top: Espacos.m),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          Expanded(child: FitaDoAlvo(alvo: widget.alvo, estilo: tema.labelMedium)),
          IconButton(
            key: ValueKey('remover-alvo-${widget.indice}'),
            tooltip: l.ctlRemoverAlvo,
            icon: const Icon(Icons.link_off),
            onPressed: () => ref.read(editorProvider.notifier).removerAlvoDoControle(widget.id, widget.indice),
          ),
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.start, children: [
          _extremo(l.ctlMinimo, widget.alvo.minimo, (valor) => _mudar(valor, widget.alvo.maximo), 'minimo'),
          _extremo(l.ctlMaximo, widget.alvo.maximo, (valor) => _mudar(widget.alvo.minimo, valor), 'maximo'),
        ]),
        if (recusa != null)
          Text(recusa == RecusaFaixa.iguais ? l.ctlFaixaIguais : l.ctlFaixaFora,
              style: tema.labelMedium?.copyWith(color: Cores.erro)),
      ]),
    );
  }

  /// O knob manda o valor ao soltar: arrastando, só o desenho acompanha.
  Widget _extremo(String rotulo, num valor, ValueChanged<num> aoSoltar, String chave) => KeyedSubtree(
        key: ValueKey('$chave-${widget.indice}'),
        child: ControleParametro(
          parametro: widget.alvo.parametro,
          rotulo: rotulo,
          valor: valor,
          cor: widget.alvo.cor ?? Cores.aluminio,
          tamanho: Medidas.knobFaixaControle,
          aoMudar: (novo, {required arrastando}) {
            if (!arrastando) aoSoltar(novo);
          },
        ),
      );
}
