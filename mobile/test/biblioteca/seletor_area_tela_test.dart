// O seletor de área no topo da lista: escolher "Estudo" mostra os presets
// dela, avisa que ela não está ativa na pedaleira e "Tornar ativa" resolve.
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';

void main() {
  testWidgets('should_show_the_area_presets_and_offer_to_activate_it_when_another_area_is_picked', (tester) async {
    await abrirDemonstracao(tester);
    expect(find.text('Escalas lentas'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('seletor-area')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Estudo').last);
    await tester.pumpAndSettle();

    expect(find.text('Escalas lentas'), findsOneWidget);
    expect(find.byKey(const ValueKey('tornar-area-ativa')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('tornar-area-ativa')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('tornar-area-ativa')), findsNothing);
    expect(find.byKey(const ValueKey('etiqueta-area-ativa')), findsOneWidget, reason: 'a escolhida agora é a ativa');
  });

  testWidgets('should_tell_on_the_list_that_the_area_did_not_switch_when_the_pedal_ignores_it', (tester) async {
    await abrirDemonstracao(tester,
        overrides: [ajusteDemonstracaoProvider.overrideWithValue((pedaleira) => pedaleira.ignorarTrocaDeArea = true)]);
    await tester.tap(find.byKey(const ValueKey('seletor-area')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Estudo').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('tornar-area-ativa')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('erro-lista')), findsOneWidget);
    expect(find.textContaining('A pedaleira não trocou de área'), findsOneWidget);
  });
}
