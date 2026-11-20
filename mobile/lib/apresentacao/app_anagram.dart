// Raiz do app: tema escuro único (DESIGN.md), rotas tipadas do go_router e
// idioma da interface (português, inglês ou espanhol; o do sistema por
// padrão). O roteador nasce uma vez por app, no estado, para não perder a
// pilha de telas a cada reconstrução.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../aplicacao/idioma.dart';
import '../l10n/app_localizations.dart';
import 'rotas.dart';
import 'tema/tema_app.dart';

class AppAnagram extends ConsumerStatefulWidget {
  const AppAnagram({super.key});

  static const titulo = 'Anagram App';

  @override
  ConsumerState<AppAnagram> createState() => _AppAnagramState();
}

class _AppAnagramState extends ConsumerState<AppAnagram> {
  late final GoRouter _roteador = criarRoteador();

  @override
  Widget build(BuildContext context) {
    final escolhido = ref.watch(idiomaProvider);
    return MaterialApp.router(
      title: AppAnagram.titulo,
      debugShowCheckedModeBanner: false,
      theme: TemaApp.escuro(),
      routerConfig: _roteador,
      locale: escolhido == null ? null : Locale(escolhido.codigo),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (sistema, _) => Locale(IdiomaApp.doSistema(sistema?.toLanguageTag() ?? '').codigo),
    );
  }
}
