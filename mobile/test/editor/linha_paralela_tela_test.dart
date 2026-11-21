// Mandar o sinal para a linha de baixo e juntar de volta antes da saída: o
// botão embaixo da cadeia cria (ou remove) o Split e o Merge, ao vivo.
import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/protocolo/api_anagram.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';

bool _temNaLinha1(ProviderContainer c, String trecho) =>
    c.read(editorProvider).atual!.blocosDaLinha(1).any((b) => b.uri.endsWith(trecho));

int _tocadosAoVivo(ProviderContainer c) => (c.read(conexaoProvider.notifier).transporte! as TransporteDemonstracao)
    .comandosRecebidos
    .where((m) => m.acao == AcoesAnagram.tocarAoVivo)
    .length;

void main() {
  testWidgets('should_create_the_parallel_row_and_play_it_live_when_the_button_is_clicked', (tester) async {
    final container = await abrirDemonstracao(tester);
    await tocarNoSlot(tester, '02A');
    final antes = _tocadosAoVivo(container);

    await tester.tap(find.byKey(const ValueKey('criar-linha-paralela')));
    await tester.pumpAndSettle();

    expect(_temNaLinha1(container, ':split'), isTrue);
    expect(_temNaLinha1(container, ':merge'), isTrue);
    expect(_tocadosAoVivo(container), greaterThan(antes), reason: 'ao vivo: a pedaleira passa a tocar com a linha paralela');
    expect(find.text('NÃO SALVO'), findsOneWidget);
    expect(find.byKey(const ValueKey('remover-linha-paralela')), findsOneWidget);
  });

  testWidgets('should_ask_and_then_remove_split_merge_and_row_two_when_the_parallel_row_has_blocks', (tester) async {
    final container = await abrirDemonstracao(tester);
    await tocarNoSlot(tester, '03A'); // "Paralelo Grave": Lo-pass e Chorus na linha 2

    await tester.tap(find.byKey(const ValueKey('remover-linha-paralela')));
    await tester.pumpAndSettle();
    expect(_temNaLinha1(container, ':split'), isTrue, reason: 'antes de confirmar nada muda');

    await tester.tap(find.byKey(const ValueKey('confirmar-remover-linha-paralela')));
    await tester.pumpAndSettle();

    expect(_temNaLinha1(container, ':split'), isFalse);
    expect(_temNaLinha1(container, ':merge'), isFalse);
    expect(container.read(editorProvider).atual!.blocosDaLinha(2), isEmpty);
  });
}
