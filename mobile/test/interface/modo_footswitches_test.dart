// O modo dos footswitches (PRESET / STOMP / SCENE) no editor, ponta a ponta na
// demonstração: tocar no modo manda `edit_settings` com `mode`, como a Anagram
// real aceitou na bancada de 2026-11-22, e o indicador mostra o que a
// releitura confirmou. Recusa volta ao valor real; valor desconhecido vira "—".
import 'dart:ui' show Tristate;

import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/protocolo/api_anagram.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';

const _indicador = ValueKey('indicador-modo-footswitches');

TransporteDemonstracao _pedaleira(ProviderContainer c) =>
    c.read(conexaoProvider.notifier).transporte! as TransporteDemonstracao;

List<Map<String, dynamic>> _gravacoesDoModo(TransporteDemonstracao t) => [
      for (final m in t.comandosRecebidos)
        if (m.acao == AcoesAnagram.gravarAjustes && (m.carga['settings'] as Map).containsKey('mode')) m.carga,
    ];

Future<(ProviderContainer, TransporteDemonstracao)> _abrirPreset(WidgetTester tester,
    {void Function(TransporteDemonstracao)? antes}) async {
  final container = await abrirDemonstracao(tester);
  final pedaleira = _pedaleira(container);
  antes?.call(pedaleira);
  await tocarNoSlot(tester, '01C');
  return (container, pedaleira);
}

Finder _textoDoIndicador(String texto) => find.descendant(of: find.byKey(_indicador), matching: find.text(texto));

bool _ativo(WidgetTester tester, String modo) =>
    tester.getSemantics(find.byKey(ValueKey('modo-footswitches-$modo'))).flagsCollection.isSelected ==
    Tristate.isTrue;

void main() {
  testWidgets('should_send_mode_scene_to_the_pedal_and_show_scene_when_scene_is_tapped', (tester) async {
    final (_, pedaleira) = await _abrirPreset(tester);
    expect(_textoDoIndicador('STOMP'), findsOneWidget, reason: 'a demonstração começa em Stomp, como a real');

    await tester.tap(find.byKey(const ValueKey('modo-footswitches-scene')));
    await tester.pumpAndSettle();

    expect(_gravacoesDoModo(pedaleira), [
      {
        'settings': {'mode': 'scene'},
        'reloadLvgl': true,
      },
    ]);
    expect(pedaleira.ajustesGlobais['mode'], 'scene');
    expect(_textoDoIndicador('SCENE'), findsOneWidget);
    expect(_ativo(tester, 'scene'), isTrue);
    expect(_ativo(tester, 'stomp'), isFalse);
  });

  testWidgets('should_warn_and_go_back_to_the_real_mode_when_the_pedal_does_not_answer', (tester) async {
    final (_, pedaleira) = await _abrirPreset(tester);
    pedaleira.naoResponder = AcoesAnagram.gravarAjustes;

    await tester.tap(find.byKey(const ValueKey('modo-footswitches-preset')));
    await tester.pump();
    await tester.pump(ApiAnagram.prazoAjustes + const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('erro-modo-footswitches')), findsOneWidget);
    expect(_textoDoIndicador('STOMP'), findsOneWidget, reason: 'mostra o que a pedaleira tem, não o pedido');
    expect(_ativo(tester, 'stomp'), isTrue);
    expect(_ativo(tester, 'preset'), isFalse);
  });

  testWidgets('should_show_a_dash_and_no_active_mode_when_the_pedal_reports_an_unknown_value', (tester) async {
    await _abrirPreset(tester, antes: (p) => p.ajustesGlobais['mode'] = 'looper');

    expect(_textoDoIndicador('—'), findsOneWidget);
    for (final modo in ['preset', 'stomp', 'scene']) {
      expect(_ativo(tester, modo), isFalse);
    }
  });

  testWidgets('should_not_send_a_mode_when_the_firmware_does_not_export_one', (tester) async {
    final (_, pedaleira) = await _abrirPreset(tester, antes: (p) => p.ajustesGlobais.remove('mode'));

    await tester.tap(find.byKey(const ValueKey('modo-footswitches-scene')), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(_textoDoIndicador('—'), findsOneWidget);
    expect(_gravacoesDoModo(pedaleira), isEmpty, reason: 'chave que a pedaleira não exporta não se inventa');
  });

  testWidgets('should_warn_in_the_controls_panel_that_assigned_foots_only_act_in_stomp', (tester) async {
    await _abrirPreset(tester);
    final aviso = find.byKey(const ValueKey('aviso-modo-controles'));
    await rolarEditorAte(tester, find.byKey(const ValueKey('painel-controles')));
    expect(aviso, findsNothing, reason: 'em Stomp os FOOT atribuídos já agem');

    await voltarAoTopoDoEditor(tester);
    await tester.tap(find.byKey(const ValueKey('modo-footswitches-scene')));
    await tester.pumpAndSettle();
    await rolarEditorAte(tester, find.byKey(const ValueKey('painel-controles')));

    expect(aviso, findsOneWidget);
  });

  testWidgets('should_change_the_mode_from_the_pedal_section_of_the_settings', (tester) async {
    final container = await abrirDemonstracao(tester);
    final pedaleira = _pedaleira(container);
    await tester.tap(find.byKey(const ValueKey('botao-configuracoes')));
    await tester.pumpAndSettle();

    final preset = find.byKey(const ValueKey('modo-footswitches-preset'));
    await tester.ensureVisible(preset);
    await tester.pumpAndSettle();
    await tester.tap(preset);
    await tester.pumpAndSettle();

    expect(pedaleira.ajustesGlobais['mode'], 'preset');
    expect(_textoDoIndicador('PRESET'), findsOneWidget);
  });
}
