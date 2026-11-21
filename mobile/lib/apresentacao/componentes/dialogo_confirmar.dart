// Pergunta de sim ou não antes de um ato que perde algo (descartar edições,
// substituir o preset de um slot, trocar de área com edição aberta). Fechar o
// diálogo sem escolher vale "não". Todos têm a mesma cara: cancelar neutro,
// confirmar no vermelho de alerta, porque confirmar sempre apaga algo.
import 'package:flutter/material.dart';

import '../tema/tokens.dart';

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
    builder: (contexto) {
      void responder(bool sim) => Navigator.pop(contexto, sim);
      return AlertDialog(
        title: Text(titulo),
        content: Text(texto),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Cores.texto),
            onPressed: () => responder(false),
            child: Text(rotuloCancelar),
          ),
          FilledButton(
            key: chaveConfirmar,
            style: FilledButton.styleFrom(backgroundColor: Cores.fitaAlerta, foregroundColor: Cores.sobreAlerta),
            onPressed: () => responder(true),
            child: Text(rotuloConfirmar),
          ),
        ],
      );
    },
  );
  return resposta ?? false;
}
