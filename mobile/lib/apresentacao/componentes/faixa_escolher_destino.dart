// Topo da lista enquanto o "Salvar como" escolhe o destino.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../tema/tokens.dart';

class FaixaEscolherDestino extends ConsumerWidget {
  const FaixaEscolherDestino({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context).textTheme;
    return Container(
      key: const ValueKey('faixa-escolher-destino'),
      color: Cores.tally,
      padding: const EdgeInsets.only(left: Espacos.m),
      child: Row(children: [
        Expanded(
          child: Text('SALVAR COMO: TOQUE NO SLOT DE DESTINO',
              style: tema.labelLarge?.copyWith(color: Cores.sobreTally)),
        ),
        TextButton(
          onPressed: () {
            ref.read(editorProvider.notifier).cancelarSalvarComo();
            Navigator.of(context).maybePop();
          },
          style: TextButton.styleFrom(foregroundColor: Cores.sobreTally),
          child: const Text('CANCELAR'),
        ),
      ]),
    );
  }
}
