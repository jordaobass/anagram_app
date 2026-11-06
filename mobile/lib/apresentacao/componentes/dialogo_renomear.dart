// Renomear o preset tocando no nome escrito na fita.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';

/// Nome curto o bastante para o visor da pedaleira (hipótese: ver DECISOES).
const tamanhoMaximoNome = 24;

Future<void> renomearPreset(BuildContext context, WidgetRef ref) async {
  final atual = ref.read(editorProvider).atual?.nome ?? '';
  final campo = TextEditingController(text: atual);
  final nome = await showDialog<String>(
    context: context,
    builder: (contexto) => AlertDialog(
      title: const Text('Nome do preset'),
      content: TextField(
        key: const ValueKey('campo-nome'),
        controller: campo,
        autofocus: true,
        maxLength: tamanhoMaximoNome,
        decoration: const InputDecoration(labelText: 'Nome'),
        onSubmitted: (texto) => Navigator.pop(contexto, texto),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(contexto), child: const Text('CANCELAR')),
        FilledButton(onPressed: () => Navigator.pop(contexto, campo.text), child: const Text('RENOMEAR')),
      ],
    ),
  );
  campo.dispose();
  if (nome != null) await ref.read(editorProvider.notifier).renomear(nome);
}
