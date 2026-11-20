// Diagnóstico de latência: pausa entre relatórios USB. "Auto" usa a do
// transporte (0 ms no Mac, 10 ms nos outros). Serve para comparar 0/2/10 ms
// na bancada lendo o log "ida e volta".
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/provedores.dart';

class SeletorPausa extends ConsumerWidget {
  const SeletorPausa({super.key});

  static const opcoes = <int?>[null, 0, 2, 10];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final atual = ref.watch(pausaRelatoriosProvider)?.inMilliseconds;
    return SegmentedButton<int?>(
      key: const ValueKey('seletor-pausa'),
      segments: [
        for (final ms in opcoes) ButtonSegment(value: ms, label: Text(ms == null ? 'Auto' : '$ms ms')),
      ],
      selected: {atual},
      onSelectionChanged: (escolha) => ref
          .read(pausaRelatoriosProvider.notifier)
          .definir(escolha.first == null ? null : Duration(milliseconds: escolha.first!)),
    );
  }
}
