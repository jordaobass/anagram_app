// O Solo ligado pintava texto branco sobre a cor da banda (2,03 a 3,51:1).
// Ligado, em qualquer banda do Ignissor e do Entropia, o texto passa de
// 4,5:1 (WCAG AA) sobre o preenchimento.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../apoio/contraste.dart';
import '../../apoio/demonstracao_na_tela.dart';

Future<void> _ligarSolo(WidgetTester tester, Finder solo) async {
  await tester.ensureVisible(solo);
  await tester.pumpAndSettle();
  await tester.tap(solo);
  await tester.pumpAndSettle();
}

void main() {
  for (final uri in ['urn:darkglass:ignissor', 'urn:darkglass:entropia']) {
    testWidgets('should_keep_the_lit_solo_label_readable_on_every_band_of_$uri', (tester) async {
      await abrirComBloco(tester, uri, tamanho: const Size(1440, 2400));

      for (final banda in ['graves', 'medios', 'agudos']) {
        final solo = find.byKey(ValueKey('solo-$banda'));
        await _ligarSolo(tester, solo);
        final material = materialDoBotao(tester, solo);

        expect(contraste(material.textStyle!.color!, material.color!), greaterThanOrEqualTo(4.5), reason: banda);
      }
    });
  }
}
