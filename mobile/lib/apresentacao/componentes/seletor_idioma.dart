// Escolha do idioma: as pílulas na tela Sobre e um menu compacto (globo) na
// tela de conectar, para dar para trocar antes mesmo de entrar. "Sistema"
// segue o idioma do aparelho; os outros fixam um. Cada nome aparece no próprio
// idioma, para quem caiu num idioma que não lê conseguir voltar.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/idioma.dart';
import '../../l10n/app_localizations.dart';
import '../tema/tokens.dart';
import 'item_de_menu.dart';

const _nomes = {
  IdiomaApp.portugues: 'Português',
  IdiomaApp.ingles: 'English',
  IdiomaApp.espanhol: 'Español',
};

class SeletorIdioma extends ConsumerWidget {
  const SeletorIdioma({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final escolhido = ref.watch(idiomaProvider);
    final controlador = ref.read(idiomaProvider.notifier);
    return Wrap(spacing: Espacos.xs, runSpacing: Espacos.xs, children: [
      _opcao('sistema', AppLocalizations.of(context).idiomaDoSistema,
          selecionado: escolhido == null, aoTocar: () => controlador.escolher(null)),
      for (final MapEntry(key: idioma, value: nome) in _nomes.entries)
        _opcao(idioma.codigo, nome, selecionado: escolhido == idioma, aoTocar: () => controlador.escolher(idioma)),
    ]);
  }

  Widget _opcao(String chave, String rotulo, {required bool selecionado, required VoidCallback aoTocar}) => ChoiceChip(
        key: ValueKey('idioma-$chave'),
        label: Text(rotulo),
        selected: selecionado,
        onSelected: (_) => aoTocar(),
      );
}

/// Globo com o idioma atual; abre a mesma lista das pílulas.
class MenuIdioma extends ConsumerWidget {
  const MenuIdioma({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final escolhido = ref.watch(idiomaProvider);
    final l = AppLocalizations.of(context);
    final atual = escolhido == null ? l.idiomaDoSistema : _nomes[escolhido]!;
    return PopupMenuButton<IdiomaApp?>(
      key: const ValueKey('menu-idioma'),
      tooltip: l.idioma,
      onSelected: ref.read(idiomaProvider.notifier).escolher,
      itemBuilder: (_) => [
        PopupMenuItem(value: null, height: alturaItemDeMenu, child: Text(l.idiomaDoSistema)),
        for (final MapEntry(key: idioma, value: nome) in _nomes.entries)
          PopupMenuItem(value: idioma, height: alturaItemDeMenu, child: Text(nome)),
      ],
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.language, color: context.cores.textoSecundario),
        const SizedBox(width: Espacos.xs),
        Text(atual, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: context.cores.textoSecundario)),
      ]),
    );
  }
}
