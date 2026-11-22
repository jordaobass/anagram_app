// A fita gaffer creme com a borda de baixo mais escura (espessura de fita
// colada): o nome do preset na faixa do editor e o nome do app na tela de
// conectar. Só existe onde há nome escrito a marcador.
import 'package:flutter/material.dart';

import '../tema/tokens.dart';

class FitaGaffer extends StatelessWidget {
  const FitaGaffer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minHeight: Medidas.alvoMinimo + Espacos.s),
        padding: const EdgeInsets.symmetric(horizontal: Espacos.l, vertical: Espacos.s),
        decoration: const BoxDecoration(
          color: Cores.fitaGaffer,
          border: Border(bottom: BorderSide(color: Cores.fitaGafferSombra, width: Medidas.contornoSelecao)),
        ),
        child: child,
      );
}
