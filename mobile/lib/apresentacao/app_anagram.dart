import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'rotas.dart';
import 'tema/tema_app.dart';

class AppAnagram extends StatefulWidget {
  const AppAnagram({super.key});

  static const titulo = 'Anagram App';

  @override
  State<AppAnagram> createState() => _AppAnagramState();
}

class _AppAnagramState extends State<AppAnagram> {
  late final GoRouter _roteador = criarRoteador();

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: AppAnagram.titulo,
        debugShowCheckedModeBanner: false,
        theme: TemaApp.escuro(),
        routerConfig: _roteador,
      );
}
