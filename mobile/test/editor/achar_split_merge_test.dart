// Split e Merge ficam na biblioteca como os outros blocos, cada um no seu
// item (DECISOES M11): achados pelo nome e pelas palavras que a pessoa usa,
// e apagados com o motivo quando não podem entrar na casa tocada.
import 'package:anagram_app/nucleo/catalogo/biblioteca_blocos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';
import '../apoio/fixtures.dart';

const _split = 'urn:darkglass-anagram:split';
const _merge = 'urn:darkglass-anagram:merge';

Finder _item(String uri) => find.byKey(ValueKey('efeito-$uri'));

Future<void> _buscarNaCasa(WidgetTester tester, int linha, int casa, String busca) async {
  await tester.tap(find.byKey(ValueKey('casa-$linha-$casa')));
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const ValueKey('busca-efeito')), busca);
  await tester.pumpAndSettle();
}

void main() {
  test('should_find_split_and_merge_by_name_and_by_the_words_people_use_but_not_by_a_single_letter', () {
    final catalogo = lerCatalogo();
    Set<String> achados(String busca) =>
        {for (final g in blocosDaBiblioteca(catalogo, busca: busca)) for (final b in g.blocos) b.uri};

    for (final busca in ['split', 'paralel', 'parallel', 'dividir']) {
      expect(achados(busca), contains(_split), reason: busca);
    }
    for (final busca in ['Merge', 'juntar', 'paralela']) {
      expect(achados(busca), contains(_merge), reason: busca);
    }
    expect(achados('chorus'), isNot(contains(_split)));
  });

  testWidgets('should_list_split_and_merge_as_two_separate_items_with_the_merge_disabled_until_there_is_a_split',
      (tester) async {
    await abrirDemonstracao(tester);
    await tocarNoSlot(tester, '02A'); // linha 1 em 1, 2, 3, 5 e 7, sem Split

    await _buscarNaCasa(tester, 1, 4, 'paralel');

    expect(tester.widget<ListTile>(_item(_split)).enabled, isTrue);
    expect(tester.widget<ListTile>(_item(_merge)).enabled, isFalse);
    expect(find.textContaining('Coloque o Split antes'), findsOneWidget);
  });

  testWidgets('should_show_a_second_split_disabled_with_the_reason_instead_of_hiding_it', (tester) async {
    await abrirDemonstracao(tester);
    await tocarNoSlot(tester, '03A'); // Split 1·2, Merge 1·5, a casa 1·3 vazia

    await _buscarNaCasa(tester, 1, 3, 'split');

    expect(tester.widget<ListTile>(_item(_split)).enabled, isFalse);
    expect(find.textContaining('já tem um Split'), findsOneWidget);
  });

  testWidgets('should_warn_in_the_library_that_row_two_gets_no_signal_when_there_is_no_split', (tester) async {
    await abrirDemonstracao(tester);
    await tocarNoSlot(tester, '02A');

    await tester.tap(find.byKey(const ValueKey('casa-2-1')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('aviso-linha2-sem-split')), findsOneWidget);
  });
}
