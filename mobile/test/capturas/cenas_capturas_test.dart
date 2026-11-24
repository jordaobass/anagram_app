// Capturas das cenas (prefixo "ce-"): preset com cinco cenas (firmware 1.16+,
// issue #39), com a fita de cenas rolando na horizontal e a cena 4 ativa.
import 'dart:async';

import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/app_com_mcp.dart' show pedaleiraDe;
import '../apoio/capturas_apoio.dart';
import '../apoio/cinco_cenas.dart';

const _celular = Tamanho('celular-retrato', 390, 844, 2);

Future<void> _abrirCincoCenasNaCena4(WidgetTester tester, Tamanho tamanho) async {
  await preparar(tester, tamanho);
  final container = await abrirSlot(tester, '01A');
  final pedaleira = pedaleiraDe(container);
  // o mesmo id do 01C da demonstração: senão a tela avisa que o slot mudou por fora
  final cinco = presetCincoCenas();
  (cinco['preset'] as Map<String, dynamic>)['uuid'] = (pedaleira.conteudoDoSlot(3)!['preset'] as Map)['uuid'];
  pedaleira.substituirSlot(3, cinco);
  final editor = container.read(editorProvider.notifier);
  unawaited(editor.abrirSlot(SlotPreset.doRotulo('01C')));
  await tester.pumpAndSettle();
  unawaited(editor.escolherCena(4));
  editor.selecionarBloco(const PosicaoBloco(1, 1));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(carregarFontes);

  testWidgets('captura ce: cinco cenas no computador', (tester) async {
    await _abrirCincoCenasNaCena4(tester, desktopWindows);
    await capturar(tester, '$pasta/ce-01-desktop-cinco-cenas.png');
  });

  testWidgets('captura ce: cinco cenas no celular', (tester) async {
    await _abrirCincoCenasNaCena4(tester, _celular);
    await capturar(tester, '$pasta/ce-90-celular-cinco-cenas.png');
  });
}
