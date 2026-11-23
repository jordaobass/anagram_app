// Seção "Backup dos presets" das Configurações, só no computador (DECISOES
// BK5): o interruptor do backup automático, a pasta (selecionável, com o
// botão que a abre), o backup completo e a lista para restaurar. Backup
// completo e restaurar precisam de pedaleira (ou da demonstração).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/copias/copia_automatica.dart';
import '../../aplicacao/estado/controlador_conexao.dart';
import '../../aplicacao/estado/estado_conexao.dart';
import '../../l10n/app_localizations.dart';
import '../../plataforma/copias_de_seguranca.dart';
import '../tema/tokens.dart';
import 'fluxo_copia_completa.dart';
import 'lista_copias.dart';

class SecaoCopias extends ConsumerWidget {
  const SecaoCopias(this.pasta, {super.key});

  final PastaDeCopias pasta;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final textos = Theme.of(context).textTheme;
    final conectada = ref.watch(conexaoProvider) is Conectada;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SwitchListTile(
        key: const ValueKey('backup-automatico'),
        contentPadding: EdgeInsets.zero,
        activeThumbColor: context.cores.tally,
        title: Text(l.bkAutomatico),
        subtitle: Text(l.bkAutomaticoTexto),
        value: ref.watch(copiaAutomaticaProvider),
        onChanged: ref.read(copiaAutomaticaProvider.notifier).definir,
      ),
      const SizedBox(height: Espacos.m),
      Text(l.bkOnde, style: textos.bodyMedium),
      const SizedBox(height: Espacos.xs),
      SelectableText(pasta.caminho.isEmpty ? l.bkPastaDesconhecida : pasta.caminho,
          key: const ValueKey('backup-pasta'), style: textos.bodySmall?.copyWith(color: context.cores.textoSecundario)),
      const SizedBox(height: Espacos.m),
      OutlinedButton.icon(
        key: const ValueKey('backup-abrir-pasta'),
        icon: const Icon(Icons.folder_open_outlined),
        label: Text(l.bkAbrirPasta),
        onPressed: pasta.caminho.isEmpty ? null : () => _abrirPasta(context, ref),
      ),
      const SizedBox(height: Espacos.xl),
      Text(l.bkCompletoTexto, style: textos.bodyMedium),
      const SizedBox(height: Espacos.m),
      _Acoes(conectada: conectada),
      if (!conectada) ...[
        const SizedBox(height: Espacos.s),
        Text(l.bkSemPedaleira, style: textos.bodySmall?.copyWith(color: context.cores.textoSecundario)),
      ],
    ]);
  }

  Future<void> _abrirPasta(BuildContext context, WidgetRef ref) async {
    final mensageiro = ScaffoldMessenger.of(context);
    final aviso = AppLocalizations.of(context).bkPastaNaoAbriu;
    if (!await ref.read(abridorDePastaProvider)(pasta.caminho)) {
      mensageiro.showSnackBar(SnackBar(content: Text(aviso)));
    }
  }
}

class _Acoes extends ConsumerWidget {
  const _Acoes({required this.conectada});

  final bool conectada;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Wrap(spacing: Espacos.s, runSpacing: Espacos.s, children: [
      OutlinedButton.icon(
        key: const ValueKey('backup-completo'),
        icon: const Icon(Icons.backup_outlined),
        label: Text(l.bkCompleto),
        onPressed: conectada ? () => executarCopiaCompleta(context, ref) : null,
      ),
      OutlinedButton.icon(
        key: const ValueKey('backup-restaurar'),
        icon: const Icon(Icons.restore),
        label: Text(l.bkRestaurar),
        onPressed: conectada ? () => abrirListaDeCopias(context, ref) : null,
      ),
    ]);
  }
}
