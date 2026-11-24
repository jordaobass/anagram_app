// Capturas do bloco do Marketplace (prefixo "mk-", DECISOES P4): o "Nebula
// Synth (demo)" instalado na pedaleira de demonstração, fora do catálogo de
// fábrica, na biblioteca de adicionar efeito e no painel com os parâmetros
// que a pedaleira descreve.
import 'package:anagram_app/nucleo/demonstracao/plugins_demonstracao.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/capturas_apoio.dart';

Future<void> _bibliotecaComNebula(WidgetTester tester) async {
  await preparar(tester, desktopWindows);
  await abrirSlot(tester, '01A');
  await tester.tap(find.byKey(const ValueKey('casa-1-4')));
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const ValueKey('busca-efeito')), 'nebula');
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(carregarFontes);

  testWidgets('captura mk: bloco do Marketplace na biblioteca', (tester) async {
    await _bibliotecaComNebula(tester);
    await capturar(tester, '$pasta/mk-01-desktop-biblioteca-marketplace.png');
  });

  testWidgets('captura mk: painel do bloco do Marketplace', (tester) async {
    await _bibliotecaComNebula(tester);
    await tester.tap(find.byKey(const ValueKey('efeito-$uriNebulaDemonstracao')));
    await tester.pumpAndSettle();
    await capturar(tester, '$pasta/mk-02-desktop-painel-marketplace.png');
  });
}
