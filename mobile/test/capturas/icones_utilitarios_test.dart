// Captura dos ícones próprios dos utilitários internos (DECISOES A19), ligados
// e desligados, para conferir de olho que cada função se distingue.
import 'package:anagram_app/aplicacao/arte/indice_miniaturas.dart';
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/apresentacao/componentes/arte_bloco.dart';
import 'package:anagram_app/apresentacao/tema/tema_app.dart';
import 'package:anagram_app/apresentacao/tema/tokens.dart';
import 'package:anagram_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/capturas_apoio.dart';
import '../apoio/fixtures.dart';

const _utilitarios = [
  'urn:darkglass:Tuner',
  'urn:darkglass-anagram:mixer',
  'urn:darkglass-anagram:meters',
  'http://gareus.org/oss/lv2/modmeter',
  'http://gareus.org/oss/lv2/modspectre',
  'urn:darkglass-anagram:midi-cc-helper',
  'urn:darkglass-anagram:midi-pc-gen',
  'urn:darkglass-anagram:sine-gen',
  'urn:darkglass-anagram:exp-pedal',
  'http://looperlative.com/plugins/lp3-anagram',
];

Widget _ficha(String uri, {required bool ligado}) {
  final definicao = lerCatalogo().definicao(uri);
  return SizedBox(
    width: 112,
    child: Column(children: [
      ArteBlocoWidget(definicao: definicao, tamanho: 96, ligado: ligado),
      const SizedBox(height: Espacos.xs),
      Text(definicao.nome, textAlign: TextAlign.center, maxLines: 2),
    ]),
  );
}

void main() {
  testWidgets('captura: ícones próprios dos utilitários', (tester) async {
    await carregarFontes();
    tester.view
      ..physicalSize = const Size(1240, 380)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(ProviderScope(
      overrides: [indiceMiniaturasProvider.overrideWith((ref) async => IndiceMiniaturas.vazio())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: TemaApp.escuro(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(Espacos.l),
            child: Wrap(spacing: Espacos.s, runSpacing: Espacos.m, children: [
              for (final uri in _utilitarios) _ficha(uri, ligado: true),
              for (final uri in _utilitarios.take(5)) _ficha(uri, ligado: false),
            ]),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    await capturar(tester, '$pasta/ar-01-icones-utilitarios.png');
  });
}
