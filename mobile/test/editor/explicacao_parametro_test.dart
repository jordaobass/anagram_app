// Balão do parâmetro na tela: com o mouse parado no rótulo, o texto do pedal
// (ou, sem ele, o do tipo); no toque, tocar no rótulo explica e segurar o
// knob continua voltando ao padrão.
import 'dart:async';

import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';
import '../apoio/fixtures.dart';

const _casa = PosicaoBloco(1, 4);

Future<ProviderContainer> _comBloco(WidgetTester tester, String uri, {ProviderContainer? container}) async {
  container ??= await abrirDemonstracao(tester, tamanho: const Size(1440, 2400));
  if (container.read(editorProvider).atual == null) await tocarNoSlot(tester, '01A');
  final notificador = container.read(editorProvider.notifier);
  if (container.read(editorProvider).atual!.bloco(_casa) != null) unawaited(notificador.removerBloco(_casa));
  await tester.pumpAndSettle();
  unawaited(notificador.adicionarBloco(_casa, lerCatalogo().definicao(uri)));
  await tester.pumpAndSettle();
  return container;
}

Future<void> _pararMouseNoRotulo(WidgetTester tester, TestGesture mouse, String simbolo) async {
  await mouse.moveTo(tester.getCenter(find.byKey(ValueKey('explicacao-$simbolo'))));
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('should_explain_the_parameter_for_this_pedal_when_the_mouse_rests_on_its_label', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);

    final container = await _comBloco(tester, 'urn:darkglass:CompLim');
    await _pararMouseNoRotulo(tester, mouse, 'Threshold');
    // o texto próprio do Compressor/Limiter, não o de "threshold" em geral
    expect(find.textContaining('vira limitador'), findsOneWidget);

    await mouse.moveTo(Offset.zero);
    await tester.pumpAndSettle();
    await _comBloco(tester, 'urn:darkglass:ChorusStereo', container: container);
    await _pararMouseNoRotulo(tester, mouse, 'Depth');
    // o chorus não tem texto próprio para Depth: vale o do tipo
    expect(find.textContaining('Intensidade da modulação'), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('should_explain_on_tapping_the_label_and_still_reset_on_holding_the_knob_on_a_touch_screen',
      (tester) async {
    final container = await _comBloco(tester, 'urn:darkglass:CompLim');
    final notificador = container.read(editorProvider.notifier);
    notificador.alterarParametro('Threshold', -50, arrastando: false, nome: 'Threshold', posicao: _casa);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('explicacao-Threshold')));
    await tester.pumpAndSettle();
    expect(find.textContaining('vira limitador'), findsOneWidget);
    expect(container.read(editorProvider).atual!.bloco(_casa)!.valorBase('Threshold'), -50,
        reason: 'tocar no rótulo só explica');

    // o balão do toque some sozinho; depois dele, segurar o knob é o de sempre
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.textContaining('vira limitador'), findsNothing);
    await tester.longPress(find.byKey(const ValueKey('param-Threshold')));
    await tester.pumpAndSettle();
    final padrao = lerCatalogo().definicao('urn:darkglass:CompLim').parametros.firstWhere((p) => p.simbolo == 'Threshold').padrao;
    expect(container.read(editorProvider).atual!.bloco(_casa)!.valorBase('Threshold'), padrao);
  });
}
