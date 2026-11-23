// O caminho até a permissão no macOS (DECISOES CA5), logo abaixo do aviso da
// tela de conectar: o botão abre a página certa dos Ajustes, e a frase lembra
// que o macOS só aplica a permissão quando o app é reaberto.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/versao_nova.dart';
import '../../l10n/app_localizations.dart';
import '../../plataforma/acesso_entrada_mac.dart';
import '../tema/tokens.dart';

class CaminhoMonitoramentoEntrada extends ConsumerWidget {
  const CaminhoMonitoramentoEntrada({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final tema = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: Espacos.m),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        OutlinedButton.icon(
          key: const ValueKey('abrir-ajustes-monitoramento'),
          icon: const Icon(Icons.settings_outlined),
          label: Text(l.caAbrirAjustes),
          onPressed: () => ref.read(abridorDeLinkProvider)(enderecoAjustesMonitoramentoEntrada),
        ),
        const SizedBox(height: Espacos.s),
        Text(l.caReabraDepois,
            key: const ValueKey('reabra-depois-de-ligar'),
            style: tema.bodyMedium?.copyWith(color: context.cores.textoSecundario)),
      ]),
    );
  }
}
