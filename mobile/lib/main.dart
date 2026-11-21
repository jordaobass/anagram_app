import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'aplicacao/erros_nao_tratados.dart';
import 'aplicacao/idioma.dart';
import 'apresentacao/app_anagram.dart';
import 'dados/preferencias_idioma.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registrarErrosNaoTratados();
  // o idioma escolhido antes da primeira tela, para ela já nascer nele
  final salvo = IdiomaApp.doCodigo(await PreferenciasIdiomaLocais().ler());
  runApp(ProviderScope(
    overrides: [idiomaSalvoProvider.overrideWithValue(salvo)],
    child: const AppAnagram(),
  ));
}
