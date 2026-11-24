// As peças da barra do Axioma: o botão quadrado de neon (48 dp de alvo), o
// logotipo, a pílula de liga/desliga, o visor de LCD e o campo "Controlar".
// Toda cor de texto daqui tem par medido no teste de contraste do painel.
import 'package:flutter/material.dart';

import '../../tema/paletas_painel.dart';
import '../../tema/tokens.dart';
import 'icones_axioma.dart';
import 'neon.dart';

/// Quadrado com o ícone em neon; desabilitado (sem [aoTocar]) apaga.
class BotaoQuadradoNeon extends StatelessWidget {
  const BotaoQuadradoNeon({super.key, required this.chave, required this.icone, required this.dica, required this.aoTocar});

  final String chave;
  final IconeAxioma icone;
  final String dica;
  final VoidCallback? aoTocar;

  static const lado = Medidas.alvoMinimo;

  @override
  Widget build(BuildContext context) {
    final ativo = aoTocar != null;
    final cor = ativo ? CoresNeon.ciano : context.cores.filete;
    return Tooltip(
      message: dica,
      child: Semantics(
        button: true,
        enabled: ativo,
        label: dica,
        child: InkWell(
          key: ValueKey(chave),
          onTap: aoTocar,
          customBorder: const BeveledRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
          // DecoratedBox, não Ink: o Ink pinta no Material de baixo, que fica
          // por trás da tela pintada do aparelho
          child: Container(
            width: lado,
            height: lado,
            decoration: ShapeDecoration(
              color: context.cores.painelElevado,
              shape: BeveledRectangleBorder(side: BorderSide(color: cor, width: 1.5), borderRadius: const BorderRadius.all(Radius.circular(4))),
            ),
            child: Padding(
              padding: const EdgeInsets.all(Espacos.s + 2),
              child: CustomPaint(painter: PintorIconeAxioma(icone: icone, cor: cor, brilho: ativo ? BrilhoNeon.of(context) : 0)),
            ),
          ),
        ),
      ),
    );
  }
}

/// "AXIOMA" em display larga, inclinada como itálico, com halo ciano e rosa.
class LogotipoAxioma extends StatelessWidget {
  const LogotipoAxioma({super.key});

  static const _inclinacao = -0.22;

  @override
  Widget build(BuildContext context) {
    final brilho = BrilhoNeon.of(context);
    return ExcludeSemantics(
      child: Transform(
        transform: Matrix4.skewX(_inclinacao),
        alignment: Alignment.center,
        child: Text(
          'AXIOMA',
          style: TextStyle(
            fontFamily: Fontes.logotipo,
            fontVariations: const [FontVariation.weight(900)],
            fontWeight: FontWeight.w900,
            fontSize: 26,
            letterSpacing: 2,
            color: CoresNeon.nucleo,
            shadows: [
              Shadow(color: CoresNeon.ciano, blurRadius: 10 * brilho),
              Shadow(color: CoresNeon.rosa, blurRadius: 3 * brilho, offset: const Offset(2, 2)),
            ],
          ),
        ),
      ),
    );
  }
}

/// A pílula azul acesa do liga/desliga do bloco (o mesmo do cabeçalho).
class PilulaLigaNeon extends StatelessWidget {
  const PilulaLigaNeon({super.key, required this.ligado, required this.dica, required this.aoTocar});

  final bool ligado;
  final String dica;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final brilho = BrilhoNeon.of(context);
    return Tooltip(
      message: dica,
      child: Semantics(
        toggled: ligado,
        label: dica,
        child: GestureDetector(
          key: const ValueKey('ax-liga'),
          behavior: HitTestBehavior.opaque,
          onTap: aoTocar,
          child: SizedBox(
            width: 64,
            height: Medidas.alvoMinimo,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 56,
                height: 26,
                alignment: ligado ? Alignment.centerRight : Alignment.centerLeft,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: ligado ? CoresNeon.azul : context.cores.painelElevado,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: ligado ? CoresNeon.nucleo : context.cores.filete),
                  boxShadow: ligado ? [BoxShadow(color: CoresNeon.azul, blurRadius: 12 * brilho)] : null,
                ),
                child: Container(width: 20, height: 20, decoration: const BoxDecoration(color: CoresNeon.nucleo, shape: BoxShape.circle)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// O visor de LCD: o slot aberto ("01A"), em ciano sobre o vidro escuro.
class VisorLcd extends StatelessWidget {
  const VisorLcd({super.key, required this.texto, required this.rotulo});

  final String texto;
  final String rotulo;

  @override
  Widget build(BuildContext context) => Semantics(
        label: rotulo,
        value: texto,
        child: Container(
          key: const ValueKey('ax-lcd'),
          padding: const EdgeInsets.symmetric(horizontal: Espacos.m, vertical: Espacos.xs + 1),
          decoration: BoxDecoration(color: CoresNeon.lcdFundo, border: Border.all(color: CoresNeon.ciano, width: 1.5)),
          child: ExcludeSemantics(
            child: Text(texto,
                style: TextStyle(
                  fontFamily: Fontes.tecno,
                  fontSize: 22,
                  color: CoresNeon.lcdTinta,
                  shadows: [Shadow(color: CoresNeon.ciano, blurRadius: 6 * BrilhoNeon.of(context))],
                )),
          ),
        ),
      );
}

/// O campo azul "Controlar": tocar alterna todas as cenas / só a ativa.
class CampoControlar extends StatelessWidget {
  const CampoControlar({super.key, required this.texto, required this.rotulo, required this.dica, required this.aoTocar});

  final String texto;
  final String rotulo;
  final String dica;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: dica,
        child: Semantics(
          button: true,
          label: rotulo,
          value: texto,
          child: InkWell(
            key: const ValueKey('ax-controlar'),
            onTap: aoTocar,
            child: Container(
              constraints: const BoxConstraints(minWidth: 180),
              padding: const EdgeInsets.symmetric(horizontal: Espacos.m, vertical: Espacos.m + 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [CoresNeon.campoFundo, Color.lerp(CoresNeon.campoFundo, CoresNeon.azul, 0.35)!]),
                border: Border.all(color: CoresNeon.ciano),
              ),
              child: ExcludeSemantics(
                child: Text(texto, style: const TextStyle(fontFamily: Fontes.tecno, fontSize: 16, color: CoresNeon.campoTinta)),
              ),
            ),
          ),
        ),
      );
}
