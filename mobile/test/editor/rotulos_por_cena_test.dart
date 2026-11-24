// O rótulo do liga/desliga e o selo do knob dizem em que cenas o estado vale
// (issue #39, AnthonyBe): "DESLIGADO SÓ NA CENA 2" era mentira com o bloco
// desligado também na cena 3. No 02A da demonstração o Microtubes tem
// high_drive 5 / 5 / 8,5 nas cenas e o compressor está na casa 2.
import 'dart:async';

import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/app_com_mcp.dart' show pedaleiraDe;
import '../apoio/app_de_teste.dart';
import '../apoio/cinco_cenas.dart';
import '../apoio/demonstracao_na_tela.dart';

const _compressor = PosicaoBloco(1, 2);
const _microtubes = PosicaoBloco(1, 3);

Future<ProviderContainer> _abrir(WidgetTester tester, String slot) async {
  await montarApp(tester, preferenciasCenas: PreferenciasCenasEmMemoria());
  final container = await entrarNaDemonstracao(tester);
  await tocarNoSlot(tester, slot);
  return container;
}

Future<void> _naCena(WidgetTester tester, ProviderContainer container, int cena, {PosicaoBloco? bloco}) async {
  final editor = container.read(editorProvider.notifier);
  unawaited(editor.escolherCena(cena));
  if (bloco != null) editor.selecionarBloco(bloco);
  await tester.pumpAndSettle();
}

/// Desliga o bloco só nas [cenas] (Controlar: só a cena ativa).
Future<void> _desligarNas(WidgetTester tester, ProviderContainer container, PosicaoBloco bloco, List<int> cenas) async {
  for (final cena in cenas) {
    await _naCena(tester, container, cena);
    unawaited(container.read(editorProvider.notifier).alternarBypass(bloco));
    await tester.pumpAndSettle();
  }
}

void main() {
  testWidgets('should_say_off_in_scenes_2_and_3_when_the_block_is_off_in_both', (tester) async {
    final container = await _abrir(tester, '02A');
    await _desligarNas(tester, container, _compressor, [2, 3]);

    await _naCena(tester, container, 2, bloco: _compressor);

    expect(find.text('DESLIGADO NAS CENAS 2, 3'), findsOneWidget);
    expect(find.textContaining('SÓ NA CENA'), findsNothing, reason: 'não está desligado só na cena 2');
    await _naCena(tester, container, 1, bloco: _compressor);
    expect(find.text('LIGADO SÓ NA CENA 1'), findsOneWidget, reason: 'aqui o "só" é verdade');
  });

  testWidgets('should_mark_the_knob_with_the_scenes_that_share_its_value', (tester) async {
    final container = await _abrir(tester, '02A');

    await _naCena(tester, container, 1, bloco: _microtubes);
    await tester.ensureVisible(find.byKey(const ValueKey('param-high_drive')));
    await tester.pumpAndSettle();
    expect(find.text('NAS CENAS 1, 2'), findsOneWidget,
        reason: 'o 5 vale nas cenas 1 e 2; só a 3 tem 8,5');
    await _naCena(tester, container, 3, bloco: _microtubes);
    expect(find.text('SÓ NA CENA 3'), findsOneWidget);
  });

  testWidgets('should_say_it_varies_between_scenes_when_more_than_three_share_the_state', (tester) async {
    await montarApp(tester, preferenciasCenas: PreferenciasCenasEmMemoria());
    final container = await entrarNaDemonstracao(tester);
    pedaleiraDe(container).substituirSlot(3, presetCincoCenas());
    await tocarNoSlot(tester, '01C');
    await _desligarNas(tester, container, const PosicaoBloco(1, 1), [5]);

    await _naCena(tester, container, 1, bloco: const PosicaoBloco(1, 1));

    expect(find.text('LIGADO NESTA CENA · VARIA ENTRE AS CENAS'), findsOneWidget,
        reason: 'ligado em 1–4: números demais para caber');
  });
}
