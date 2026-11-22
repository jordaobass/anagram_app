// Os utilitários internos da pedaleira (afinador, mixer, medidores, MIDI,
// gerador, pedal de expressão, looper) não têm arte em fonte nenhuma: ganham
// um ícone próprio desenhado pela função, em vez da arte genérica da família.
import 'package:anagram_app/aplicacao/arte/indice_miniaturas.dart';
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/apresentacao/componentes/arte_bloco.dart';
import 'package:anagram_app/apresentacao/componentes/pintor_arte_utilitario.dart';
import 'package:anagram_app/l10n/app_localizations.dart';
import 'package:anagram_app/nucleo/catalogo/utilitario_bloco.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';

void main() {
  final catalogo = lerCatalogo();

  test('should_give_every_catalog_block_its_own_art_instead_of_the_generic_family_art', () {
    final indice = lerIndiceVersionado();

    final genericos = [
      for (final bloco in catalogo.todos)
        if (indice.arteDe(bloco) is ArteDaFamilia) bloco.uri,
    ];

    expect(genericos, isEmpty);
  });

  test('should_pick_the_utility_icon_by_the_block_function', () {
    final esperado = {
      'urn:darkglass:Tuner': TipoUtilitario.afinador,
      'urn:darkglass-anagram:mixer': TipoUtilitario.mixer,
      'urn:darkglass-anagram:meters': TipoUtilitario.vu,
      'http://gareus.org/oss/lv2/modmeter': TipoUtilitario.medidor,
      'http://gareus.org/oss/lv2/modspectre': TipoUtilitario.espectro,
      'urn:darkglass-anagram:midi-cc-helper': TipoUtilitario.midiCc,
      'urn:darkglass-anagram:midi-pc-gen': TipoUtilitario.midiPc,
      'urn:darkglass-anagram:sine-gen': TipoUtilitario.senoide,
      'urn:darkglass-anagram:exp-pedal': TipoUtilitario.pedalExpressao,
      'http://looperlative.com/plugins/lp3-anagram': TipoUtilitario.looper,
    };

    expect({for (final uri in esperado.keys) uri: utilitarioDaUri(uri)}, esperado);
    expect(utilitarioDaUri('urn:darkglass:Chorus'), isNull);
  });

  testWidgets('should_paint_the_tuner_icon_even_without_the_art_index', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [indiceMiniaturasProvider.overrideWith((ref) async => IndiceMiniaturas.vazio())],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ArteBlocoWidget(definicao: catalogo.definicao('urn:darkglass:Tuner'), tamanho: 64),
      ),
    ));
    await tester.pump();

    final pintores = tester.widgetList<CustomPaint>(find.byType(CustomPaint)).map((c) => c.painter);
    expect(pintores.whereType<PintorArteUtilitario>().single.tipo, TipoUtilitario.afinador);
  });
}
