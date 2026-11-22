// A fita gaffer creme com a borda de baixo mais escura (espessura de fita
// colada): o nome do preset na faixa do editor e o nome do app na tela de
// conectar. Só existe onde há nome escrito a marcador.
import 'package:flutter/material.dart';

import '../tema/tokens.dart';

class FitaGaffer extends StatelessWidget {
  const FitaGaffer({super.key, required this.child, this.medidas = MedidasDoTopo.toque});

  final Widget child;

  /// A fita do editor segue o tamanho do topo da plataforma; a da tela de
  /// conectar é a vitrine do app e fica no tamanho cheio.
  final MedidasDoTopo medidas;

  @override
  Widget build(BuildContext context) => Container(
        constraints: BoxConstraints(minHeight: medidas.fita),
        padding: EdgeInsets.symmetric(horizontal: Espacos.l, vertical: medidas.folgaFita),
        decoration: BoxDecoration(
          color: context.cores.fitaGaffer,
          border: Border(bottom: BorderSide(color: context.cores.fitaGafferSombra, width: Medidas.contornoSelecao)),
        ),
        child: child,
      );
}
