import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'knob_test.dart' show abrirSujoDeEnsaio;

void main() {
  testWidgets('should_press_the_focused_button_instead_of_toggling_bypass_when_space_is_pressed', (tester) async {
    final container = await abrirSujoDeEnsaio(tester);
    final pedaleira = container.read(conexaoProvider.notifier).transporte! as TransporteDemonstracao;
    container.read(editorProvider.notifier).alterarParametro('Threshold', -12, arrastando: false);
    await tester.pumpAndSettle();
    bool ligado() => container.read(editorProvider).atual!.bloco(const PosicaoBloco(1, 1))!.habilitadoNaCena(1);
    final antes = ligado();

    Focus.of(tester.element(find.text('SALVAR'))).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();

    expect(ligado(), antes, reason: 'Espaço era para o botão focado');
    final salvo = pedaleira.conteudoDoSlot(4)!['preset']['chains']['1']['blocks']['1']['parameters'] as Map;
    expect(salvo.values.firstWhere((p) => p['symbol'] == 'Threshold')['value'], -12);
  });
}
