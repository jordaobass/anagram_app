// Os plugins do Darkglass Marketplace aparecem com a arte pública da loja
// (DECISOES A17), com crédito ao fabricante na tela Sobre. A arte da própria
// pedaleira continua vencendo na mesma uri.
import 'dart:io';

import 'package:anagram_app/aplicacao/arte/indice_miniaturas.dart';
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/apresentacao/telas/tela_creditos.dart';
import 'package:anagram_app/l10n/app_localizations.dart';
import 'package:anagram_app/nucleo/catalogo/definicao_bloco.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';

/// Os plugins de marketplace do catálogo de fábrica (fw 1.19.2.24) e os que
/// aparecem nos exemplos reais da pedaleira.
const _doMarketplace = [
  'urn:nembriniaudio:bassdriver',
  'urn:dirty-boys-audio:plugins:iv4n',
  'https://atlantida-audio.com/plugins/Groove_Preamp',
  'https://cognate.audio/plugins/cognate-aperture',
  'https://cognate.audio/plugins/cognate-metro',
  'https://cognate.audio/plugins/cognate-tuner',
  'https://falktx.com/plugins/auto-drummer',
  'https://shedspaceapp.com/plugins/ShedSpace',
  'https://fineclassicsplugins.com/plugins/FC_Punk_Sans',
  'urn:nembriniaudio:basshammer',
  'urn:nembriniaudio:clonminotaur',
  'urn:nembriniaudio:crunck',
];

void main() {
  test('should_have_the_marketplace_art_on_disk_for_every_marketplace_plugin_in_the_catalog_and_examples', () {
    final indice = lerIndiceVersionado();
    final catalogo = lerCatalogo();

    final semArte = [
      for (final uri in _doMarketplace)
        if (indice.arteDe(catalogo.definicao(uri)) case final arte
            when arte is! ArteMiniatura || !arte.caminhoAsset.contains('/mk_') || !File(arte.caminhoAsset).existsSync())
          uri,
    ];

    expect(semArte, isEmpty);
  });

  test('should_prefer_the_pedal_own_art_over_the_marketplace_art_on_the_same_uri', () {
    const texto = '''{"blocos": {
      "dg_x": {"nome": "", "origem": "pedaleira", "arquivo": "dg_X.png", "uris": ["urn:darkglass:x"]},
      "mk_x": {"nome": "X", "origem": "marketplace", "arquivo": "mk_x.png", "uris": ["urn:darkglass:x"]},
      "mk_y": {"nome": "Y", "origem": "marketplace", "arquivo": "mk_y.png", "uris": ["urn:loja:y"]},
      "y": {"nome": "Y", "arquivo": "y.png", "uris": ["urn:loja:y"]}}}''';
    final indice = IndiceMiniaturas.doTexto(texto);
    String arquivo(String uri) => (indice.arteDe(DefinicaoBloco.desconhecido(uri)) as ArteMiniatura).caminhoAsset;

    expect(arquivo('urn:darkglass:x'), 'dg_X.png');
    expect(arquivo('urn:loja:y'), 'mk_y.png', reason: 'a loja vence a miniatura de terceiros sem autorização');
  });

  testWidgets('should_credit_the_marketplace_makers_and_tone3000_on_the_about_screen', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [indiceMiniaturasProvider.overrideWith((ref) async => lerIndiceVersionado())],
      child: const MaterialApp(
        locale: Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TelaCreditos(),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('Nembrini Audio'), findsOneWidget);
    expect(find.textContaining('Cognate Audio'), findsOneWidget);
    expect(find.textContaining('TONE3000'), findsOneWidget);
  });
}
