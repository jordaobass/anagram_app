// Montar a cadeia pela tela, como a pessoa faz: o "+" da casa vazia abre a
// biblioteca, o bloco muda de lugar arrastando (mouse ou segurando no toque)
// e, para quem não arrasta, pelo menu visível do painel.
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';

Finder _casa(int linha, int casa) => find.byKey(ValueKey('casa-$linha-$casa'));

String? _uriEm(ProviderContainer container, int linha, int casa) =>
    container.read(editorProvider).atual!.bloco(PosicaoBloco(linha, casa))?.uri;

Future<ProviderContainer> _abrirPresetComBuracos(WidgetTester tester) async {
  final container = await abrirDemonstracao(tester);
  // 01A é o exemplo real com a linha 1 em 1, 2, 3, 5…: a casa 4 está vazia
  await tocarNoSlot(tester, '01A');
  expect(_uriEm(container, 1, 4), isNull);
  return container;
}

Future<void> _arrastar(WidgetTester tester, Finder de, Finder para, {required PointerDeviceKind tipo}) async {
  // os centros antes de começar: durante o arrasto a cópia "na mão" repete a chave da casa
  final origem = tester.getCenter(de);
  final destino = tester.getCenter(para);
  final gesto = await tester.startGesture(origem, kind: tipo);
  if (tipo == PointerDeviceKind.touch) await tester.pump(kLongPressTimeout + const Duration(milliseconds: 100));
  for (final passo in [0.25, 0.5, 0.75, 1.0]) {
    await gesto.moveTo(Offset.lerp(origem, destino, passo)!);
    await tester.pump();
  }
  await gesto.up();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('should_put_the_picked_effect_in_the_grid_when_an_empty_slot_plus_is_tapped', (tester) async {
    final container = await _abrirPresetComBuracos(tester);

    await tester.tap(_casa(1, 4));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('busca-efeito')), 'suppress');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('efeito-urn:darkglass:Suppressor')));
    await tester.pumpAndSettle();

    expect(_uriEm(container, 1, 4), 'urn:darkglass:Suppressor');
    expect(container.read(editorProvider).selecionado, const PosicaoBloco(1, 4));
    expect(find.text('NÃO SALVO'), findsOneWidget);
  });

  testWidgets('should_explain_how_to_add_an_effect_when_a_new_preset_has_no_blocks', (tester) async {
    await abrirDemonstracao(tester);
    await tocarNoSlot(tester, '03C');

    await tester.tap(find.byKey(const ValueKey('botao-novo-preset')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('dica-montar-cadeia')), findsOneWidget);
  });

  testWidgets('should_move_the_block_when_dragged_with_the_mouse_onto_an_empty_slot', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    try {
      final container = await _abrirPresetComBuracos(tester);

      await _arrastar(tester, _casa(1, 1), _casa(1, 4), tipo: PointerDeviceKind.mouse);

      expect(_uriEm(container, 1, 4), 'urn:darkglass:Suppressor');
      expect(_uriEm(container, 1, 1), isNull);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('should_swap_blocks_when_one_is_held_and_dragged_onto_another_on_a_touch_screen', (tester) async {
    final container = await _abrirPresetComBuracos(tester);

    await _arrastar(tester, _casa(1, 1), _casa(1, 2), tipo: PointerDeviceKind.touch);

    expect(_uriEm(container, 1, 2), 'urn:darkglass:Suppressor');
    expect(_uriEm(container, 1, 1), 'urn:darkglass:wah');
  });

  testWidgets('should_move_the_selected_block_from_the_visible_actions_menu_when_not_dragging', (tester) async {
    final container = await _abrirPresetComBuracos(tester);
    await tester.tap(_casa(1, 1));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('mais-acoes-bloco')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mover para a direita'));
    await tester.pumpAndSettle();

    expect(_uriEm(container, 1, 2), 'urn:darkglass:Suppressor');
    expect(_uriEm(container, 1, 1), 'urn:darkglass:wah');
  });
}
