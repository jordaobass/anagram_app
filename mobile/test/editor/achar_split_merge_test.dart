// A linha paralela tem de ser achável por onde a pessoa procura: na
// biblioteca de efeitos (o par Split + Merge), na faixa da linha 2 e no menu
// do bloco ("dividir o sinal depois deste bloco").
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/catalogo/biblioteca_blocos.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';
import '../apoio/fixtures.dart';

Finder _casa(int linha, int casa) => find.byKey(ValueKey('casa-$linha-$casa'));

String? _uriEm(ProviderContainer c, int linha, int casa) => c.read(editorProvider).atual!.bloco(PosicaoBloco(linha, casa))?.uri;

int? _casaDe(ProviderContainer c, String fim) =>
    c.read(editorProvider).atual!.blocosDaLinha(1).where((b) => b.uri.endsWith(fim)).firstOrNull?.posicao.casa;

/// 02A ("Sujo de Ensaio"): linha 1 em 1, 2, 3, 5 e 7, sem linha paralela.
Future<ProviderContainer> _abrirSemParalela(WidgetTester tester) async {
  final container = await abrirDemonstracao(tester);
  await tocarNoSlot(tester, '02A');
  expect(_casaDe(container, ':split'), isNull);
  return container;
}

void main() {
  test('should_find_the_split_merge_pair_by_the_words_people_use_and_not_by_a_single_letter', () {
    final catalogo = lerCatalogo();
    bool achou(String busca) => bibliotecaComLinhaParalela(catalogo, busca: busca).any((g) => g.linhaParalela != null);

    for (final busca in ['split', 'Merge', 'paralel', 'parallel', 'dividir', 'linha paralela']) {
      expect(achou(busca), isTrue, reason: busca);
    }
    expect(achou('a'), isFalse);
    expect(achou('chorus'), isFalse);
  });

  testWidgets('should_put_split_on_the_tapped_slot_and_merge_next_when_the_pair_is_picked_in_the_library', (tester) async {
    final container = await _abrirSemParalela(tester);

    await tester.tap(_casa(1, 4));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('busca-efeito')), 'paralel');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('efeito-linha-paralela')));
    await tester.pumpAndSettle();

    expect(_uriEm(container, 1, 4), 'urn:darkglass-anagram:split');
    expect(_casaDe(container, ':merge'), greaterThan(4));
    expect(find.text('NÃO SALVO'), findsOneWidget);
  });

  testWidgets('should_show_the_pair_disabled_with_the_reason_when_the_preset_already_has_a_parallel_row', (tester) async {
    await abrirDemonstracao(tester);
    await tocarNoSlot(tester, '03A'); // Split 1·2, Merge 1·5, a casa 1·3 vazia

    await tester.tap(_casa(1, 3));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('busca-efeito')), 'split');
    await tester.pumpAndSettle();

    expect(tester.widget<ListTile>(find.byKey(const ValueKey('efeito-linha-paralela'))).enabled, isFalse);
    expect(find.textContaining('já tem linha paralela'), findsOneWidget);
  });

  testWidgets('should_create_the_parallel_row_when_the_dashed_strip_in_place_of_row_two_is_tapped_on_a_phone',
      (tester) async {
    final container = await abrirDemonstracao(tester, tamanho: telaCelular, densidade: 2);
    await tester.tap(find.text('VER PRESETS'));
    await tester.pumpAndSettle();
    await tocarNoSlot(tester, '02A');

    await tester.tap(find.byKey(const ValueKey('faixa-criar-linha-paralela')));
    await tester.pumpAndSettle();

    expect(_casaDe(container, ':split'), isNotNull);
    expect(_casaDe(container, ':merge'), isNotNull);
    expect(find.byKey(const ValueKey('faixa-criar-linha-paralela')), findsNothing, reason: 'a linha 2 vira casas');
  });

  testWidgets('should_split_right_after_the_block_when_the_block_menu_asks_to_split_the_signal_after_it',
      (tester) async {
    final container = await _abrirSemParalela(tester);

    await tester.tap(_casa(1, 3), buttons: kSecondaryMouseButton, kind: PointerDeviceKind.mouse);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('menu-dividir-sinal')));
    await tester.pumpAndSettle();

    expect(_casaDe(container, ':split'), 4, reason: 'a primeira casa livre depois do bloco 3');
    expect(_casaDe(container, ':merge'), greaterThan(4));
  });
}
