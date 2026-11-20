// "Salvar como" pela interface: a lista vira a escolha de destino.
import 'dart:async';

import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/modelo/documento_preset.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';
import '../apoio/fixtures.dart';

void main() {
  testWidgets('should_open_the_list_in_destination_mode_when_saving_without_slot_on_a_phone', (tester) async {
    final c = await abrirDemonstracao(tester, tamanho: telaCelular, densidade: 2);
    unawaited(c.read(editorProvider.notifier).carregarDocumento(DocumentoPreset.doJson(lerExemplo('13'))));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('botao-salvar')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('faixa-escolher-destino')), findsOneWidget);
  });

  testWidgets('should_mark_the_origin_row_when_choosing_a_destination', (tester) async {
    final c = await abrirDemonstracao(tester);
    unawaited(c.read(editorProvider.notifier).abrirSlot(SlotPreset.doRotulo('01C')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('botao-salvar-como')));
    await tester.pumpAndSettle();

    expect(find.descendant(of: find.byKey(const ValueKey('slot-01C')), matching: find.text('ORIGEM')), findsOneWidget);
    expect(find.descendant(of: find.byKey(const ValueKey('slot-02A')), matching: find.byIcon(Icons.save_alt)), findsOneWidget);
  });
}
