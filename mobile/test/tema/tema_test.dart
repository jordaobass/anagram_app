// Tema da interface: Sistema (padrão), Escuro ou Claro, escolhido nas
// Configurações e guardado. "Sistema" segue o brilho do aparelho, também
// quando ele muda com o app aberto (o modo automático do macOS ao anoitecer).
import 'package:anagram_app/aplicacao/tema.dart';
import 'package:anagram_app/apresentacao/tema/paleta.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/app_de_teste.dart';
import '../apoio/demonstracao_na_tela.dart';

Color _fundoDaTela(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(Scaffold).first)).scaffoldBackgroundColor;

void main() {
  testWidgets('should_follow_the_platform_brightness_when_the_theme_is_system', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await montarApp(tester, tema: EscolhaTema.sistema);
    expect(_fundoDaTela(tester), Paleta.clara.fundoCase);

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await tester.pumpAndSettle();
    expect(_fundoDaTela(tester), Paleta.escura.fundoCase);
  });

  testWidgets('should_start_following_the_system_when_no_theme_was_saved', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await montarApp(tester, tema: null);

    expect(_fundoDaTela(tester), Paleta.clara.fundoCase);
  });

  testWidgets('should_switch_to_light_and_keep_the_choice_when_light_is_picked_in_settings', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    final preferencias = PreferenciasTemaEmMemoria();
    await montarApp(tester, tema: EscolhaTema.sistema, overrides: [preferenciasTemaProvider.overrideWithValue(preferencias)]);
    expect(_fundoDaTela(tester), Paleta.escura.fundoCase);

    await tester.tap(find.byKey(const ValueKey('botao-configuracoes')));
    await tester.pumpAndSettle();
    final claro = find.byKey(const ValueKey('tema-claro'));
    await tester.scrollUntilVisible(claro, 200, scrollable: find.byType(Scrollable).first);
    await tester.tap(claro);
    await tester.pumpAndSettle();

    expect(preferencias.salvo, 'claro');
    expect(_fundoDaTela(tester), Paleta.clara.fundoCase);
  });

  test('should_read_a_saved_choice_and_ignore_an_unknown_one', () {
    expect(EscolhaTema.doCodigo('claro'), EscolhaTema.claro);
    expect(EscolhaTema.doCodigo('escuro'), EscolhaTema.escuro);
    expect(EscolhaTema.doCodigo('roxo'), isNull);
    expect(EscolhaTema.doCodigo(null), isNull);
  });
}
