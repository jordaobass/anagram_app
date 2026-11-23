// Topo da lista enquanto o "Salvar como" escolhe o destino.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../navegacao.dart';
import '../tema/tokens.dart';
import '../../l10n/app_localizations.dart';

class FaixaEscolherDestino extends ConsumerWidget {
  const FaixaEscolherDestino({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context).textTheme;
    final l = AppLocalizations.of(context);
    return Container(
      key: const ValueKey('faixa-escolher-destino'),
      color: context.cores.tally,
      padding: const EdgeInsets.only(left: Espacos.m),
      child: Row(children: [
        Expanded(
          child: Text(l.salvarComoEscolhaDestino,
              style: tema.labelLarge?.copyWith(color: context.cores.sobreTally)),
        ),
        TextButton(
          onPressed: () {
            ref.read(editorProvider.notifier).cancelarSalvarComo();
            voltarSePuder(context);
          },
          style: TextButton.styleFrom(foregroundColor: context.cores.sobreTally),
          child: Text(l.cancelar),
        ),
      ]),
    );
  }
}
