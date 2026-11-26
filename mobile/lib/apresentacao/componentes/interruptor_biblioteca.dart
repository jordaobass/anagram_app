// "BIBLIOTECA" + interruptor, ao lado do "Ao vivo" (DECISOES BB1): liga o
// modo em que a lista de presets mostra os presets prontos por banda. No
// celular a barra de cima não tem espaço: o interruptor vira um ícone na
// barra da tela da lista de presets.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/modo_biblioteca.dart';
import '../../l10n/app_localizations.dart';
import '../tema/tokens.dart';

class InterruptorBiblioteca extends ConsumerWidget {
  const InterruptorBiblioteca({super.key, required this.compacta});

  final bool compacta;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ligado = ref.watch(modoBibliotecaProvider);
    final l = AppLocalizations.of(context);
    final definir = ref.read(modoBibliotecaProvider.notifier).definir;

    if (compacta) {
      return IconButton(
        key: const ValueKey('interruptor-biblioteca'),
        tooltip: l.bbModoDica,
        isSelected: ligado,
        color: context.cores.textoSecundario,
        selectedIcon: Icon(Icons.library_music, color: context.cores.tallyTinta),
        icon: const Icon(Icons.library_music_outlined),
        onPressed: () => definir(!ligado),
      );
    }
    return Tooltip(
      message: l.bbModoDica,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Espacos.s, vertical: Espacos.xxs),
          child: Text(l.bbModo,
              key: const ValueKey('rotulo-biblioteca'),
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: ligado ? context.cores.tallyTinta : context.cores.textoSecundario)),
        ),
        Switch(
          key: const ValueKey('interruptor-biblioteca'),
          value: ligado,
          activeThumbColor: context.cores.tally,
          onChanged: definir,
        ),
      ]),
    );
  }
}
