import 'dart:async';

import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/nucleo/midi/saida_midi.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';
import '../apoio/conexao_demo.dart';

void main() {
  test('should_switch_the_pedal_slot_by_program_change_when_opening_a_preset', () async {
    final (container, _) = await conectarDemonstracao();
    final midi = container.read(conexaoProvider.notifier).midi! as SaidaMidiDemonstracao;

    await container.read(editorProvider.notifier).abrirSlot(SlotPreset.doRotulo('17A'));

    expect(midi.mensagens.last, [0xC0, 49], reason: '17A = slot 49 = programa 49 (midi.py goto_slot)');
    expect(container.read(editorProvider).slotNaPedaleira, isTrue);
  });

  testWidgets('should_say_it_is_only_an_audition_when_there_is_no_midi', (tester) async {
    await abrirDemonstracao(tester, overrides: [midiDemonstracaoProvider.overrideWithValue(() => null)]);
    await tocarNoSlot(tester, '01C');

    expect(find.textContaining('a pedaleira continua no slot dela'), findsOneWidget);
  });

  testWidgets('should_mark_the_slot_the_pedal_is_on_when_a_preset_opens', (tester) async {
    final c = await abrirDemonstracao(tester);
    unawaited(c.read(editorProvider.notifier).abrirSlot(SlotPreset.doRotulo('02A')));
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byKey(const ValueKey('slot-02A')), matching: find.byKey(const ValueKey('na-pedaleira'))),
        findsOneWidget);
  });
}
