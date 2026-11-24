// A moldura que transforma o painel de um bloco no aparelho da pedaleira:
// aplica o ThemeData do painel (paleta, tipografia, botões em placa), pinta o
// chassi de alumínio escovado e, encaixada nele, a tela do bloco (anodizado
// escuro ou neon). A barra de cabeçalho é de cada painel (o letreiro, o
// Templates, o liga/desliga). Sem tema, devolve o painel como está.
import 'package:flutter/material.dart';

import '../tema/tema_app.dart';
import '../tema/tema_painel.dart';
import '../tema/tokens.dart';
import 'pintor_fundo_painel.dart';
import 'tela_pedaleira/decoracao_axioma.dart';

class MolduraTemaPainel extends StatelessWidget {
  const MolduraTemaPainel({super.key, required this.tema, required this.child});

  final TemaPainel? tema;
  final Widget child;

  /// A largura do chassi em volta da tela (os parafusos moram nele).
  static const recuoTela = 26.0;
  static const recuoTelaCelular = 12.0;
  static const _larguraCelular = 600.0;

  @override
  Widget build(BuildContext context) {
    final tema = this.tema;
    if (tema == null) return child;
    return Theme(
      data: TemaApp.doPainel(tema),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: tema.paleta.texto),
        child: LayoutBuilder(builder: (context, restricoes) {
          // no celular o chassi afina: a largura vai para os controles
          final recuo = restricoes.maxWidth < _larguraCelular ? recuoTelaCelular : recuoTela;
          return CustomPaint(
            key: ValueKey('tema-painel-${tema.estilo.name}'),
            painter: PintorChassi(recuoTela: recuo),
            child: Padding(
              padding: EdgeInsets.all(recuo),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Raios.canto),
                child: CustomPaint(
                  painter: PintorTela(tema),
                  foregroundPainter: tema.ehNeon ? const PintorVarredura() : null,
                  child: Padding(padding: const EdgeInsets.all(Espacos.m), child: child),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
