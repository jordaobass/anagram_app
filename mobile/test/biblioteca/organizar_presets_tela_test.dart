// Pela tela: o menu do preset (botão direito ou o ⋮ da linha) leva a mover,
// clonar e trocar de banco; a lista passa a pedir o destino na faixa âmbar.
import 'package:anagram_app/aplicacao/estado/controlador_biblioteca.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';

void main() {
  testWidgets('should_move_the_preset_when_right_clicked_moved_and_the_destination_is_tapped', (tester) async {
    final container = await abrirDemonstracao(tester);
    final destino = SlotPreset.doRotulo('04B');
    final nome = container.read(bibliotecaProvider).resumo(SlotPreset.doRotulo('01A'))!.nome;
    expect(container.read(bibliotecaProvider).resumo(destino), isNull, reason: 'o 04B começa vazio');

    await tester.tap(find.byKey(const ValueKey('slot-01A')), buttons: kSecondaryButton);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('op-mover')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('faixa-organizar')), findsOneWidget, reason: 'a lista pede o destino');

    await tester.tap(find.byKey(const ValueKey('slot-04B')));
    // a pedaleira responde com atraso: avança o relógio até a lista mudar
    for (var i = 0; i < 40 && container.read(bibliotecaProvider).resumo(destino) == null; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pumpAndSettle();

    final biblioteca = container.read(bibliotecaProvider);
    expect(biblioteca.resumo(destino)?.nome, nome);
    expect(biblioteca.resumo(SlotPreset.doRotulo('01A')), isNull);
    expect(find.byKey(const ValueKey('faixa-organizar')), findsNothing);
  });

  testWidgets('should_offer_the_preset_menu_on_a_visible_button_for_who_does_not_right_click', (tester) async {
    await abrirDemonstracao(tester);

    await tester.tap(find.byKey(const ValueKey('menu-preset-01A')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('op-mover')), findsOneWidget);
    expect(find.byKey(const ValueKey('op-clonar')), findsOneWidget);
    expect(find.byKey(const ValueKey('op-banco')), findsOneWidget);
  });
}
