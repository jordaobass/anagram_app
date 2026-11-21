// Grupo de escolha em botões, no mesmo estilo das opções dos parâmetros
// (Less/More, Low/Mid/High): o marcado cheio na cor do bloco, os outros com
// contorno. Usado no gabinete para microfone e posição.
import 'package:flutter/material.dart';

import '../tema/tokens.dart';

class EscolhaEmBotoes extends StatelessWidget {
  const EscolhaEmBotoes({
    super.key,
    required this.rotulo,
    required this.prefixoChave,
    required this.opcoes,
    required this.atual,
    required this.cor,
    required this.aoEscolher,
    this.icone,
  });

  final String rotulo;
  final String prefixoChave;
  final List<String> opcoes;
  final String? atual;
  final Color cor;
  final void Function(String) aoEscolher;
  final Widget Function(String opcao, bool marcada)? icone;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(rotulo.toUpperCase(), style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: Espacos.xs),
        Wrap(spacing: Espacos.xs, runSpacing: Espacos.xs, children: [for (final o in opcoes) _botao(o, o == atual)]),
      ]);

  Widget _botao(String opcao, bool marcada) {
    void tocar() {
      if (!marcada) aoEscolher(opcao);
    }

    final conteudo = Row(mainAxisSize: MainAxisSize.min, children: [
      if (icone != null) ...[icone!(opcao, marcada), const SizedBox(width: Espacos.xs)],
      Text(opcao, maxLines: 1),
    ]);
    return Semantics(
      key: ValueKey('$prefixoChave-$opcao'),
      selected: marcada,
      button: true,
      child: marcada
          ? FilledButton(
              onPressed: tocar,
              style: FilledButton.styleFrom(backgroundColor: cor, foregroundColor: Cores.tintaMarcador),
              child: conteudo,
            )
          : OutlinedButton(onPressed: tocar, child: conteudo),
    );
  }
}
