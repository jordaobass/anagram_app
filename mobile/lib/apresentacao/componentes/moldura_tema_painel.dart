// A moldura que dá a um painel de bloco o tema da tela dele na pedaleira:
// aplica o ThemeData do painel (paleta, tipografia, botões em placa), pinta o
// fundo do material (alumínio escovado ou synthwave) e põe o letreiro com o
// nome do bloco. Sem tema, devolve o painel como está.
import 'package:flutter/material.dart';

import '../tema/tema_app.dart';
import '../tema/tema_painel.dart';
import '../tema/tokens.dart';
import 'pintor_fundo_painel.dart';

class MolduraTemaPainel extends StatelessWidget {
  const MolduraTemaPainel({super.key, required this.tema, required this.titulo, required this.child});

  final TemaPainel? tema;

  /// O nome do bloco no letreiro (decorativo: o cabeçalho já o anuncia).
  final String titulo;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tema = this.tema;
    if (tema == null) return child;
    final p = tema.paleta;
    return Theme(
      data: TemaApp.doPainel(tema),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: p.texto),
        child: Container(
          key: ValueKey('tema-painel-${tema.estilo.name}'),
          decoration: ShapeDecoration(shape: tema.forma(BorderSide(color: p.filete))),
          clipBehavior: Clip.antiAlias,
          child: CustomPaint(
            painter: PintorFundoPainel(tema),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Espacos.m, Espacos.m, Espacos.m, Espacos.l),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                _Letreiro(tema: tema, titulo: titulo),
                const SizedBox(height: Espacos.m),
                child,
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// "I G N I S S O R" fino e espaçado com um filete até a borda (metal), ou o
/// nome em display com o friso magenta e o ciano por baixo (neon).
class _Letreiro extends StatelessWidget {
  const _Letreiro({required this.tema, required this.titulo});

  final TemaPainel tema;
  final String titulo;

  static const _corpo = 20.0;
  static const _espacoMetal = 8.0;
  static const _espacoNeon = 3.0;

  @override
  Widget build(BuildContext context) {
    final p = tema.paleta;
    final estilo = TextStyle(
      fontFamily: tema.ehNeon ? Fontes.tecno : Fontes.ui,
      fontWeight: FontWeight.w400,
      fontSize: _corpo,
      height: 1,
      letterSpacing: tema.ehNeon ? _espacoNeon : _espacoMetal,
      color: p.texto,
    );
    return ExcludeSemantics(
      child: LayoutBuilder(
        builder: (context, restricoes) => Row(children: [
          // no celular o nome espaçado não cabe: encolhe em vez de estourar
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: restricoes.maxWidth * _fracaoMaximaDoNome),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(titulo.toUpperCase(), key: const ValueKey('letreiro-painel'), style: estilo),
            ),
          ),
          const SizedBox(width: Espacos.m),
          Expanded(child: tema.ehNeon ? _frisosNeon() : Container(height: Medidas.filete, color: p.filete)),
        ]),
      ),
    );
  }

  /// O filete (ou os frisos) sempre aparece: o nome ocupa no máximo isto.
  static const _fracaoMaximaDoNome = 0.8;

  Widget _frisosNeon() => Column(mainAxisSize: MainAxisSize.min, children: [
        Container(height: Medidas.contornoSelecao, color: tema.friso),
        const SizedBox(height: Espacos.xxs),
        Container(height: Medidas.filete, color: tema.destaque),
      ]);
}
