// Split e Merge andam pela linha 1 arrastando (trocam com bloco comum), mas
// nunca vão para a linha 2 e o Split nunca passa do Merge: soltar ali é
// recusado com um aviso, e a linha 2 não muda.
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';

Finder _casa(int linha, int casa) => find.byKey(ValueKey('casa-$linha-$casa'));

String? _uriEm(ProviderContainer c, int linha, int casa) => c.read(editorProvider).atual!.bloco(PosicaoBloco(linha, casa))?.uri;

int? _casaDe(ProviderContainer c, String fim) =>
    c.read(editorProvider).atual!.blocosDaLinha(1).where((b) => b.uri.endsWith(fim)).firstOrNull?.posicao.casa;

Future<void> _arrastar(WidgetTester tester, Finder de, Finder para) async {
  final origem = tester.getCenter(de);
  final destino = tester.getCenter(para);
  final gesto = await tester.startGesture(origem, kind: PointerDeviceKind.mouse);
  for (final passo in [0.25, 0.5, 0.75, 1.0]) {
    await gesto.moveTo(Offset.lerp(origem, destino, passo)!);
    await tester.pump();
  }
  await gesto.up();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('should_move_split_right_and_merge_left_along_row_one_when_dragged', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    try {
      final container = await abrirDemonstracao(tester);
      await tocarNoSlot(tester, '03A'); // Split 1·2, vazia 1·3, B3K 1·4, Merge 1·5

      await _arrastar(tester, _casa(1, 2), _casa(1, 3));
      await _arrastar(tester, _casa(1, 5), _casa(1, 4));

      expect(_casaDe(container, ':split'), 3);
      expect(_casaDe(container, ':merge'), 4);
      expect(_uriEm(container, 1, 5), 'urn:darkglass:B3K', reason: 'o bloco comum vai para onde o Merge estava');
      expect(container.read(editorProvider).atual!.blocosDaLinha(2).map((b) => b.posicao.casa), [3, 4],
          reason: 'a linha 2 não muda');
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('should_refuse_with_a_short_notice_when_the_split_is_dropped_after_the_merge', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    try {
      final container = await abrirDemonstracao(tester);
      await tocarNoSlot(tester, '03A');

      await _arrastar(tester, _casa(1, 2), _casa(1, 6));

      expect(_casaDe(container, ':split'), 2);
      expect(_uriEm(container, 1, 6), 'urn:darkglass-anagram:cabinet-bass');
      expect(find.text('O Split precisa ficar antes do Merge na linha 1.'), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
