import 'package:anagram_app/apresentacao/telas/tela_presets.dart';
import 'package:go_router/go_router.dart';
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/protocolo/api_anagram.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';

Future<void> abrirNoCelular(WidgetTester tester, String rotulo) async {
  await abrirDemonstracao(tester, tamanho: telaCelular, densidade: 2);
  await tester.tap(find.text('VER PRESETS'));
  await tester.pumpAndSettle();
  await tocarNoSlot(tester, rotulo);
}

void main() {
  testWidgets('should_show_the_whole_chain_without_side_scrolling_when_on_a_phone', (tester) async {
    await abrirNoCelular(tester, '02A');
    for (final casa in [1, 2, 3, 5, 7]) {
      final retangulo = tester.getRect(find.byKey(ValueKey('casa-1-$casa')));
      expect(retangulo.right, lessThanOrEqualTo(390), reason: 'casa $casa precisa caber na largura');
    }
  });

  testWidgets('should_list_every_parameter_without_pages_when_on_a_phone', (tester) async {
    await abrirNoCelular(tester, '02C');
    await tester.tap(find.byKey(const ValueKey('casa-1-2')));
    await tester.pumpAndSettle();
    final rolagem = find.descendant(of: find.byKey(const ValueKey('rolagem-editor')), matching: find.byType(Scrollable));
    final ultimo = find.byKey(const ValueKey('param-arp_octaves'));
    await tester.scrollUntilVisible(ultimo, 300, scrollable: rolagem.first);
    expect(ultimo, findsOneWidget, reason: 'o 25º parâmetro sem trocar de página');
    expect(find.byTooltip('Próxima página'), findsNothing);
  });

  testWidgets('should_stay_on_the_editor_when_back_is_pressed_while_the_slot_is_still_opening', (tester) async {
    TransporteDemonstracao? pedaleira;
    await abrirDemonstracao(tester, tamanho: telaCelular, densidade: 2, overrides: [
      ajusteDemonstracaoProvider.overrideWithValue((p) => pedaleira = p),
    ]);
    await tester.tap(find.text('VER PRESETS'));
    await tester.pumpAndSettle();
    // a leitura fica pendurada: o slot ainda está abrindo quando a lista fecha
    pedaleira!.naoResponder = AcoesAnagram.lerPreset;

    await tester.tap(find.byKey(const ValueKey('slot-02A')));
    await tester.pump();
    tester.element(find.byType(TelaPresets)).pop();
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byKey(const ValueKey('lista-presets')), findsNothing);
    await tester.pump(const Duration(seconds: 30));

    expect(tester.takeException(), isNull, reason: 'a lista já fechada não pode tentar voltar de novo');
    expect(find.text('VER PRESETS'), findsOneWidget, reason: 'o editor continua na tela');
  });
}
