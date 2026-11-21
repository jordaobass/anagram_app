// Capturas dos estados que a revisão de coerência pediu e que as outras não
// cobriam: área que não é a ativa na pedaleira e o idioma escolhido na tela de
// conectar. Prefixo "tx-" para não cruzar com as capturas do editor.
import 'dart:async';

import 'package:anagram_app/aplicacao/estado/controlador_biblioteca.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/capturas_apoio.dart';
import '../apoio/demonstracao_na_tela.dart';

const _desktop = Tamanho('desktop', 1440, 900, 1);
const _celular = Tamanho('celular-retrato', 390, 844, 2);

Future<void> _foto(String nome) =>
    expectLater(find.byType(MaterialApp), matchesGoldenFile('$pasta/tx-$nome.png'));

void main() {
  setUpAll(carregarFontes);

  testWidgets('área escolhida que não é a ativa na pedaleira', (tester) async {
    await preparar(tester, _desktop);
    final container = await entrarNaDemonstracao(tester);
    unawaited(container.read(bibliotecaProvider.notifier).selecionarArea('user-2'));
    await tester.pumpAndSettle();
    await assentarImagens(tester);
    await _foto('01-area-nao-ativa');
  });

  testWidgets('idioma na tela de conectar, com o menu aberto', (tester) async {
    await preparar(tester, _celular);
    await tester.tap(find.byKey(const ValueKey('menu-idioma')));
    await tester.pumpAndSettle();
    await _foto('02-conectar-menu-idioma');
  });
}
