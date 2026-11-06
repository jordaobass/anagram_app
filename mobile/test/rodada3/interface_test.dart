// Correções de interface da rodada 3 (c5 e UX 1–5).
import 'dart:async';

import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/modelo/documento_preset.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/app_de_teste.dart';
import '../apoio/fixtures.dart';

Future<ProviderContainer> conectar(WidgetTester tester, Size tamanho, {double densidade = 1}) async {
  tester.view.physicalSize = tamanho * densidade;
  tester.view.devicePixelRatio = densidade;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(appDeTeste());
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('botao-demonstracao')));
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));
}

Future<void> abrir(WidgetTester tester, ProviderContainer c, String rotulo) async {
  unawaited(c.read(editorProvider.notifier).abrirSlot(SlotPreset.doRotulo(rotulo)));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('c5_should_open_the_list_in_destination_mode_on_phone_when_saving_without_slot', (tester) async {
    final c = await conectar(tester, const Size(390, 844), densidade: 2);
    unawaited(c.read(editorProvider.notifier).carregarDocumento(DocumentoPreset.doJson(lerExemplo('13'))));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('botao-salvar')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('faixa-escolher-destino')), findsOneWidget);
  });

  testWidgets('ux1_should_offer_undo_after_resetting_a_knob_and_undo_live', (tester) async {
    final c = await conectar(tester, const Size(1440, 900));
    await abrir(tester, c, '02A');
    c.read(editorProvider.notifier).alterarParametro('Threshold', -12, arrastando: false);
    await tester.pumpAndSettle();

    await tester.longPress(find.byKey(const ValueKey('param-Threshold')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('DESFAZER'));
    await tester.pumpAndSettle();

    final pedaleira = c.read(conexaoProvider.notifier).transporte! as TransporteDemonstracao;
    final tocando = pedaleira.presetTocando!['preset']['chains']['1']['blocks']['1']['parameters'] as Map;
    expect(c.read(editorProvider).blocoSelecionado!.valorBase('Threshold'), -12);
    expect(tocando.values.firstWhere((p) => p['symbol'] == 'Threshold')['value'], -12);
  });

  testWidgets('ux2_should_mark_the_origin_row_in_destination_mode', (tester) async {
    final c = await conectar(tester, const Size(1440, 900));
    await abrir(tester, c, '01C');
    await tester.tap(find.byKey(const ValueKey('botao-salvar-como')));
    await tester.pumpAndSettle();

    expect(find.descendant(of: find.byKey(const ValueKey('slot-01C')), matching: find.text('ORIGEM')), findsOneWidget);
    expect(find.descendant(of: find.byKey(const ValueKey('slot-02A')), matching: find.byIcon(Icons.save_alt)), findsOneWidget);
  });

  testWidgets('ux3_should_show_list_and_editor_on_ipad_portrait', (tester) async {
    await conectar(tester, const Size(820, 1180));
    expect(find.byKey(const ValueKey('slot-01A')), findsOneWidget);
  });

  testWidgets('ux4_should_say_the_disconnection_once', (tester) async {
    final c = await conectar(tester, const Size(1440, 900));
    await abrir(tester, c, '01C');
    (c.read(conexaoProvider.notifier).transporte! as TransporteDemonstracao).desconectar();
    await tester.pumpAndSettle();

    expect(find.textContaining('foi desconectada'), findsOneWidget);
  });

  testWidgets('ux5_should_mark_the_slot_the_pedal_is_on', (tester) async {
    final c = await conectar(tester, const Size(1440, 900));
    await abrir(tester, c, '02A');
    expect(find.descendant(of: find.byKey(const ValueKey('slot-02A')), matching: find.byKey(const ValueKey('na-pedaleira'))),
        findsOneWidget);
  });
}
