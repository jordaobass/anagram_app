// Monta o app (sem widgets) conectado à pedaleira de demonstração.
import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/escopo_cenas.dart';
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_de_teste.dart' show PreferenciasCenasEmMemoria;
import 'fixtures.dart';

Future<(ProviderContainer, TransporteDemonstracao)> conectarDemonstracao() async {
  final container = ProviderContainer(overrides: [
    presetsDemonstracaoProvider.overrideWith((ref) async => lerPresetsDemonstracao()),
    preferenciasCenasProvider.overrideWithValue(PreferenciasCenasEmMemoria()),
  ]);
  await container.read(conexaoProvider.notifier).conectarDemonstracao();
  final transporte = container.read(conexaoProvider.notifier).transporte! as TransporteDemonstracao;
  return (container, transporte);
}
