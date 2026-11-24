// A tela Sobre (versão, créditos, diagnóstico) se abre pelas Configurações,
// no computador e no celular: a barra não tem mais o "i" (DECISOES BS1).
import 'package:anagram_app/apresentacao/telas/tela_configuracoes.dart';
import 'package:anagram_app/apresentacao/telas/tela_creditos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';

void main() {
  testWidgets('should_open_the_about_screen_from_the_settings_on_a_computer', (tester) async {
    await montarApp(tester);
    expect(find.byTooltip('Créditos'), findsNothing, reason: 'o "i" saiu da barra');

    await tester.tap(find.byKey(const ValueKey('botao-configuracoes')));
    await tester.pumpAndSettle();
    final rolagem = find.descendant(of: find.byType(TelaConfiguracoes), matching: find.byType(Scrollable)).first;
    await tester.scrollUntilVisible(find.byKey(const ValueKey('abrir-sobre')), 300, scrollable: rolagem);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('abrir-sobre')));
    await tester.pumpAndSettle();

    expect(find.byType(TelaCreditos), findsOneWidget);
    expect(find.text('v0.1.3'), findsOneWidget, reason: 'a versão fica no Sobre');
  });

  testWidgets('should_open_the_about_screen_from_the_settings_when_on_a_phone', (tester) async {
    await montarApp(tester, tamanho: telaCelular, densidade: 2);
    expect(find.byTooltip('Créditos'), findsNothing, reason: 'o "i" saiu da barra');

    await tester.tap(find.byKey(const ValueKey('botao-configuracoes')));
    await tester.pumpAndSettle();
    final rolagem = find.descendant(of: find.byType(TelaConfiguracoes), matching: find.byType(Scrollable)).first;
    await tester.scrollUntilVisible(find.byKey(const ValueKey('abrir-sobre')), 300, scrollable: rolagem);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('abrir-sobre')));
    await tester.pumpAndSettle();

    expect(find.byType(TelaCreditos), findsOneWidget);
  });
}
