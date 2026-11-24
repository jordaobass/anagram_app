// Idioma da interface: escolhido em Configurações, muda na hora e fica guardado;
// sem escolha, segue o sistema. As quatro traduções têm de cobrir as mesmas
// frases, com os mesmos espaços para preencher, senão uma tela aparece com
// buraco ou com o nome do preset faltando num dos idiomas.
import 'dart:convert';
import 'dart:io';

import 'package:anagram_app/aplicacao/idioma.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/app_de_teste.dart';
import '../apoio/demonstracao_na_tela.dart';

Map<String, String> _frases(String idioma) {
  final arquivo = File('lib/l10n/app_$idioma.arb');
  if (!arquivo.existsSync()) return const {};
  final arb = jsonDecode(arquivo.readAsStringSync()) as Map<String, dynamic>;
  return {for (final e in arb.entries) if (!e.key.startsWith('@')) e.key: e.value as String};
}

Set<String> _chaves(String idioma) => _frases(idioma).keys.toSet();

// "{nome}" e o seletor de "{n, plural, …}" contam; o texto de cada ramo
// ("preset{PRESET}", "=1{1 atribuído}") não, porque é tradução.
final _espacoParaPreencher = RegExp(r'(?<![\w=])\{([A-Za-z_]\w*)\s*(,\s*(plural|select)\s*,)?');

Map<String, Set<String>> _espacos(String idioma) => {
      for (final MapEntry(key: chave, value: frase) in _frases(idioma).entries)
        chave: {
          for (final m in _espacoParaPreencher.allMatches(frase)) m.group(3) == null ? m.group(1)! : '${m.group(1)}:${m.group(3)}'
        },
    };

Future<void> _escolherNasConfiguracoes(WidgetTester tester, String codigo) async {
  await tester.tap(find.byKey(const ValueKey('botao-configuracoes')));
  await tester.pumpAndSettle();
  final opcao = find.byKey(ValueKey('idioma-$codigo'));
  await tester.scrollUntilVisible(opcao, 200, scrollable: find.byType(Scrollable).first);
  await tester.tap(opcao);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('should_switch_the_interface_language_and_keep_the_choice_when_english_is_picked_in_settings',
      (tester) async {
    final preferencias = PreferenciasIdiomaEmMemoria();
    await montarApp(tester, overrides: [preferenciasIdiomaProvider.overrideWithValue(preferencias)]);
    expect(find.text('ABRIR DEMONSTRAÇÃO'), findsOneWidget);

    await _escolherNasConfiguracoes(tester, 'en');

    expect(find.text('Settings'), findsOneWidget);
    expect(preferencias.salvo, 'en');
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('OPEN DEMO'), findsOneWidget);
  });

  testWidgets('should_switch_to_french_and_keep_the_choice_when_francais_is_picked_in_settings', (tester) async {
    final preferencias = PreferenciasIdiomaEmMemoria();
    await montarApp(tester, overrides: [preferenciasIdiomaProvider.overrideWithValue(preferencias)]);

    await _escolherNasConfiguracoes(tester, 'fr');

    expect(find.text('Paramètres'), findsOneWidget);
    expect(preferencias.salvo, 'fr');
    // pageBack procura a dica "Back"; em francês o botão diz "Retour"
    await tester.tap(find.byTooltip('Retour'));
    await tester.pumpAndSettle();
    expect(find.text('OUVRIR LA DÉMO'), findsOneWidget);
  });

  testWidgets('should_follow_the_system_language_when_no_language_was_picked', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('es', 'AR')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await tester.pumpWidget(appDeTeste(idioma: null));
    await tester.pumpAndSettle();

    expect(find.text('ABRIR DEMOSTRACIÓN'), findsOneWidget);
  });

  test('should_fall_back_to_english_when_the_system_language_is_not_one_of_the_four', () {
    expect(IdiomaApp.doSistema('de-DE'), IdiomaApp.ingles);
    expect(IdiomaApp.doSistema('pt_BR'), IdiomaApp.portugues);
    expect(IdiomaApp.doSistema('es-419'), IdiomaApp.espanhol);
    expect(IdiomaApp.doSistema('fr-CA'), IdiomaApp.frances);
  });

  test('should_have_the_same_sentences_in_portuguese_english_and_spanish', () {
    final portugues = _chaves('pt');

    expect(_chaves('en'), portugues, reason: 'falta ou sobra tradução em inglês');
    expect(_chaves('es'), portugues, reason: 'falta ou sobra tradução em espanhol');
  });

  test('should_have_in_french_exactly_the_english_sentences_with_the_same_placeholders', () {
    final ingles = _espacos('en');
    final frances = _espacos('fr');

    expect(frances.keys.toSet(), ingles.keys.toSet(), reason: 'falta ou sobra tradução em francês');
    for (final MapEntry(key: chave, value: espacos) in ingles.entries) {
      expect(frances[chave], espacos, reason: 'espaços para preencher diferentes em "$chave"');
    }
  });
}
