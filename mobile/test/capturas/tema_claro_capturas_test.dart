// Capturas do tema claro (o case de alumínio): as mesmas telas das capturas
// escuras, para comparar lado a lado. Prefixo "tc-". Saem com a arte real dos
// pedais. Gerar/atualizar: flutter test test/capturas --update-goldens
import 'dart:async';

import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/aplicacao/tema.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/capturas_apoio.dart';
import '../apoio/demonstracao_na_tela.dart';
import '../apoio/fixtures.dart';

const _claro = EscolhaTema.claro;
const _celular = Tamanho('celular-retrato', 390, 844, 2);
const _computadorAlto = Tamanho('desktop', 1440, 1500, 1, plataforma: TargetPlatform.windows);

void main() {
  setUpAll(carregarFontes);

  testWidgets('captura tc: conectar no computador', (tester) async {
    await preparar(tester, desktopWindows, tema: _claro);
    await capturar(tester, '$pasta/tc-01-desktop-conectar.png');
  });

  testWidgets('captura tc: editor no computador', (tester) async {
    await preparar(tester, desktopWindows, tema: _claro);
    await abrirPresetEditado(tester, desktopWindows);
    await capturar(tester, '$pasta/tc-02-desktop-editor.png');
  });

  testWidgets('captura tc: editor no macOS', (tester) async {
    await preparar(tester, desktopMac, tema: _claro);
    await abrirPresetEditado(tester, desktopMac);
    await capturar(tester, '$pasta/tc-03-desktop-macos-editor.png');
  });

  testWidgets('captura tc: cadeia paralela e o Ignissor', (tester) async {
    await preparar(tester, _computadorAlto, tema: _claro);
    final container = await abrirSlot(tester, '03A');
    unawaited(container.read(editorProvider.notifier).adicionarBloco(
        const PosicaoBloco(1, 10), lerCatalogo().definicao('urn:darkglass:ignissor')));
    await tester.pumpAndSettle();
    await capturar(tester, '$pasta/tc-04-desktop-paralelo-ignissor.png');
  });

  testWidgets('captura tc: configurações com o Global EQ', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    await abrirDemonstracao(tester, tamanho: const Size(1440, 1500), tema: _claro);
    await tester.tap(find.byKey(const ValueKey('botao-configuracoes')));
    await tester.pumpAndSettle();
    await capturar(tester, '$pasta/tc-05-desktop-configuracoes.png');
  });

  testWidgets('captura tc: conectar no celular', (tester) async {
    await preparar(tester, _celular, tema: _claro);
    await capturar(tester, '$pasta/tc-06-celular-conectar.png');
  });

  testWidgets('captura tc: editor no celular', (tester) async {
    await preparar(tester, _celular, tema: _claro);
    await abrirPresetEditado(tester, _celular);
    await capturar(tester, '$pasta/tc-07-celular-editor.png');
  });

  testWidgets('captura tc: lista de presets no celular', (tester) async {
    await preparar(tester, _celular, tema: _claro);
    await abrirPresetEditado(tester, _celular);
    await tester.tap(find.byKey(const ValueKey('abrir-lista')));
    await tester.pumpAndSettle();
    await capturar(tester, '$pasta/tc-08-celular-lista.png');
  });

  testWidgets('captura tc: menu do preset e diálogo de confirmar', (tester) async {
    await preparar(tester, desktopWindows, tema: _claro);
    await abrirPresetEditado(tester, desktopWindows);
    await tester.tap(find.byKey(const ValueKey('botao-salvar-como')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('slot-02B')));
    await tester.pumpAndSettle();
    await capturar(tester, '$pasta/tc-09-desktop-confirmar-salvar.png');
  });
}
