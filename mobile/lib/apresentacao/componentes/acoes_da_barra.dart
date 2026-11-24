// O lado direito da barra, o que é do app e não da pedaleira: o indicador
// "IA" enquanto o MCP escuta (o som pode mudar sem a pessoa tocar) e a
// engrenagem das Configurações, com um ponto quando há versão nova para
// baixar (DECISOES BS1). O Sobre fica dentro das Configurações.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/mcp/controlador_mcp.dart';
import '../../aplicacao/versao_nova.dart';
import '../../l10n/app_localizations.dart';
import '../rotas.dart';
import '../tema/tokens.dart';

/// Ponto verde + "IA", só com o MCP escutando; a porta vai na dica.
class IndicadorIa extends ConsumerWidget {
  const IndicadorIa({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final situacao = ref.watch(controladorMcpProvider.select((e) => e.situacao));
    if (situacao is! McpEscutando) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    return Tooltip(
      message: l.mcpAtivoDicaPorta(situacao.porta),
      child: Padding(
        key: const ValueKey('selo-mcp'),
        padding: const EdgeInsets.symmetric(horizontal: Espacos.s),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: Medidas.pontoIa,
            height: Medidas.pontoIa,
            decoration: BoxDecoration(color: context.cores.ledLigado, shape: BoxShape.circle),
          ),
          const SizedBox(width: Espacos.xs),
          Text(l.mcpAtivoNaBarra, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: context.cores.texto)),
        ]),
      ),
    );
  }
}

/// A engrenagem, à direita; com versão nova não dispensada, um ponto âmbar
/// (é convite a uma ação: baixar) e a versão na dica.
class BotaoConfiguracoes extends ConsumerWidget {
  const BotaoConfiguracoes({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final versaoNova = ref.watch(versaoNovaProvider.select((estado) => estado.avisoNaBarra));
    return IconButton(
      key: const ValueKey('botao-configuracoes'),
      tooltip: versaoNova == null
          ? l.mcpConfiguracoes
          : '${l.mcpConfiguracoes} · ${l.versaoNovaNaBarra(versaoNova.versao)}',
      icon: Badge(
        key: const ValueKey('selo-versao-nova'),
        isLabelVisible: versaoNova != null,
        smallSize: Medidas.seloEngrenagem,
        backgroundColor: context.cores.tally,
        child: const Icon(Icons.settings_outlined),
      ),
      onPressed: () => const RotaConfiguracoes().push<void>(context),
    );
  }
}
