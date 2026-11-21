// Idioma da interface: escolhido em Configurações, muda na hora e fica guardado;
// sem escolha, segue o sistema. As três traduções têm de cobrir as mesmas
// frases, senão uma tela aparece com buraco num dos idiomas.
import 'dart:convert';
import 'dart:io';

import 'package:anagram_app/aplicacao/idioma.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/app_de_teste.dart';
import '../apoio/demonstracao_na_tela.dart';

Set<String> _chaves(String idioma) {
  final arb = jsonDecode(File('lib/l10n/app_$idioma.arb').readAsStringSync()) as Map<String, dynamic>;
  return {for (final k in arb.keys) if (!k.startsWith('@')) k};
}

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

  testWidgets('should_follow_the_system_language_when_no_language_was_picked', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('es', 'AR')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await tester.pumpWidget(appDeTeste(idioma: null));
    await tester.pumpAndSettle();

    expect(find.text('ABRIR DEMOSTRACIÓN'), findsOneWidget);
  });

  test('should_fall_back_to_english_when_the_system_language_is_not_one_of_the_three', () {
    expect(IdiomaApp.doSistema('fr-FR'), IdiomaApp.ingles);
    expect(IdiomaApp.doSistema('pt_BR'), IdiomaApp.portugues);
    expect(IdiomaApp.doSistema('es-419'), IdiomaApp.espanhol);
  });

  test('should_have_the_same_sentences_in_portuguese_english_and_spanish', () {
    final portugues = _chaves('pt');

    expect(_chaves('en'), portugues, reason: 'falta ou sobra tradução em inglês');
    expect(_chaves('es'), portugues, reason: 'falta ou sobra tradução em espanhol');
  });
}
