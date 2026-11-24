// "Conectar ao abrir" nas Configurações (DECISOES CA1): vale para a próxima
// abertura do app; mexer aqui não conecta nem desconecta. No macOS, a linha a
// mais diz que sem o Monitoramento de Entrada o app não tenta sozinho (CA3).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/conectar_ao_abrir.dart';
import '../../l10n/app_localizations.dart';
import '../tema/tokens.dart';

class InterruptorConectarAoAbrir extends ConsumerWidget {
  const InterruptorConectarAoAbrir({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final noMac = ref.watch(plataformaDeAberturaProvider) == PlataformaDeAbertura.macOS;
    return SwitchListTile(
      key: const ValueKey('conectar-ao-abrir'),
      contentPadding: EdgeInsets.zero,
      activeThumbColor: context.cores.tally,
      title: Text(l.caConectarAoAbrir),
      subtitle: Text(noMac ? '${l.caConectarAoAbrirTexto}\n${l.caConectarAoAbrirMac}' : l.caConectarAoAbrirTexto),
      value: ref.watch(conectarAoAbrirProvider),
      onChanged: ref.read(conectarAoAbrirProvider.notifier).definir,
    );
  }
}
