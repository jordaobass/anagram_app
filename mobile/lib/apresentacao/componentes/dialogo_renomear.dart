// Renomear o preset tocando no nome escrito na fita.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../../nucleo/modelo/documento_preset.dart';

/// Nome curto o bastante para o visor da pedaleira (hipótese: ver DECISOES).
const tamanhoMaximoNome = 24;

Future<void> renomearPreset(BuildContext context, WidgetRef ref) async {
  final atual = ref.read(editorProvider).atual?.nome ?? '';
  final nome = await showDialog<String>(context: context, builder: (_) => _DialogoRenomear(atual));
  if (nome != null) await ref.read(editorProvider.notifier).renomear(nome);
}

/// O diálogo é dono do controller do campo: ele só pode ser descartado
/// quando o campo sai da árvore, e isso acontece depois da animação de saída,
/// não quando o showDialog devolve o valor.
class _DialogoRenomear extends StatefulWidget {
  const _DialogoRenomear(this.nomeAtual);

  final String nomeAtual;

  @override
  State<_DialogoRenomear> createState() => _EstadoDialogoRenomear();
}

class _EstadoDialogoRenomear extends State<_DialogoRenomear> {
  late final _campo = TextEditingController(text: widget.nomeAtual);
  String? _motivo;

  @override
  void dispose() {
    _campo.dispose();
    super.dispose();
  }

  void _confirmar() {
    final motivo = motivoNomeInvalido(_campo.text);
    if (motivo == null) {
      Navigator.pop(context, _campo.text);
    } else {
      setState(() => _motivo = motivo);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Nome do preset'),
        content: TextField(
          key: const ValueKey('campo-nome'),
          controller: _campo,
          autofocus: true,
          maxLength: tamanhoMaximoNome,
          decoration: InputDecoration(labelText: 'Nome', errorText: _motivo),
          onChanged: (_) => setState(() => _motivo = null),
          onSubmitted: (_) => _confirmar(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          FilledButton(onPressed: _confirmar, child: const Text('RENOMEAR')),
        ],
      );
}
