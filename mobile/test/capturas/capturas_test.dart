// Capturas das telas principais em modo demonstração, com as fontes reais,
// em três tamanhos. Gerar/atualizar: flutter test test/capturas --update-goldens
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/capturas_apoio.dart';

void main() {
  setUpAll(carregarFontes);

  for (final t in tamanhos) {
    testWidgets('captura ${t.nome}: conectar', (tester) async {
      await preparar(tester, t);
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('$pasta/${t.nome}-1-conectar.png'));
    });

    testWidgets('captura ${t.nome}: editor', (tester) async {
      await preparar(tester, t);
      await abrirPresetEditado(tester, t);
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('$pasta/${t.nome}-2-editor.png'));
    });

    testWidgets('captura ${t.nome}: salvar', (tester) async {
      await preparar(tester, t);
      await abrirPresetEditado(tester, t);
      await tester.tap(find.byKey(const ValueKey('botao-salvar-como')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('slot-02B')));
      await tester.pumpAndSettle();
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('$pasta/${t.nome}-3-confirmar-salvar.png'));
    });
  }

  testWidgets('captura celular-retrato: lista de presets', (tester) async {
    const t = Tamanho('celular-retrato', 390, 844, 2);
    await preparar(tester, t);
    await abrirPresetEditado(tester, t);
    await tester.tap(find.byKey(const ValueKey('abrir-lista')));
    await tester.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('$pasta/celular-retrato-4-lista.png'));
  });

  testWidgets('captura desktop: cadeia paralela com split e merge', (tester) async {
    const t = Tamanho('desktop', 1440, 900, 1);
    await preparar(tester, t);
    final container = await abrirSlot(tester, '03A');
    container.read(editorProvider.notifier).selecionarBloco(const PosicaoBloco(2, 4));
    await tester.pumpAndSettle();
    await assentarImagens(tester);
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('$pasta/desktop-4-paralelo.png'));
  });
}
