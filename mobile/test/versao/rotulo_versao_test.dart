// A versão fica à vista na barra de cima e diz se o build traz a arte da
// pedaleira: há builds com e sem ela, e a pessoa precisa saber qual abriu.
import 'package:anagram_app/aplicacao/arte/indice_miniaturas.dart';
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/aplicacao/versao_app.dart';
import 'package:anagram_app/apresentacao/componentes/barra_conexao.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:anagram_app/l10n/app_localizations.dart';

const _comArteDaPedaleira = '''
{"blocos": {"dg_b3k": {"nome": "", "origem": "pedaleira", "arquivo": "a.png", "uris": ["urn:darkglass:B3K"]}}}''';

Future<void> _montarBarra(WidgetTester tester, IndiceMiniaturas indice) async {
  await tester.pumpWidget(ProviderScope(
    overrides: [
      versaoAppProvider.overrideWith((ref) async => '0.1.3'),
      indiceMiniaturasProvider.overrideWith((ref) async => indice),
    ],
    child: const MaterialApp(
      locale: Locale('pt'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: BarraConexao(compacta: false)),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('should_show_the_version_and_the_pedal_art_mark_when_the_build_embeds_the_pedal_art', (tester) async {
    await _montarBarra(tester, IndiceMiniaturas.doTexto(_comArteDaPedaleira));

    expect(find.text('v0.1.3 · arte da pedaleira'), findsOneWidget);
  });

  testWidgets('should_show_only_the_version_when_the_build_has_the_app_own_art', (tester) async {
    await _montarBarra(tester, IndiceMiniaturas.vazio());

    expect(find.text('v0.1.3'), findsOneWidget);
    expect(find.textContaining('arte da pedaleira'), findsNothing);
  });
}
