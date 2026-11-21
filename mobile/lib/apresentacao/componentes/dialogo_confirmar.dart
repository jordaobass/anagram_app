// Pergunta de sim ou não antes de um ato que perde algo (descartar edições,
// substituir o preset de um slot, trocar de área com edição aberta). Fechar o
// diálogo sem escolher vale "não". Todos têm a mesma cara: cancelar neutro,
// confirmar no vermelho de alerta, porque confirmar sempre apaga algo.
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../tema/tokens.dart';

/// Abrir outro preset com edição não salva: as edições de [nome] se perdem.
Future<bool> confirmarLargarEdicoes(BuildContext context, String nome) {
  final l = AppLocalizations.of(context);
  return confirmar(context,
      titulo: l.largarEdicoesTitulo,
      texto: l.largarEdicoesTexto(nome),
      rotuloCancelar: l.continuarEditando,
      rotuloConfirmar: l.largar);
}

Future<bool> confirmar(
  BuildContext context, {
  required String titulo,
  required String texto,
  required String rotuloCancelar,
  required String rotuloConfirmar,
  Key? chaveConfirmar,
}) async {
  final resposta = await showDialog<bool>(
    context: context,
    builder: (contexto) => AlertDialog(
      title: Text(titulo),
      content: Text(texto),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        BotaoCancelarDialogo(rotulo: rotuloCancelar, aoTocar: () => Navigator.pop(contexto, false)),
        BotaoConfirmarPerda(key: chaveConfirmar, rotulo: rotuloConfirmar, aoTocar: () => Navigator.pop(contexto, true)),
      ],
    ),
  );
  return resposta ?? false;
}

/// O "não" dos diálogos de perda: neutro, em texto.
class BotaoCancelarDialogo extends StatelessWidget {
  const BotaoCancelarDialogo({super.key, required this.rotulo, required this.aoTocar});

  final String rotulo;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) => TextButton(
        style: TextButton.styleFrom(foregroundColor: Cores.texto),
        onPressed: aoTocar,
        child: Text(rotulo),
      );
}

/// O "sim" que apaga algo: cheio, no vermelho de alerta.
class BotaoConfirmarPerda extends StatelessWidget {
  const BotaoConfirmarPerda({super.key, required this.rotulo, required this.aoTocar});

  final String rotulo;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) => FilledButton(
        style: FilledButton.styleFrom(backgroundColor: Cores.fitaAlerta, foregroundColor: Cores.sobreAlerta),
        onPressed: aoTocar,
        child: Text(rotulo),
      );
}
