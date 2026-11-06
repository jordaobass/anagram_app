// Capturas do editor nos tamanhos de iPad, nas duas orientações e em Split View.
import 'dart:async';

import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/capturas_apoio.dart';

const ipads = [
  Tamanho('ipad-mini-retrato', 744, 1133, 1),
  Tamanho('ipad-mini-paisagem', 1133, 744, 1),
  Tamanho('ipad-11-retrato', 834, 1194, 1),
  Tamanho('ipad-11-paisagem', 1194, 834, 1),
  Tamanho('ipad-13-paisagem', 1376, 1032, 1),
  Tamanho('ipad-split-metade', 678, 1024, 1),
];

void main() {
  setUpAll(carregarFontes);

  for (final t in ipads) {
    testWidgets('editor no ${t.nome}', (tester) async {
      await preparar(tester, t);
      final c = await abrirSlot(tester, '02A');
      unawaited(c.read(editorProvider.notifier).escolherCena(2));
      c.read(editorProvider.notifier).selecionarBloco(const PosicaoBloco(1, 3));
      await tester.pumpAndSettle();
      await assentarImagens(tester);
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('$pasta/ipad/${t.nome}.png'));
    });
  }
}
