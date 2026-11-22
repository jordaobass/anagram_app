// Pausa entre pacotes (relatórios) USB, em Configurações › Pedaleira. "Auto"
// usa a do transporte (0 ms no Mac, no Windows e no Linux; 10 ms no Android e
// no navegador). Menor deixa o ao vivo mais rápido; maior ajuda se a
// pedaleira deixar de responder. A escolha fica guardada
// (preferencias_pausa.dart) e aparece também sem pedaleira: é quando ela não
// responde que mais se precisa mudar isto.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/provedores.dart';
import '../../l10n/app_localizations.dart';
import '../tema/tokens.dart';

/// Título, explicação e o seletor.
class AjustePausaUsb extends StatelessWidget {
  const AjustePausaUsb({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tema = Theme.of(context).textTheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l.pausaUsbTitulo, style: tema.titleSmall),
      const SizedBox(height: Espacos.xs),
      Text(l.pausaUsbTexto, style: tema.bodyMedium?.copyWith(color: context.cores.textoSecundario)),
      const SizedBox(height: Espacos.s),
      const SeletorPausa(),
    ]);
  }
}

class SeletorPausa extends ConsumerWidget {
  const SeletorPausa({super.key});

  static const opcoes = <int?>[null, 0, 2, 10];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final atual = ref.watch(pausaRelatoriosProvider)?.inMilliseconds;
    return SegmentedButton<int?>(
      key: const ValueKey('seletor-pausa'),
      segments: [
        for (final ms in opcoes) ButtonSegment(value: ms, label: Text(ms == null ? AppLocalizations.of(context).pausaAuto : '$ms ms')),
      ],
      selected: {atual},
      onSelectionChanged: (escolha) => ref
          .read(pausaRelatoriosProvider.notifier)
          .definir(escolha.first == null ? null : Duration(milliseconds: escolha.first!)),
    );
  }
}
