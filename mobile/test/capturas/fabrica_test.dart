// Capturas da área Fábrica (U18): o preset de fábrica aberto (aviso e botão
// de copiar), a pergunta da área de destino, a lista da área pedindo o slot e
// o celular. Prefixo "fb-". Com COM_MINIATURAS=1 saem com a arte e a fábrica
// de verdade, na pasta ignorada pelo git.
import 'dart:async';

import 'package:anagram_app/aplicacao/estado/controlador_biblioteca.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/modelo/presets_fabrica.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/capturas_apoio.dart';
import '../apoio/demonstracao_na_tela.dart';
import '../apoio/fixtures.dart';

const _celular = Tamanho('celular-retrato', 390, 844, 2);

/// A demonstração na fábrica, com o 01A aberto (tocando como temporário).
Future<ProviderContainer> _presetDeFabrica(WidgetTester tester, Tamanho tamanho) async {
  await preparar(tester, tamanho, fabrica: lerFabrica());
  final container = await entrarNaDemonstracao(tester);
  unawaited(container.read(bibliotecaProvider.notifier).selecionarArea(PresetsDeFabrica.idArea));
  await tester.pumpAndSettle();
  unawaited(container.read(editorProvider.notifier).abrirSlot(SlotPreset(1)));
  await tester.pumpAndSettle();
  return container;
}

Future<void> _copiar(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('botao-salvar')));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(carregarFontes);

  testWidgets('captura fb: preset de fábrica aberto no computador', (tester) async {
    await _presetDeFabrica(tester, desktopWindows);
    await capturar(tester, '$pasta/fb-01-desktop-preset-fabrica.png');
  });

  testWidgets('captura fb: para qual área copiar', (tester) async {
    await _presetDeFabrica(tester, desktopWindows);
    await _copiar(tester);
    await capturar(tester, '$pasta/fb-02-desktop-copiar-qual-area.png');
  });

  testWidgets('captura fb: a área escolhida pedindo o slot', (tester) async {
    await _presetDeFabrica(tester, desktopWindows);
    await _copiar(tester);
    await tester.tap(find.byKey(const ValueKey('copiar-para-user-2')));
    await tester.pumpAndSettle();
    await capturar(tester, '$pasta/fb-03-desktop-escolher-slot.png');
  });

  testWidgets('captura fb: preset de fábrica no celular', (tester) async {
    await _presetDeFabrica(tester, _celular);
    await capturar(tester, '$pasta/fb-04-celular-preset-fabrica.png');
  });

  testWidgets('captura fb: lista da fábrica no celular', (tester) async {
    await _presetDeFabrica(tester, _celular);
    await tester.tap(find.byKey(const ValueKey('abrir-lista')));
    await tester.pumpAndSettle();
    await capturar(tester, '$pasta/fb-05-celular-lista-fabrica.png');
  });
}
