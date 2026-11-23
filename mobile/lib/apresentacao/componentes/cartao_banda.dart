// Moldura de uma banda do paramétrico: título e chave em cima, controles
// embaixo. Banda desligada continua ajustável, só apagada, para dar para
// preparar o ajuste antes de ligar.
import 'package:flutter/material.dart';

import '../tema/tokens.dart';

class CartaoBanda extends StatelessWidget {
  const CartaoBanda({
    super.key,
    required this.titulo,
    required this.chave,
    required this.ligada,
    required this.controles,
  });

  final String? titulo;
  final Widget? chave;
  final bool ligada;
  final List<Widget> controles;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(Espacos.m),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Raios.painel),
          border: Border.all(color: context.cores.filete),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (titulo != null || chave != null)
            Row(mainAxisSize: MainAxisSize.min, children: [
              // janela estreita: o título encolhe antes de empurrar a chave para fora
              if (titulo != null)
                Flexible(
                  child: Text(titulo!.toUpperCase(),
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleSmall),
                ),
              if (chave != null) ...[const SizedBox(width: Espacos.m), chave!],
            ]),
          const SizedBox(height: Espacos.s),
          Opacity(
            opacity: ligada ? 1 : Medidas.opacidadeBandaDesligada,
            child: Wrap(spacing: Espacos.s, runSpacing: Espacos.m, children: controles),
          ),
        ]),
      );
}
