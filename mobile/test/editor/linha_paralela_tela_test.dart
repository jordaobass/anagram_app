// Montar a linha paralela como qualquer cadeia (DECISOES M11): o Split posto
// numa casa da linha 1 "abre abaixo" e toca ao vivo; o Merge posto depois
// "junta acima"; tirar o Split com blocos na linha 2 pergunta antes.
import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:anagram_app/nucleo/protocolo/api_anagram.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';

const _split = 'urn:darkglass-anagram:split';
const _merge = 'urn:darkglass-anagram:merge';

String? _uriEm(ProviderContainer c, int linha, int casa) => c.read(editorProvider).atual!.bloco(PosicaoBloco(linha, casa))?.uri;

bool _temNaLinha1(ProviderContainer c, String uri) => c.read(editorProvider).atual!.blocosDaLinha(1).any((b) => b.uri == uri);

int _tocadosAoVivo(ProviderContainer c) => (c.read(conexaoProvider.notifier).transporte! as TransporteDemonstracao)
    .comandosRecebidos
    .where((m) => m.acao == AcoesAnagram.tocarAoVivo)
    .length;

Future<void> _porPelaBiblioteca(WidgetTester tester, int casa, String busca, String uri) async {
  await tester.tap(find.byKey(ValueKey('casa-1-$casa')));
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const ValueKey('busca-efeito')), busca);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(ValueKey('efeito-$uri')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('should_open_row_two_with_a_split_and_join_it_back_with_a_merge_picked_one_at_a_time', (tester) async {
    final container = await abrirDemonstracao(tester);
    await tocarNoSlot(tester, '02A'); // linha 1 em 1, 2, 3, 5 e 7, sem Split
    final antes = _tocadosAoVivo(container);

    await _porPelaBiblioteca(tester, 4, 'split', _split);

    expect(_uriEm(container, 1, 4), _split, reason: 'o Split vai na casa tocada');
    expect(_temNaLinha1(container, _merge), isFalse, reason: 'o Merge não entra sozinho');
    expect(_tocadosAoVivo(container), greaterThan(antes), reason: 'ao vivo: a pedaleira já toca com a divisão');

    await _porPelaBiblioteca(tester, 6, 'merge', _merge);

    expect(_uriEm(container, 1, 6), _merge);
    expect(find.text('NÃO SALVO'), findsOneWidget);
  });

  testWidgets('should_refuse_a_merge_before_the_split_with_a_short_notice', (tester) async {
    final container = await abrirDemonstracao(tester);
    await tocarNoSlot(tester, '02A');
    await _porPelaBiblioteca(tester, 6, 'split', _split);

    await tester.tap(find.byKey(const ValueKey('casa-1-4')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('busca-efeito')), 'merge');
    await tester.pumpAndSettle();

    expect(tester.widget<ListTile>(find.byKey(const ValueKey('efeito-$_merge'))).enabled, isFalse);
    expect(find.textContaining('Split precisa ficar antes do Merge'), findsOneWidget);
    expect(_temNaLinha1(container, _merge), isFalse);
  });

  testWidgets('should_ask_and_then_remove_split_merge_and_row_two_when_the_split_is_removed_with_row_two_blocks',
      (tester) async {
    final container = await abrirDemonstracao(tester);
    await tocarNoSlot(tester, '03A'); // "Paralelo Grave": Split 1·2, Merge 1·5, Lo-pass e Chorus na linha 2

    await tester.tap(find.byKey(const ValueKey('casa-1-2')), buttons: kSecondaryMouseButton, kind: PointerDeviceKind.mouse);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remover bloco'));
    await tester.pumpAndSettle();
    expect(_temNaLinha1(container, _split), isTrue, reason: 'antes de confirmar nada muda');

    await tester.tap(find.byKey(const ValueKey('confirmar-remover-split')));
    await tester.pumpAndSettle();

    expect(_temNaLinha1(container, _split), isFalse);
    expect(_temNaLinha1(container, _merge), isFalse);
    expect(container.read(editorProvider).atual!.blocosDaLinha(2), isEmpty);
  });

  testWidgets('should_remove_only_the_merge_when_the_merge_is_removed', (tester) async {
    final container = await abrirDemonstracao(tester);
    await tocarNoSlot(tester, '03A');

    await tester.tap(find.byKey(const ValueKey('casa-1-5')), buttons: kSecondaryMouseButton, kind: PointerDeviceKind.mouse);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remover bloco'));
    await tester.pumpAndSettle();

    expect(_temNaLinha1(container, _merge), isFalse);
    expect(_temNaLinha1(container, _split), isTrue);
    expect(container.read(editorProvider).atual!.blocosDaLinha(2), isNotEmpty, reason: 'a linha 2 segue até a saída');
  });
}
