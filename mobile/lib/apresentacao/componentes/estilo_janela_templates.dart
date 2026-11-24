// O desenho da janela de templates pelo painel de onde ela abriu: alumínio
// com tinta gravada (Ignissor, Entropia), neon com a barra azul (Axioma) ou
// o case. As tintas daqui têm par medido no teste de contraste do painel.
import 'package:flutter/material.dart';

import '../tema/paletas_painel.dart';
import '../tema/tema_painel.dart';
import '../tema/tokens.dart';

/// As cores e formas da janela, pelo painel de onde ela abriu.
class EstiloJanela {
  const EstiloJanela._({
    required this.neon,
    required this.metal,
    required this.fundo,
    required this.forma,
    required this.barra,
    required this.tintaBarra,
    required this.estiloTitulo,
    required this.tintaTexto,
  });

  factory EstiloJanela.de(BuildContext context) {
    final tema = context.temaPainel;
    final cores = context.cores;
    final titulo = Theme.of(context).textTheme.titleLarge;
    if (tema == null) {
      return EstiloJanela._(
        neon: false,
        metal: false,
        fundo: cores.painelElevado,
        forma: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Raios.painel))),
        barra: BoxDecoration(border: Border(bottom: BorderSide(color: cores.filete))),
        tintaBarra: cores.texto,
        estiloTitulo: titulo,
        tintaTexto: cores.textoSecundario,
      );
    }
    return tema.ehNeon ? EstiloJanela._neon(cores, titulo) : EstiloJanela._metal(cores, titulo);
  }

  factory EstiloJanela._neon(Paleta cores, TextStyle? titulo) => EstiloJanela._(
        neon: true,
        metal: false,
        fundo: cores.painel,
        forma: const BeveledRectangleBorder(
            side: BorderSide(color: CoresNeon.ciano, width: 2), borderRadius: BorderRadius.all(Radius.circular(10))),
        barra: const BoxDecoration(
          color: CoresNeon.barraJanela,
          border: Border(top: BorderSide(color: CoresNeon.ciano, width: 2), bottom: BorderSide(color: CoresNeon.ciano, width: 2)),
        ),
        tintaBarra: CoresNeon.sobreFaixa,
        estiloTitulo: titulo?.copyWith(fontFamily: Fontes.tecno, fontSize: 24, color: CoresNeon.sobreFaixa),
        tintaTexto: cores.textoSecundario,
      );

  factory EstiloJanela._metal(Paleta cores, TextStyle? titulo) => EstiloJanela._(
        neon: false,
        metal: true,
        // a janela do metal é de alumínio (como a tela de templates da
        // pedaleira), com tinta gravada: não depende da paleta de onde abriu
        fundo: CoresChassi.gradiente[1],
        forma: const RoundedRectangleBorder(
            side: BorderSide(color: CoresChassi.biselSombra), borderRadius: BorderRadius.all(Radius.circular(Raios.painel))),
        barra: const BoxDecoration(gradient: LinearGradient(colors: CoresChassi.gradiente, begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        tintaBarra: CoresChassi.tintaGravada,
        estiloTitulo: titulo?.copyWith(fontWeight: FontWeight.w400, letterSpacing: 4, color: CoresChassi.tintaGravada),
        tintaTexto: CoresChassi.tintaSecundariaGravada,
      );

  final bool neon;
  final bool metal;
  final Color fundo;
  final ShapeBorder forma;
  final Decoration barra;
  final Color tintaBarra;
  final TextStyle? estiloTitulo;

  /// Texto de apoio direto sobre o fundo da janela (o separador "Do app").
  final Color tintaTexto;
}
