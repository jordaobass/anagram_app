// O modo dos footswitches (PRESET / STOMP / SCENE), ponta a ponta na
// demonstração: no editor, três pílulas à direita das cenas (abaixo delas
// quando não cabem). Tocar numa manda `edit_settings` com `mode`, como a
// Anagram real aceitou na bancada de 2026-11-22; a pílula do modo confirmado
// fica acesa na cor do LED da pedaleira e pulsa — sem movimento quando o
// sistema pede. Recusa volta ao valor real; valor desconhecido não acende
// nenhuma. Nas Configurações, o cartão tem os três botões.
import 'dart:ui' show Tristate;

import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/controlador_modo_footswitches.dart';
import 'package:anagram_app/apresentacao/tema/tokens.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/protocolo/api_anagram.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';

const _pulso = ValueKey('pulso-modo-footswitches');
const _modos = ['preset', 'stomp', 'scene'];

TransporteDemonstracao _pedaleira(ProviderContainer c) =>
    c.read(conexaoProvider.notifier).transporte! as TransporteDemonstracao;

List<Map<String, dynamic>> _gravacoesDoModo(TransporteDemonstracao t) => [
      for (final m in t.comandosRecebidos)
        if (m.acao == AcoesAnagram.gravarAjustes && (m.carga['settings'] as Map).containsKey('mode')) m.carga,
    ];

Future<(ProviderContainer, TransporteDemonstracao)> _abrirPreset(WidgetTester tester,
    {void Function(TransporteDemonstracao)? antes, Size tamanho = telaDesktop}) async {
  final celular = tamanho == telaCelular;
  final container = await abrirDemonstracao(tester, tamanho: tamanho, densidade: celular ? 2 : 1);
  final pedaleira = _pedaleira(container);
  antes?.call(pedaleira);
  if (celular) {
    await tester.tap(find.text('VER PRESETS'));
    await tester.pumpAndSettle();
  }
  await tocarNoSlot(tester, '01C');
  return (container, pedaleira);
}

Finder _pilula(String modo) => find.byKey(ValueKey('pilula-modo-$modo'));

bool _acesa(WidgetTester tester, String modo) =>
    tester.getSemantics(_pilula(modo)).flagsCollection.isSelected == Tristate.isTrue;

List<String> _acesas(WidgetTester tester) => [for (final m in _modos) if (_acesa(tester, m)) m];

/// Avança em passos curtos até a releitura confirmar a troca (o pulso nasce aí).
Future<void> _ateConfirmar(WidgetTester tester, ProviderContainer container) async {
  await tester.pump();
  for (var i = 0; i < 50 && container.read(controladorModoProvider).pedido != null; i++) {
    await tester.pump(const Duration(milliseconds: 2));
  }
  await tester.pump();
}

