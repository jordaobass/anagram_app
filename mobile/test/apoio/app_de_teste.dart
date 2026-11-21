// O app inteiro com assets lidos do disco de forma síncrona: o carregamento
// em isolate do rootBundle (arquivo > 50 KB) não anda no relógio falso.
import 'package:anagram_app/apresentacao/app_anagram.dart';
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/aplicacao/versao_app.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import 'fixtures.dart';
import 'package:anagram_app/aplicacao/arte/indice_miniaturas.dart';
import 'package:anagram_app/aplicacao/idioma.dart';
import 'package:anagram_app/dados/preferencias_idioma.dart';

/// Latência fixa: a real varia de execução para execução e sujaria as capturas.
class CronometroFixo implements Stopwatch {
  @override
  Duration get elapsed => const Duration(milliseconds: 42);

  @override
  void start() {}

  @override
  void stop() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const versaoNasCapturas = '0.1.3';

/// [indice]: o índice de arte (o padrão é o das capturas, sem a arte de terceiros).
Widget appDeTeste(
        {List<Override> overrides = const [], IdiomaApp? idioma = IdiomaApp.portugues, IndiceMiniaturas? indice}) =>
    ProviderScope(
      overrides: [
        ...overrides,
        cronometroProvider.overrideWithValue(CronometroFixo.new),
        catalogoProvider.overrideWith((ref) async => lerCatalogo()),
        presetsDemonstracaoProvider.overrideWith((ref) async => lerPresetsDemonstracao()),
        indiceMiniaturasProvider.overrideWith((ref) async => indice ?? lerIndiceMiniaturas()),
        // versão fixa: com a do pubspec, toda release mudaria todas as capturas
        versaoAppProvider.overrideWith((ref) async => versaoNasCapturas),
        // o ambiente de teste é en-US: as capturas de referência são em português
        // (nulo = seguir o idioma do sistema)
        idiomaSalvoProvider.overrideWithValue(idioma),
      ],
      child: const AppAnagram(),
    );

/// Guarda a escolha de idioma só em memória (o teste não toca no disco).
class PreferenciasIdiomaEmMemoria implements PreferenciasIdioma {
  String? salvo;

  @override
  Future<String?> ler() async => salvo;

  @override
  Future<void> gravar(String? codigo) async => salvo = codigo;
}
