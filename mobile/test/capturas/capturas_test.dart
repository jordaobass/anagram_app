// Capturas das telas principais em modo demonstração, com as fontes reais,
// em três tamanhos. Gerar/atualizar: flutter test test/capturas --update-goldens
import 'dart:async';

import 'package:anagram_app/aplicacao/arte/indice_miniaturas.dart';
import 'package:anagram_app/aplicacao/estado/controlador_biblioteca.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/capturas_apoio.dart';
import '../apoio/fixtures.dart' show comMiniaturas;
import '../nucleo/catalogo_gabinetes_test.dart' show catalogoDeTeste;

void main() {
  setUpAll(carregarFontes);

  for (final t in tamanhos) {
    testWidgets('captura ${t.nome}: conectar', (tester) async {
      await preparar(tester, t);
      await capturar(tester, '$pasta/${t.nome}-1-conectar.png');
    });

    testWidgets('captura ${t.nome}: editor', (tester) async {
      await preparar(tester, t);
      await abrirPresetEditado(tester, t);
      await capturar(tester, '$pasta/${t.nome}-2-editor.png');
    });

    testWidgets('captura ${t.nome}: salvar', (tester) async {
      await preparar(tester, t);
      await abrirPresetEditado(tester, t);
      await tester.tap(find.byKey(const ValueKey('botao-salvar-como')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('slot-02B')));
      await tester.pumpAndSettle();
      await capturar(tester, '$pasta/${t.nome}-3-confirmar-salvar.png');
    });
  }

  testWidgets('captura celular-retrato: lista de presets', (tester) async {
    const t = Tamanho('celular-retrato', 390, 844, 2);
    await preparar(tester, t);
    await abrirPresetEditado(tester, t);
    await tester.tap(find.byKey(const ValueKey('abrir-lista')));
    await tester.pumpAndSettle();
    await capturar(tester, '$pasta/celular-retrato-4-lista.png');
  });

  testWidgets('captura desktop: cadeia paralela com split e merge', (tester) async {
    const t = Tamanho('desktop', 1440, 900, 1);
    await preparar(tester, t);
    final container = await abrirSlot(tester, '03A');
    container.read(editorProvider.notifier).selecionarBloco(const PosicaoBloco(2, 4));
    await tester.pumpAndSettle();
    await assentarImagens(tester);
    await capturar(tester, '$pasta/desktop-4-paralelo.png');
  });

  testWidgets('captura desktop-macos: editor', (tester) async {
    await preparar(tester, desktopMac);
    await abrirPresetEditado(tester, desktopMac);
    await capturar(tester, '$pasta/desktop-macos-2-editor.png');
  });

  testWidgets('captura desktop: área que não está ativa na pedaleira', (tester) async {
    await preparar(tester, desktopWindows);
    final container = await abrirSlot(tester, '02A');
    unawaited(container.read(bibliotecaProvider.notifier).selecionarArea('user-2'));
    await tester.pumpAndSettle();
    await capturar(tester, '$pasta/desktop-5-area-nao-ativa.png');
  });

  testWidgets('captura desktop: bloco desligado selecionado', (tester) async {
    await preparar(tester, desktopWindows);
    final container = await abrirSlot(tester, '02A');
    const posicao = PosicaoBloco(1, 2);
    unawaited(container.read(editorProvider.notifier).alternarBypass(posicao));
    container.read(editorProvider.notifier).selecionarBloco(posicao);
    await tester.pumpAndSettle();
    await capturar(tester, '$pasta/desktop-6-bloco-desligado.png');
  });

  // FILTER TONE (exemplo real 2): o gabinete com o IR "212 103 on axis_01-MP",
  // que no Darkglass Suite é o Darkglass Neo 2x12 (só com a arte da pedaleira)
  testWidgets('captura desktop: gabinete com o IR escolhido', (tester) async {
    await preparar(tester, desktopWindows);
    final container = await abrirSlot(tester, '01B');
    container.read(editorProvider.notifier).selecionarBloco(const PosicaoBloco(1, 9));
    await tester.pumpAndSettle();
    await assentarImagens(tester);
    await capturar(tester, '$pasta/desktop-7-gabinete.png');
  });

  // a escolha do gabinete em três cartões iguais (modelo com a foto, microfone,
  // posição), cada um com ‹ ›; sem a arte, a tabela de teste
  testWidgets('captura desktop: escolher o gabinete', (tester) async {
    await _abrirGabinete(tester, desktopWindows);
    await tester.ensureVisible(find.byKey(const ValueKey('cartao-gabinete')));
    await tester.pumpAndSettle();
    await assentarImagens(tester);
    await capturar(tester, '$pasta/desktop-10-escolher-gabinete.png');
  });

  // tocar na foto abre a galeria dos modelos, com a busca por texto
  testWidgets('captura desktop: buscar o gabinete na galeria', (tester) async {
    await _abrirGabinete(tester, desktopWindows);
    await tester.ensureVisible(find.byKey(const ValueKey('gabinete-abrir')));
    await tester.tap(find.byKey(const ValueKey('gabinete-abrir')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('galeria-busca')), comMiniaturas ? 'peg' : 'neo');
    await tester.pumpAndSettle();
    await assentarImagens(tester);
    await capturar(tester, '$pasta/desktop-11-buscar-gabinete.png');
  });

  testWidgets('captura celular: escolher o gabinete', (tester) async {
    await _abrirGabinete(tester, const Tamanho('celular-retrato', 390, 844, 2));
    // no celular o painel fica abaixo da cadeia: rola até os cartões aparecerem
    await tester.scrollUntilVisible(find.byKey(const ValueKey('cartao-microfone')), 300,
        scrollable: find.byType(Scrollable).first);
    // com os controles da pedaleira embaixo, a rolagem pode passar da foto
    await tester.ensureVisible(find.byKey(const ValueKey('gabinete-abrir')));
    await tester.pumpAndSettle();
    await assentarImagens(tester);
    await capturar(tester, '$pasta/celular-retrato-6-gabinete.png');
  });

  testWidgets('captura celular: galeria dos gabinetes com busca', (tester) async {
    await _abrirGabinete(tester, const Tamanho('celular-retrato', 390, 844, 2));
    // rola até o cartão de baixo, para a foto do gabinete ficar inteira na tela
    await tester.scrollUntilVisible(find.byKey(const ValueKey('cartao-microfone')), 300,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    // com os controles da pedaleira embaixo, a rolagem pode passar da foto
    await tester.ensureVisible(find.byKey(const ValueKey('gabinete-abrir')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('gabinete-abrir')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('galeria-busca')), comMiniaturas ? '4x10' : 'neo');
    await tester.pumpAndSettle();
    await assentarImagens(tester);
    await capturar(tester, '$pasta/celular-retrato-7-galeria-gabinete.png');
  });
}

/// 01B (exemplo real 2) com o Bass Cabinet selecionado e as escolhas do Suite.
Future<void> _abrirGabinete(WidgetTester tester, Tamanho tamanho) async {
  await preparar(tester, tamanho,
      indice: comMiniaturas ? null : IndiceMiniaturas(const {}, const {}, '', escolhasDeGabinete: catalogoDeTeste));
  final container = await abrirSlot(tester, '01B');
  container.read(editorProvider.notifier).selecionarBloco(const PosicaoBloco(1, 9));
  await tester.pumpAndSettle();
}