void main() {
  testWidgets('should_send_mode_scene_when_the_scene_pill_is_tapped_and_light_it', (tester) async {
    final (_, pedaleira) = await _abrirPreset(tester);
    expect(_acesas(tester), ['stomp'], reason: 'a demonstração começa em Stomp, como a real');

    await tester.tap(_pilula('scene'));
    await tester.pumpAndSettle();

    expect(_gravacoesDoModo(pedaleira), [
      {
        'settings': {'mode': 'scene'},
        'reloadLvgl': true,
      },
    ]);
    expect(pedaleira.ajustesGlobais['mode'], 'scene');
    expect(_acesas(tester), ['scene']);
  });

  testWidgets('should_put_the_pills_right_of_the_scenes_on_the_desktop', (tester) async {
    await _abrirPreset(tester);
    final cena3 = tester.getRect(find.byKey(const ValueKey('cena-3')));

    for (final modo in _modos) {
      final pilula = tester.getRect(_pilula(modo));
      expect(pilula.left, greaterThan(cena3.right), reason: '$modo fica à direita das cenas');
      expect(pilula.center.dy, closeTo(cena3.center.dy, 1), reason: '$modo na linha das cenas');
      expect(pilula.height, greaterThanOrEqualTo(48), reason: 'alvo de toque de 48 dp');
    }
  });

  testWidgets('should_fit_the_pills_on_the_phone_and_change_the_mode', (tester) async {
    final (_, pedaleira) = await _abrirPreset(tester, tamanho: telaCelular);

    for (final modo in _modos) {
      expect(tester.getRect(_pilula(modo)).right, lessThanOrEqualTo(telaCelular.width));
      expect(tester.getSize(_pilula(modo)).height, greaterThanOrEqualTo(48));
    }
    await tester.tap(_pilula('preset'));
    await tester.pumpAndSettle();

    expect(pedaleira.ajustesGlobais['mode'], 'preset');
    expect(_acesas(tester), ['preset']);
  });

  testWidgets('should_pulse_the_new_pill_once_the_pedal_confirms', (tester) async {
    final (container, _) = await _abrirPreset(tester);

    await tester.tap(_pilula('scene'));
    await _ateConfirmar(tester, container);

    expect(find.descendant(of: _pilula('scene'), matching: find.byKey(_pulso)), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byKey(_pulso), findsNothing, reason: 'um pulso só');
  });

  testWidgets('should_not_animate_when_the_system_asks_to_reduce_motion', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final (container, pedaleira) = await _abrirPreset(tester);

    await tester.tap(_pilula('scene'));
    await _ateConfirmar(tester, container);

    expect(pedaleira.ajustesGlobais['mode'], 'scene');
    expect(find.byKey(_pulso), findsNothing);
    final desenho = find.descendant(of: _pilula('scene'), matching: find.byType(DecoratedBox)).first;
    final cor = (tester.widget<DecoratedBox>(desenho).decoration as BoxDecoration).color;
    expect(cor, Paleta.escura.modoScene, reason: 'acesa por inteiro já no primeiro quadro, sem transição');
    expect(_acesas(tester), ['scene']);
  });

  testWidgets('should_warn_and_go_back_to_the_real_mode_when_the_pedal_does_not_answer', (tester) async {
    final (_, pedaleira) = await _abrirPreset(tester);
    pedaleira.naoResponder = AcoesAnagram.gravarAjustes;

    await tester.tap(_pilula('preset'));
    await tester.pump();
    await tester.pump(ApiAnagram.prazoAjustes + const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('erro-modo-footswitches')), findsOneWidget);
    expect(_acesas(tester), ['stomp'], reason: 'mostra o que a pedaleira tem, não o pedido');
    expect(find.byKey(_pulso), findsNothing, reason: 'o pulso é só para o que a pedaleira confirmou');
  });

  testWidgets('should_light_no_pill_and_send_nothing_when_the_pedal_reports_an_unknown_value', (tester) async {
    final (_, pedaleira) = await _abrirPreset(tester, antes: (p) => p.ajustesGlobais['mode'] = 'looper');

    expect(_acesas(tester), isEmpty);
    await tester.tap(_pilula('scene'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(_gravacoesDoModo(pedaleira), isEmpty);
  });

  testWidgets('should_not_send_a_mode_when_the_firmware_does_not_export_one', (tester) async {
    final (_, pedaleira) = await _abrirPreset(tester, antes: (p) => p.ajustesGlobais.remove('mode'));

    await tester.tap(_pilula('scene'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(_acesas(tester), isEmpty);
    expect(_gravacoesDoModo(pedaleira), isEmpty, reason: 'chave que a pedaleira não exporta não se inventa');
  });

  testWidgets('should_warn_in_the_controls_panel_that_assigned_foots_only_act_in_stomp', (tester) async {
    await _abrirPreset(tester);
    final aviso = find.byKey(const ValueKey('aviso-modo-controles'));
    await abrirControlesDaPedaleira(tester);
    expect(aviso, findsNothing, reason: 'em Stomp os FOOT atribuídos já agem');

    await voltarAoTopoDoEditor(tester);
    await tester.tap(_pilula('scene'));
    await tester.pumpAndSettle();
    await abrirControlesDaPedaleira(tester);

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
    final indicador = find.byKey(const ValueKey('indicador-modo-footswitches'));
    expect(find.descendant(of: indicador, matching: find.text('PRESET')), findsOneWidget);
  });
}
