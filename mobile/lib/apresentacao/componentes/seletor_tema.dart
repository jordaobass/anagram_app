// Escolha do tema nas Configurações, com as mesmas pílulas do idioma:
// "Do sistema" segue o claro/escuro do aparelho; os outros fixam um.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/tema.dart';
import '../../l10n/app_localizations.dart';
import '../tema/tokens.dart';

class SeletorTema extends ConsumerWidget {
  const SeletorTema({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final escolhido = ref.watch(temaProvider);
    final controlador = ref.read(temaProvider.notifier);
    final l = AppLocalizations.of(context);
    final rotulos = {
      EscolhaTema.sistema: l.temaSistema,
      EscolhaTema.escuro: l.temaEscuro,
      EscolhaTema.claro: l.temaClaro,
    };
    return Wrap(spacing: Espacos.xs, runSpacing: Espacos.xs, children: [
      for (final MapEntry(key: tema, value: rotulo) in rotulos.entries)
        ChoiceChip(
          key: ValueKey('tema-${tema.codigo}'),
          label: Text(rotulo),
          selected: escolhido == tema,
          onSelected: (_) => controlador.escolher(tema),
        ),
    ]);
  }
}
