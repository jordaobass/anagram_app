// Pergunta de sim ou não antes de um ato que perde algo (largar edições,
// substituir o preset de um slot). Fechar o diálogo sem escolher vale "não".
import 'package:flutter/material.dart';

/// [enfatizar]: o confirmar sai preenchido, para quando ele é o passo esperado
/// (substituir no Salvar como); sem ele, sai só contornado, como o cancelar.
Future<bool> confirmar(
  BuildContext context, {
  required String titulo,
  required String texto,
  required String rotuloCancelar,
  required String rotuloConfirmar,
  Key? chaveConfirmar,
  bool enfatizar = false,
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
          TextButton(onPressed: () => responder(false), child: Text(rotuloCancelar)),
          enfatizar
              ? FilledButton(key: chaveConfirmar, onPressed: () => responder(true), child: Text(rotuloConfirmar))
              : OutlinedButton(key: chaveConfirmar, onPressed: () => responder(true), child: Text(rotuloConfirmar)),
        ],
      );
    },
  );
  return resposta ?? false;
}
