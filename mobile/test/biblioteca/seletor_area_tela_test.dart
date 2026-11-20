// O seletor de área no topo da lista: escolher "Estudo" mostra os presets
// dela, avisa que ela não está ativa na pedaleira e "Tornar ativa" resolve.
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
    expect(find.text('Estudo · ativa na pedaleira'), findsOneWidget);
  });
}
