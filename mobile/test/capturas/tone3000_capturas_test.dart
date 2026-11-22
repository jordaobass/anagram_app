// Capturas da escolha de tom do TONE3000 (DECISOES T3K): o painel do NAM
// Loader com os cartões TOM e MODELO, a galeria com autor e licença, e o
// painel no celular. Prefixo "t3k-". Saem com as fotos
// reais dos tons.
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/capturas_apoio.dart';
import '../apoio/preset_tone3000.dart';

const _celular = Tamanho('celular-retrato', 390, 844, 2);

/// Alto o bastante para a cadeia, o cabeçalho do bloco e os cartões caberem juntos.
const _computadorAlto = Tamanho('desktop', 1440, 1200, 1, plataforma: TargetPlatform.windows);

Future<void> _abrirTone3000(WidgetTester tester, Tamanho tamanho) async {
  await preparar(tester, tamanho, overrides: [pedaleiraComTone3000()]);
  final container = await abrirSlot(tester, '01C');
  container.read(editorProvider.notifier).selecionarBloco(posicaoTone3000);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(carregarFontes);

  testWidgets('captura t3k: tom e modelo no painel do NAM Loader no computador', (tester) async {
    await _abrirTone3000(tester, _computadorAlto);
    await capturar(tester, '$pasta/t3k-01-desktop-tom-e-modelo.png');
  });

  testWidgets('captura t3k: galeria dos tons da pedaleira no computador', (tester) async {
    await _abrirTone3000(tester, _computadorAlto);
    await tester.tap(find.byKey(const ValueKey('tom-abrir')));
    await tester.pumpAndSettle();
    await capturar(tester, '$pasta/t3k-02-desktop-galeria-dos-tons.png');
  });

  testWidgets('captura t3k: tom e modelo no celular', (tester) async {
    await _abrirTone3000(tester, _celular);
    await tester.scrollUntilVisible(find.byKey(const ValueKey('cartao-modelo-tom')), 300,
        scrollable: find.byType(Scrollable).first);
    await tester.ensureVisible(find.byKey(const ValueKey('tom-abrir')));
    await tester.pumpAndSettle();
    await capturar(tester, '$pasta/t3k-03-celular-tom-e-modelo.png');
  });
}
