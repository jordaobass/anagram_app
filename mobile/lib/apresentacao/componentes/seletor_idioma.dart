// Escolha do idioma na tela Sobre: "Sistema" segue o idioma do aparelho; os
// outros fixam um. Cada nome aparece no próprio idioma, para quem caiu num
// idioma que não lê conseguir voltar.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/idioma.dart';
import '../../l10n/app_localizations.dart';
import '../tema/tokens.dart';

class SeletorIdioma extends ConsumerWidget {
  const SeletorIdioma({super.key});

  static const _nomes = {
    IdiomaApp.portugues: 'Português',
    IdiomaApp.ingles: 'English',
    IdiomaApp.espanhol: 'Español',
  };

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
