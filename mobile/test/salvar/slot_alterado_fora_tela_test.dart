// Pela tela: o slot aberto foi regravado na pedaleira depois de aberto. O
// SALVAR pergunta em vez de gravar, e recarregar mostra a versão de lá.
import 'dart:async';

import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';

void main() {
  testWidgets('should_ask_before_saving_over_a_slot_changed_on_the_pedal_and_reload_on_request', (tester) async {
    final c = await abrirDemonstracao(tester);
    final slot = SlotPreset.doRotulo('01C');
    unawaited(c.read(editorProvider.notifier).abrirSlot(slot));
    await tester.pumpAndSettle();
    final pedaleira = c.read(conexaoProvider.notifier).transporte! as TransporteDemonstracao;
    final conteudo = pedaleira.conteudoDoSlot(slot.numero)!;
    pedaleira.substituirSlot(
        slot.numero, {...conteudo, 'preset': {...conteudo['preset'] as Map<String, dynamic>, 'name': 'Da pedaleira'}});
    unawaited(c.read(editorProvider.notifier).renomear('Do app'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('botao-salvar')));
    await tester.pumpAndSettle();

    expect(find.textContaining('O slot 01C foi alterado na pedaleira desde que você abriu'), findsOneWidget);
    expect(find.byKey(const ValueKey('sobrescrever-slot-alterado')), findsOneWidget);
    expect(pedaleira.conteudoDoSlot(slot.numero)!['preset']['name'], 'Da pedaleira', reason: 'nada foi gravado');

    await tester.tap(find.byKey(const ValueKey('recarregar-slot-alterado')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirmar-recarregar')));
    await tester.pumpAndSettle();

    expect(c.read(editorProvider).atual!.nome, 'Da pedaleira');
    expect(c.read(editorProvider).naoSalvo, isFalse);
  });
}
