// A seção "Pedaleira" das Configurações, ponta a ponta na demonstração. Na
// bancada de 2026-11-22 a Anagram aceitou e releu mixer, Global EQ e ganho de
// entrada, mas o som não mudou (DECISOES AJ1): a seção mostra o que a
// pedaleira tem, avisa que o app não tem acesso a esses recursos e nenhum
// gesto nos controles manda `edit_settings`. O modo dos footswitches continua
// editável (modo_footswitches_test); a placa de som só se lê.
import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/apresentacao/componentes/botao_giratorio.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/protocolo/api_anagram.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

Finder _valor(String id) => find.byKey(ValueKey('valor-$id'));

/// Arrasta, segura e toca no número do controle [id], como quem tenta mudar.
Future<void> _tentarMudar(WidgetTester tester, String id) async {
  final controle = find.byKey(ValueKey('ajuste-$id'));
  await tester.ensureVisible(controle);
  await tester.pumpAndSettle();
  await tester.drag(controle, const Offset(0, -80));
  await tester.longPress(controle);
  await tester.tap(_valor(id), warnIfMissed: false);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('should_explain_at_the_top_of_the_pedal_section_that_the_app_has_no_access_to_these_features',
      (tester) async {
    await _abrirPedaleira(tester);
    final aviso = find.byKey(const ValueKey('aviso-sem-acesso-ajustes'));

    expect(aviso, findsOneWidget);
    expect(find.descendant(of: aviso, matching: find.textContaining('não tem acesso')), findsOneWidget);
    expect(find.textContaining('Mudam na hora'), findsNothing, reason: 'a pedaleira não aplica ao som');
    expect(tester.getTopLeft(aviso).dy, lessThan(tester.getTopLeft(find.byKey(const ValueKey('ajuste-headphones'))).dy),
        reason: 'o aviso vem antes dos controles');
  });

  testWidgets('should_show_the_values_read_from_the_pedal_without_the_speaker_fader', (tester) async {
    await _abrirPedaleira(tester);

    expect(find.descendant(of: _valor('headphones'), matching: find.text('6,0 dB')), findsOneWidget);
    expect(find.byKey(const ValueKey('ajuste-speaker')), findsNothing, reason: 'o mixer do manual não tem Speaker');
  });

  testWidgets('should_not_send_edit_settings_when_outputs_eq_or_input_controls_are_touched', (tester) async {
    final container = await _abrirPedaleira(tester);
    final pedaleira = _pedaleira(container);

    await _tentarMudar(tester, 'headphones');
    await _tentarMudar(tester, 'input_gain_1');
    await _tentarMudar(tester, 'eq_ls_gain');
    final curva = find.byKey(const ValueKey('curva-global-eq'));
    await tester.ensureVisible(curva);
    await tester.pumpAndSettle();
    final caixa = tester.getRect(curva);
    // o ponto do low shelf da demonstração: 35 Hz, −7,8 dB
    await tester.dragFrom(Offset(caixa.left + caixa.width * 0.0810, caixa.top + caixa.height / 2 * (1 + 7.8 / 15)),
        const Offset(0, 30));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(_gravacoes(pedaleira), isEmpty);
    expect(find.byKey(const ValueKey('digitar-valor')), findsNothing, reason: 'o número não abre o campo');
    expect(find.byKey(const ValueKey('eq-reset')), findsNothing);
    expect(find.descendant(of: _valor('headphones'), matching: find.text('6,0 dB')), findsOneWidget);
  });

  testWidgets('should_show_the_sound_card_as_text_without_any_control_to_change_it', (tester) async {
    await _abrirPedaleira(tester);
    final placa = find.byKey(const ValueKey('cartao-placa'));
    await tester.ensureVisible(placa);

    expect(find.descendant(of: placa, matching: find.text('Headphone Gain: 2')), findsOneWidget);
    expect(find.descendant(of: placa, matching: find.byType(BotaoGiratorio)), findsNothing);
  });

  testWidgets('should_show_the_new_value_after_refresh_when_it_was_changed_on_the_pedal', (tester) async {
    final container = await _abrirPedaleira(tester);
    _pedaleira(container).ajustesGlobais['mixer.headphones.vol'] = -4.0;

    await tester.tap(find.byKey(const ValueKey('atualizar-ajustes')));
    await tester.pumpAndSettle();

    expect(find.descendant(of: _valor('headphones'), matching: find.text('-4,0 dB')), findsOneWidget);
  });
}
