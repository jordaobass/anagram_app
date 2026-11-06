// O app inteiro com assets lidos do disco de forma síncrona: o carregamento
// em isolate do rootBundle (arquivo > 50 KB) não anda no relógio falso.
import 'package:anagram_app/apresentacao/app_anagram.dart';
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import 'fixtures.dart';

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

Widget appDeTeste({List<Override> overrides = const []}) => ProviderScope(
      overrides: [
        ...overrides,
        cronometroProvider.overrideWithValue(CronometroFixo.new),
        catalogoProvider.overrideWith((ref) async => lerCatalogo()),
        presetsDemonstracaoProvider.overrideWith((ref) async => lerPresetsDemonstracao()),
        indiceMiniaturasProvider.overrideWith((ref) async => lerIndiceMiniaturas()),
      ],
      child: const AppAnagram(),
    );
