// A seção "Pedaleira" das Configurações, ponta a ponta na demonstração:
// mexer no controle manda `edit_settings` com a chave plana que a Anagram
// real aceitou, o app relê e mostra o valor confirmado; a placa de som só
// se lê; e um ajuste sem chave conhecida nunca sai para a pedaleira.
import 'package:anagram_app/aplicacao/estado/controlador_ajustes.dart';
import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/apresentacao/componentes/botao_giratorio.dart';
import 'package:anagram_app/nucleo/ajustes/mapa_ajustes.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/protocolo/api_anagram.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/conexao_demo.dart';
import '../apoio/demonstracao_na_tela.dart';

TransporteDemonstracao _pedaleira(ProviderContainer c) =>
    c.read(conexaoProvider.notifier).transporte! as TransporteDemonstracao;

List<Map<String, dynamic>> _gravacoes(TransporteDemonstracao t) => [
      for (final m in t.comandosRecebidos)
        if (m.acao == AcoesAnagram.gravarAjustes) m.carga['settings'] as Map<String, dynamic>,
    ];

Future<ProviderContainer> _abrirPedaleira(WidgetTester tester) async {
  final container = await abrirDemonstracao(tester);
  await tester.tap(find.byKey(const ValueKey('botao-configuracoes')));
  await tester.pumpAndSettle();
  return container;
}

/// Espera a pausa do envio, a gravação e a releitura.
Future<void> _esperarEnvio(WidgetTester tester) async {
  await tester.pump(ControladorAjustes.espera * 2);
  await tester.pumpAndSettle();
}

Future<void> _digitar(WidgetTester tester, String id, String texto) async {
  await tester.ensureVisible(find.byKey(ValueKey('valor-$id')));
  await tester.tap(find.byKey(ValueKey('valor-$id')));
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const ValueKey('digitar-valor')), texto);
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('should_send_the_headphone_level_with_the_pedal_key_and_show_the_confirmed_value', (tester) async {
    final container = await _abrirPedaleira(tester);
    final pedaleira = _pedaleira(container);

    await _digitar(tester, 'headphones', '-4');
    await _esperarEnvio(tester);

    expect(_gravacoes(pedaleira), [
      {'mixer.headphones.vol': -4},
    ]);
    expect(pedaleira.ajustesGlobais['mixer.headphones.vol'], -4);
    expect(container.read(controladorAjustesProvider).locais, isEmpty, reason: 'o que aparece é o relido');
    expect(find.descendant(of: find.byKey(const ValueKey('valor-headphones')), matching: find.text('-4,0 dB')),
        findsOneWidget);
  });

  testWidgets('should_change_the_low_shelf_when_its_point_is_dragged_down_on_the_curve', (tester) async {
    final container = await _abrirPedaleira(tester);
    final pedaleira = _pedaleira(container);
    final curva = find.byKey(const ValueKey('curva-global-eq'));
    await tester.ensureVisible(curva);
    await tester.pumpAndSettle();
    final caixa = tester.getRect(curva);
    // o ponto do low shelf da demonstração: 40,5 Hz, −3 dB
    final x = caixa.left + caixa.width * 0.1019;
    final y = caixa.top + caixa.height / 2 * (1 + 3 / 15);

    await tester.dragFrom(Offset(x, y), const Offset(0, 30));
    await _esperarEnvio(tester);

    final ganho = pedaleira.ajustesGlobais['globaleq.ls.gain'] as num;
    expect(ganho, lessThan(-3), reason: 'arrastar para baixo corta mais grave');
    expect(_gravacoes(pedaleira).last.keys, containsAll(['globaleq.ls.freq', 'globaleq.ls.gain']));
  });

  testWidgets('should_show_the_sound_card_as_text_without_any_control_to_change_it', (tester) async {
    await _abrirPedaleira(tester);
    final placa = find.byKey(const ValueKey('cartao-placa'));
    await tester.ensureVisible(placa);

    expect(find.descendant(of: placa, matching: find.text('Headphone Gain: 2')), findsOneWidget);
    expect(find.descendant(of: placa, matching: find.byType(BotaoGiratorio)), findsNothing);
  });

  testWidgets('should_explain_near_the_controls_when_the_pedal_does_not_accept_the_change', (tester) async {
    final container = await _abrirPedaleira(tester);
    _pedaleira(container).naoResponder = AcoesAnagram.gravarAjustes;

    await _digitar(tester, 'out1', '-2');
    await tester.pump(ControladorAjustes.espera);
    await tester.pump(ApiAnagram.prazoAjustes + const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('erro-ajuste')), findsOneWidget);
  });

  test('should_never_send_a_setting_whose_pedal_key_is_still_unknown', () async {
    final (container, pedaleira) = await conectarDemonstracao();
    addTearDown(container.dispose);
    final controlador = container.read(controladorAjustesProvider.notifier);

    controlador.alterar(ajustePorIdOuChave('master')!, -6);
    controlador.alterar(ajustePorIdOuChave('input_gain_3')!, 4);
    await controlador.enviarAgora();

    expect(_gravacoes(pedaleira), isEmpty);
    expect(container.read(controladorAjustesProvider).locais, isEmpty);
  });
}
