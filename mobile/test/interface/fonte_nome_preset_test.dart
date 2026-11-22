// O nome do preset é dado do usuário e tem de ler bem de longe: o marcador
// (Permanent Marker) foi chamado de "very ugly" no Reddit e custava leitura.
// Na fita e na lista o nome vai na família de rótulo do case; o marcador
// sobra só no nome fixo do app, na tela de conectar.
import 'dart:async';

import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/apresentacao/tema/tokens.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';

String? _familiaDo(WidgetTester tester, Finder onde, String texto) {
  final elemento = find.descendant(of: onde, matching: find.text(texto)).evaluate().single;
  return DefaultTextStyle.of(elemento).style.merge((elemento.widget as Text).style).fontFamily;
}

void main() {
  testWidgets('should_write_the_preset_name_in_a_legible_face_on_the_tape_and_in_the_list', (tester) async {
    final c = await abrirDemonstracao(tester);
    unawaited(c.read(editorProvider.notifier).abrirSlot(SlotPreset.doRotulo('02A')));
    await tester.pumpAndSettle();

    expect(_familiaDo(tester, find.byKey(const ValueKey('fita-nome')), 'Sujo de Ensaio'), Fontes.rotulo);
    expect(_familiaDo(tester, find.byKey(const ValueKey('slot-02A')), 'Sujo de Ensaio'), isNot(Fontes.marcador));
  });
}
