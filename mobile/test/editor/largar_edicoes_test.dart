// Tocar de novo no slot aberto relê o preset da pedaleira: com edição não
// salva, isso apagaria o trabalho sem aviso.
import 'dart:async';

import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';

void main() {
  testWidgets('should_ask_before_reloading_when_the_open_slot_is_tapped_with_unsaved_edits', (tester) async {
    final container = await abrirDemonstracao(tester);
    await tocarNoSlot(tester, '01A');
    // sem await: a edição toca ao vivo, e no relógio falso só o pump faz andar
    unawaited(container.read(editorProvider.notifier).renomear('Ainda não salvo'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('slot-01A')));
    await tester.pumpAndSettle();
    expect(find.text('Largar edições?'), findsOneWidget);

    await tester.tap(find.text('CONTINUAR EDITANDO'));
    await tester.pumpAndSettle();
    expect(container.read(editorProvider).atual!.nome, 'Ainda não salvo');
  });
}
