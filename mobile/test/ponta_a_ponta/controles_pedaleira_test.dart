// Controles da pedaleira pela interface, na demonstração: atribuir um pot
// pelo menu do knob, ver no painel de controles, salvar e conferir o JSON
// que a pedaleira simulada gravou no slot.
import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';

void main() {
  testWidgets('should_save_pot2_bound_to_the_threshold_when_assigned_from_the_knob_menu', (tester) async {
    final container = await abrirDemonstracao(tester);
    final pedaleira = container.read(conexaoProvider.notifier).transporte! as TransporteDemonstracao;
    await tocarNoSlot(tester, '01C');

    final knob = find.byKey(const ValueKey('param-Threshold'));
    await tester.ensureVisible(knob);
    await tester.tap(knob, buttons: kSecondaryMouseButton, kind: PointerDeviceKind.mouse);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('atribuir-pot2')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('marca-controle-Threshold')), findsOneWidget,
        reason: 'o knob mostra que agora está num pot');
    final cartao = find.byKey(const ValueKey('controle-pot2'));
    await tester.ensureVisible(cartao);
    expect(find.descendant(of: cartao, matching: find.textContaining('Threshold')), findsWidgets);
    expect(container.read(editorProvider).naoSalvo, isTrue, reason: 'atribuir é edição: só grava com Salvar');
    expect(pedaleira.conteudoDoSlot(3)!['preset']['bindings'], isEmpty);

    await voltarAoTopoDoEditor(tester);
    await tester.tap(find.byKey(const ValueKey('botao-salvar')));
    await tester.pumpAndSettle();

    final gravado = pedaleira.conteudoDoSlot(3)!['preset']['bindings'] as Map<String, dynamic>;
    expect(gravado['pot2'], {
      'name': 'Threshold',
      'parameters': [
        {'block': 1, 'max': 0, 'min': -60, 'row': 1, 'symbol': 'Threshold'}
      ],
      'properties': <dynamic>[],
      'value': -30,
    });
    expect(container.read(editorProvider).naoSalvo, isFalse);
  });
}
