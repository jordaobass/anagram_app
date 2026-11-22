// Aviso discreto de versão nova na barra de cima: não bloqueia nada e fica
// até a pessoa baixar ou pedir para lembrar depois. Na barra estreita cabe
// só um ícone, que abre as duas ações num menu.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/versao_nova.dart';
import '../../l10n/app_localizations.dart';
import '../../nucleo/versao/release_publicada.dart';
import '../tema/tokens.dart';
import 'item_de_menu.dart';

class AvisoVersaoNova extends ConsumerWidget {
  const AvisoVersaoNova({super.key, required this.compacta});

  final bool compacta;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final release = ref.watch(versaoNovaProvider.select((estado) => estado.avisoNaBarra));
    if (release == null) return const SizedBox.shrink();
    return compacta ? _MenuVersaoNova(release) : _FaixaVersaoNova(release);
  }
}

class _FaixaVersaoNova extends ConsumerWidget {
  const _FaixaVersaoNova(this.release);

  final ReleasePublicada release;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final controlador = ref.read(versaoNovaProvider.notifier);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.system_update_alt, size: Medidas.iconeAvisoVersao, color: Cores.aluminioClaro),
      const SizedBox(width: Espacos.xs),
      Text(l.versaoNovaNaBarra(release.versao), style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Cores.texto)),
      TextButton(
        key: const ValueKey('versao-nova-baixar'),
        onPressed: () => controlador.baixar(release),
        child: Text(l.versaoNovaBaixar),
      ),
      IconButton(
        key: const ValueKey('versao-nova-dispensar'),
        tooltip: l.versaoNovaLembrarDepois,
        icon: const Icon(Icons.close),
        onPressed: controlador.dispensar,
      ),
    ]);
  }
}

enum _AcaoVersao { baixar, lembrarDepois }

class _MenuVersaoNova extends ConsumerWidget {
  const _MenuVersaoNova(this.release);

  final ReleasePublicada release;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final controlador = ref.read(versaoNovaProvider.notifier);
    return PopupMenuButton<_AcaoVersao>(
      key: const ValueKey('versao-nova-menu'),
      tooltip: l.versaoNovaNaBarra(release.versao),
      icon: const Icon(Icons.system_update_alt, color: Cores.aluminioClaro),
      onSelected: (acao) => acao == _AcaoVersao.baixar ? controlador.baixar(release) : controlador.dispensar(),
      itemBuilder: (_) => [
        PopupMenuItem(value: _AcaoVersao.baixar, height: alturaItemDeMenu, child: Text(l.versaoNovaBaixar)),
        PopupMenuItem(value: _AcaoVersao.lembrarDepois, height: alturaItemDeMenu, child: Text(l.versaoNovaLembrarDepois)),
      ],
    );
  }
}
