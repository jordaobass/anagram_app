// Capturas dos controles da pedaleira (prefixo "ct-"): o painel com o pedal
// de expressão e os pots de um preset real, o diálogo de edição, o menu do
// knob e o painel no celular.

import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/capturas_apoio.dart';
import '../apoio/demonstracao_na_tela.dart';

const _celular = Tamanho('celular-retrato', 390, 844, 2);

/// 01A ("My faorite tone") tem o pedal no Position do wah e dois pots.
Future<void> _abrirComWah(WidgetTester tester, Tamanho tamanho) async {
  await preparar(tester, tamanho);
  final container = await abrirSlot(tester, '01A');
  container.read(editorProvider.notifier).selecionarBloco(const PosicaoBloco(1, 2));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(carregarFontes);

  testWidgets('captura ct: painel dos controles no computador', (tester) async {
    await _abrirComWah(tester, desktopWindows);
    await rolarEditorAte(tester, find.byKey(const ValueKey('controle-exp.pedal')));
    await capturar(tester, '$pasta/ct-01-desktop-controles.png');
  });

  testWidgets('captura ct: editar o pedal de expressão', (tester) async {
    await _abrirComWah(tester, desktopWindows);
    await rolarEditorAte(tester, find.byKey(const ValueKey('controle-exp.pedal')));
    await tester.tap(find.byKey(const ValueKey('controle-exp.pedal')));
    await tester.pumpAndSettle();
    await capturar(tester, '$pasta/ct-02-desktop-dialogo-expressao.png');
  });

  testWidgets('captura ct: menu de atribuir no knob', (tester) async {
    await _abrirComWah(tester, desktopWindows);
    final knob = find.byKey(const ValueKey('param-OutLvl'));
    await tester.ensureVisible(knob);
    await tester.pumpAndSettle();
    await tester.tap(knob, buttons: kSecondaryMouseButton, kind: PointerDeviceKind.mouse);
    await tester.pumpAndSettle();
    await capturar(tester, '$pasta/ct-03-desktop-menu-knob.png');
  });

  testWidgets('captura ct: painel dos controles no celular', (tester) async {
    await _abrirComWah(tester, _celular);
    await rolarEditorAte(tester, find.byKey(const ValueKey('controle-exp.pedal')));
    await capturar(tester, '$pasta/ct-90-celular-controles.png');
  });
}
