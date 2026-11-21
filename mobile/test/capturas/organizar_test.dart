// Capturas de organizar os presets: o menu do preset aberto pelo ⋮ da linha e
// a lista pedindo o slot de destino de um "Mover para…". Prefixo "op-".
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/capturas_apoio.dart';
import '../apoio/demonstracao_na_tela.dart';

const _desktop = Tamanho('desktop', 1440, 900, 1);
const _celular = Tamanho('celular-retrato', 390, 844, 2);

Future<void> _foto(String nome) =>
    expectLater(find.byType(MaterialApp), matchesGoldenFile('$pasta/op-$nome.png'));

Future<void> _abrirMenuDo01A(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('menu-preset-01A')));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(carregarFontes);

  testWidgets('menu do preset aberto pelo botão da linha', (tester) async {
    await preparar(tester, _desktop);
    await entrarNaDemonstracao(tester);
    await _abrirMenuDo01A(tester);
    await assentarImagens(tester);
    await _foto('01-menu-preset');
  });

  testWidgets('lista pedindo o destino de "Mover para…"', (tester) async {
    await preparar(tester, _desktop);
    await entrarNaDemonstracao(tester);
    await _abrirMenuDo01A(tester);
    await tester.tap(find.byKey(const ValueKey('op-mover')));
    await tester.pumpAndSettle();
    await assentarImagens(tester);
    await _foto('02-escolher-destino');
  });

  testWidgets('lista do celular com o menu do preset', (tester) async {
    await preparar(tester, _celular);
    // no celular a lista é outra tela: abre um preset e vai para a lista
    await abrirSlot(tester, '02A');
    await tester.tap(find.byKey(const ValueKey('abrir-lista')));
    await tester.pumpAndSettle();
    await _abrirMenuDo01A(tester);
    await _foto('03-celular-menu-preset');
  });
}
