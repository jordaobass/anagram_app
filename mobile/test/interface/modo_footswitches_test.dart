// O modo dos footswitches (PRESET / STOMP / SCENE), ponta a ponta na
// demonstração: no editor, um selo na faixa do preset abre o menu dos modos;
// escolher manda `edit_settings` com `mode`, como a Anagram real aceitou na
// bancada de 2026-11-22, e o selo mostra o que a releitura confirmou, com um
// pulso — que some com "reduzir movimento". Recusa volta ao valor real; valor
// desconhecido vira "—" e o selo não abre. Nas Configurações, o cartão tem os
// três botões.
import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/controlador_modo_footswitches.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/protocolo/api_anagram.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';

const _selo = ValueKey('selo-modo-footswitches');
const _pulso = ValueKey('pulso-modo-footswitches');

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

Finder _seloMostra(String texto) => find.descendant(of: find.byKey(_selo), matching: find.text(texto));

/// Toca no selo, espera o menu abrir e toca no [modo].
Future<void> _escolher(WidgetTester tester, String modo, {bool esperar = true}) async {
  await tester.tap(find.byKey(_selo));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(ValueKey('menu-modo-$modo')));
  if (esperar) await tester.pumpAndSettle();
}

/// Avança em passos curtos até a releitura confirmar a troca (o pulso nasce aí).
Future<void> _ateConfirmar(WidgetTester tester, ProviderContainer container) async {
  await tester.pump();
  for (var i = 0; i < 50 && container.read(controladorModoProvider).pedido != null; i++) {
    await tester.pump(const Duration(milliseconds: 2));
  }
  await tester.pump();
}

void main() {
  testWidgets('should_send_mode_scene_when_scene_is_chosen_in_the_badge_menu_and_show_scene', (tester) async {
    final (_, pedaleira) = await _abrirPreset(tester);
    expect(_seloMostra('STOMP'), findsOneWidget, reason: 'a demonstração começa em Stomp, como a real');

    await tester.tap(find.byKey(_selo));
    await tester.pumpAndSettle();
    final marcado = find.byKey(const ValueKey('modo-marcado'));
    expect(find.descendant(of: find.byKey(const ValueKey('menu-modo-stomp')), matching: marcado), findsOneWidget,
        reason: 'o menu marca o modo atual');
    await tester.tap(find.byKey(const ValueKey('menu-modo-scene')));
    await tester.pumpAndSettle();

    expect(_gravacoesDoModo(pedaleira), [
      {
        'settings': {'mode': 'scene'},
        'reloadLvgl': true,
      },
    ]);
    expect(pedaleira.ajustesGlobais['mode'], 'scene');
    expect(_seloMostra('SCENE'), findsOneWidget);
  });

  testWidgets('should_keep_the_badge_in_the_preset_strip_on_the_phone', (tester) async {
    final (_, pedaleira) = await _abrirPreset(tester, tamanho: telaCelular);

    await _escolher(tester, 'preset');

    expect(pedaleira.ajustesGlobais['mode'], 'preset');
    expect(_seloMostra('PRESET'), findsOneWidget);
    expect(tester.getSize(find.byKey(_selo)).height, greaterThanOrEqualTo(48), reason: 'alvo de toque de 48 dp');
  });

  testWidgets('should_pulse_the_badge_once_the_pedal_confirms', (tester) async {
    final (container, _) = await _abrirPreset(tester);

    await _escolher(tester, 'scene', esperar: false);
    await _ateConfirmar(tester, container);

    expect(find.byKey(_pulso), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byKey(_pulso), findsNothing, reason: 'um pulso só');
  });

  testWidgets('should_not_animate_the_badge_when_the_system_asks_to_reduce_motion', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final (container, pedaleira) = await _abrirPreset(tester);

    await _escolher(tester, 'scene', esperar: false);
    await _ateConfirmar(tester, container);

    expect(pedaleira.ajustesGlobais['mode'], 'scene');
    expect(find.byKey(_pulso), findsNothing);
    expect(_seloMostra('SCENE'), findsOneWidget, reason: 'o texto troca sem deslizar');
    await tester.pumpAndSettle();
    expect(find.byKey(_pulso), findsNothing);
  });

  testWidgets('should_warn_and_go_back_to_the_real_mode_when_the_pedal_does_not_answer', (tester) async {
    final (_, pedaleira) = await _abrirPreset(tester);
    pedaleira.naoResponder = AcoesAnagram.gravarAjustes;

    await _escolher(tester, 'preset', esperar: false);
    await tester.pump();
    await tester.pump(ApiAnagram.prazoAjustes + const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('erro-modo-footswitches')), findsOneWidget);
    expect(_seloMostra('STOMP'), findsOneWidget, reason: 'mostra o que a pedaleira tem, não o pedido');
    expect(find.byKey(_pulso), findsNothing, reason: 'o pulso é só para o que a pedaleira confirmou');
  });

  testWidgets('should_show_a_disabled_dash_when_the_pedal_reports_an_unknown_value', (tester) async {
    final (_, pedaleira) = await _abrirPreset(tester, antes: (p) => p.ajustesGlobais['mode'] = 'looper');

    expect(_seloMostra('—'), findsOneWidget);
    await tester.tap(find.byKey(_selo), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('menu-modo-scene')), findsNothing, reason: 'desconhecido não abre o menu');
    expect(_gravacoesDoModo(pedaleira), isEmpty);
  });

  testWidgets('should_not_send_a_mode_when_the_firmware_does_not_export_one', (tester) async {
    final (_, pedaleira) = await _abrirPreset(tester, antes: (p) => p.ajustesGlobais.remove('mode'));

    await tester.tap(find.byKey(_selo), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(_seloMostra('—'), findsOneWidget);
    expect(find.byKey(const ValueKey('menu-modo-scene')), findsNothing);
    expect(_gravacoesDoModo(pedaleira), isEmpty, reason: 'chave que a pedaleira não exporta não se inventa');
  });

  testWidgets('should_warn_in_the_controls_panel_that_assigned_foots_only_act_in_stomp', (tester) async {
    await _abrirPreset(tester);
    final aviso = find.byKey(const ValueKey('aviso-modo-controles'));
    await rolarEditorAte(tester, find.byKey(const ValueKey('painel-controles')));
    expect(aviso, findsNothing, reason: 'em Stomp os FOOT atribuídos já agem');

    await voltarAoTopoDoEditor(tester);
    await _escolher(tester, 'scene');
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
    final indicador = find.byKey(const ValueKey('indicador-modo-footswitches'));
    expect(find.descendant(of: indicador, matching: find.text('PRESET')), findsOneWidget);
  });
}
