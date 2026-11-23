// O botão de escolha das cenas e dos modos: inativo em `painel-elevado` com
// filete; ativo preenchido em âmbar tally (DESIGN.md, Cenas). Sem [aoTocar],
// desabilitado: o texto vai para `texto-secundario`.
import 'package:flutter/material.dart';

import '../tema/tokens.dart';

class BotaoTally extends StatelessWidget {
  const BotaoTally({
    super.key,
    required this.chave,
    required this.ativo,
    required this.rotuloSemantico,
    required this.aoTocar,
    required this.alturaMinima,
    required this.filho,
  });

  /// Vai no InkWell, onde os testes tocam.
  final Key chave;
  final bool ativo;
  final String rotuloSemantico;
  final VoidCallback? aoTocar;
  final double alturaMinima;
  final Widget filho;

  /// A cor do texto de quem monta o [filho].
  static Color corDoTexto(Paleta cores, {required bool ativo, bool habilitado = true}) {
    if (ativo) return cores.sobreTally;
    return habilitado ? cores.texto : cores.textoSecundario;
  }

  @override
  Widget build(BuildContext context) {
    final raio = BorderRadius.circular(Raios.controle);
    return Semantics(
      selected: ativo,
      button: true,
      label: rotuloSemantico,
      child: Material(
        color: ativo ? context.cores.tally : context.cores.painelElevado,
        shape: RoundedRectangleBorder(
          borderRadius: raio,
          side: BorderSide(color: ativo ? context.cores.tallyTinta : context.cores.filete),
        ),
        child: InkWell(
          key: chave,
          borderRadius: raio,
          onTap: aoTocar,
          child: ConstrainedBox(constraints: BoxConstraints(minHeight: alturaMinima), child: filho),
        ),
      ),
    );
  }
}
