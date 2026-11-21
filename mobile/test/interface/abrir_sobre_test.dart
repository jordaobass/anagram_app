// A tela Sobre (versão, créditos, diagnóstico) se abre pela rota: no
// computador pelo "i" da barra; no celular, que não tem o botão, pelas
// Configurações.
import 'package:anagram_app/apresentacao/telas/tela_configuracoes.dart';
import 'package:anagram_app/apresentacao/telas/tela_creditos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';

void main() {
  testWidgets('should_open_the_about_screen_when_the_info_button_of_the_wide_bar_is_tapped', (tester) async {
    await montarApp(tester);

    await tester.tap(find.byTooltip('Créditos'));
    await tester.pumpAndSettle();

    expect(find.byType(TelaCreditos), findsOneWidget);
    expect(find.text('v0.1.3'), findsOneWidget, reason: 'a versão fica no Sobre');
  });

  testWidgets('should_open_the_about_screen_from_the_settings_when_on_a_phone', (tester) async {
    await montarApp(tester, tamanho: telaCelular, densidade: 2);
    expect(find.byTooltip('Créditos'), findsNothing, reason: 'no celular o "i" não cabe na barra');

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
