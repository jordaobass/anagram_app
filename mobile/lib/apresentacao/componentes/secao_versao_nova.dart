// Seção "Atualizações" das Configurações: ligar ou desligar a consulta ao
// GitHub ao abrir e ver em que pé está (em dia, versão nova, sem resposta).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/versao_nova.dart';
import '../../l10n/app_localizations.dart';
import '../tema/tokens.dart';

class SecaoVersaoNova extends ConsumerWidget {
  const SecaoVersaoNova({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(versaoNovaProvider);
    final l = AppLocalizations.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SwitchListTile(
        key: const ValueKey('versao-nova-verificar'),
        contentPadding: EdgeInsets.zero,
        activeThumbColor: Cores.tally,
        title: Text(l.versaoNovaVerificar),
        subtitle: Text(l.versaoNovaVerificarTexto),
        value: estado.configuracao.verificarAoAbrir,
        onChanged: ref.read(versaoNovaProvider.notifier).definirVerificacao,
      ),
      if (estado.configuracao.verificarAoAbrir) _SituacaoVersao(estado.situacao),
    ]);
  }
}

class _SituacaoVersao extends ConsumerWidget {
  const _SituacaoVersao(this.situacao);

  final SituacaoVersao situacao;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final estilo = Theme.of(context).textTheme.bodyLarge;
    return Semantics(
      liveRegion: true,
      child: switch (situacao) {
        VersaoNaoVerificada() => const SizedBox.shrink(),
        VersaoEmDia() => Text(l.versaoNovaEmDia, style: estilo),
        VersaoSemResposta() => Text(l.versaoNovaSemResposta, style: Theme.of(context).textTheme.bodyMedium),
        VersaoDisponivel(:final release) => Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: Espacos.m, children: [
            Text(l.versaoNovaDisponivel(release.versao), style: estilo),
            OutlinedButton.icon(
              key: const ValueKey('versao-nova-baixar-configuracoes'),
              icon: const Icon(Icons.system_update_alt),
              label: Text(l.versaoNovaBaixar),
              onPressed: () => ref.read(versaoNovaProvider.notifier).baixar(release),
            ),
          ]),
      },
    );
  }
}
