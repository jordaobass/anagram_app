// Um cartão de seção do painel do synth: título (e a chave, no arpejador),
// o desenho da seção quando ela tem um e os controles embaixo. Seção
// desligada continua ajustável, só apagada, como a banda desligada do EQ.
import 'package:flutter/material.dart';

import '../tema/tokens.dart';

class CartaoSecaoSynth extends StatelessWidget {
  const CartaoSecaoSynth({
    super.key,
    required this.titulo,
    required this.largura,
    required this.filhos,
    this.chave,
    this.desenho,
    this.apagada = false,
    this.alinharTopo = false,
  });

  final String titulo;
  final double largura;
  final Widget? chave;
  final Widget? desenho;
  final bool apagada;

  /// Colunas (os osciladores) alinham pelo topo; controles soltos, pela base,
  /// para os valores ficarem na mesma linha.
  final bool alinharTopo;
  final List<Widget> filhos;

  @override
  Widget build(BuildContext context) => Container(
        width: largura,
        padding: const EdgeInsets.all(Espacos.m),
        decoration: BoxDecoration(
          color: context.cores.painel,
          borderRadius: BorderRadius.circular(Raios.painel),
          border: Border.all(color: context.cores.filete),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Expanded(child: Text(titulo.toUpperCase(), style: Theme.of(context).textTheme.titleSmall)),
            ?chave,
          ]),
          const SizedBox(height: Espacos.s),
          Opacity(
            opacity: apagada ? Medidas.opacidadeBandaDesligada : 1,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
              if (desenho != null) ...[desenho!, if (filhos.isNotEmpty) const SizedBox(height: Espacos.m)],
              Wrap(
                alignment: WrapAlignment.spaceEvenly,
                crossAxisAlignment: alinharTopo ? WrapCrossAlignment.start : WrapCrossAlignment.end,
                spacing: Espacos.s,
                runSpacing: Espacos.m,
                children: filhos,
              ),
            ]),
          ),
        ]),
      );
}
