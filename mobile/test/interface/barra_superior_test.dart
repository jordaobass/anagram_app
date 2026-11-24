// A barra de cima em dois grupos (DECISOES BS1): à esquerda o chip da conexão
// (com o Desconectar no menu) e o "Ao vivo" com a latência; à direita o "IA"
// (só com o MCP escutando) e a engrenagem. O "i" saiu: o Sobre se abre pelas
// Configurações, que também mostram a versão do app.
import 'dart:async';

import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/aplicacao/estado/estado_conexao.dart';
import 'package:anagram_app/aplicacao/mcp/controlador_mcp.dart';
import 'package:anagram_app/apresentacao/componentes/barra_conexao.dart';
import 'package:anagram_app/apresentacao/tema/tokens.dart';
import 'package:anagram_app/apresentacao/telas/tela_configuracoes.dart';
import 'package:anagram_app/apresentacao/telas/tela_creditos.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';
import '../apoio/pedaleira_no_cabo.dart';

Future<void> _noWindows(Future<void> Function() corpo) async {
  debugDefaultTargetPlatformOverride = TargetPlatform.windows;
  try {
    await corpo();
  } finally {
    debugDefaultTargetPlatformOverride = null;
  }
}

Finder _naBarra(Finder alvo) => find.descendant(of: find.byType(BarraConexao), matching: alvo);

/// Demonstração com um ajuste enviado ao vivo: a latência medida aparece.
Future<void> _comAjusteAoVivo(WidgetTester tester, {Duration latencia = const Duration(milliseconds: 42)}) async {
  await montarApp(tester, latencia: latencia);
  final c = await entrarNaDemonstracao(tester);
  unawaited(c.read(editorProvider.notifier).abrirSlot(SlotPreset.doRotulo('02A')));
  await tester.pumpAndSettle();
  c.read(editorProvider.notifier).alterarParametro('Threshold', -52, arrastando: false);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('should_put_the_settings_gear_at_the_right_end_of_the_top_bar',
      (tester) => _noWindows(() async {
            await abrirDemonstracao(tester);

            final barra = tester.getRect(find.byType(BarraConexao));
            final engrenagem = tester.getRect(find.byKey(const ValueKey('botao-configuracoes')));
            expect(barra.right - engrenagem.right, lessThanOrEqualTo(Espacos.l), reason: 'encostada à direita');
            expect(engrenagem.left, greaterThan(tester.getRect(find.byKey(const ValueKey('interruptor-ao-vivo'))).right),
                reason: 'depois do Ao vivo, no grupo do app');
            expect(engrenagem.height, inInclusiveRange(32, 40), reason: 'alvo de mouse da barra');
          }));

  testWidgets('should_leave_the_info_button_out_of_the_bar_and_open_about_from_the_settings', (tester) async {
    await abrirDemonstracao(tester);
    expect(_naBarra(find.byIcon(Icons.info_outline)), findsNothing);
    expect(find.byTooltip('Créditos'), findsNothing);
    expect(_naBarra(find.textContaining('App v')), findsNothing, reason: 'a versão foi para as Configurações');

    await tester.tap(find.byKey(const ValueKey('botao-configuracoes')));
    await tester.pumpAndSettle();
    final rolagem = find.descendant(of: find.byType(TelaConfiguracoes), matching: find.byType(Scrollable)).first;
    await tester.scrollUntilVisible(find.byKey(const ValueKey('abrir-sobre')), 300, scrollable: rolagem);
    await tester.pumpAndSettle();
    expect(find.text('App v0.1.3'), findsOneWidget, reason: 'a versão fica sob o Sobre');
    await tester.tap(find.byKey(const ValueKey('abrir-sobre')));
    await tester.pumpAndSettle();

    expect(find.byType(TelaCreditos), findsOneWidget);
  });

  testWidgets('should_show_the_pedal_in_one_chip_and_disconnect_from_its_menu', (tester) async {
    await montarApp(tester, overrides: [pedaleiraNoCabo]);
    await conectarPeloCabo(tester);
    expect(_naBarra(find.text('Anagram · fw 1.18.1.23')), findsOneWidget);
    expect(_naBarra(find.byIcon(Icons.link_off)), findsNothing, reason: 'o Desconectar mora no menu do chip');

    await tester.tap(find.byKey(const ValueKey('chip-conexao')));
    await tester.pumpAndSettle();
    expect(find.text('Anagram · USB · v1.18.1.23'), findsOneWidget, reason: 'a frase inteira no topo do menu');
    await tester.tap(find.byKey(const ValueKey('menu-desconectar')));
    await tester.pumpAndSettle();

    expect(containerDaTela(tester).read(conexaoProvider), isA<SemConexao>());
    expect(find.byKey(const ValueKey('botao-conectar')), findsOneWidget);
    expect(find.byKey(const ValueKey('chip-conexao')), findsNothing, reason: 'sem conexão o chip só informa');
  });

  testWidgets('should_name_the_demo_shortly_in_the_chip', (tester) async {
    await abrirDemonstracao(tester);

    expect(_naBarra(find.text('Demonstração')), findsOneWidget);
    expect(find.byKey(const ValueKey('chip-conexao')), findsOneWidget);
  });

  for (final (ms, papel) in [(42, 'neutra'), (501, 'âmbar'), (1501, 'vermelha')]) {
    testWidgets('should_paint_the_latency_${papel}_at_${ms}_ms', (tester) async {
      await _comAjusteAoVivo(tester, latencia: Duration(milliseconds: ms));

      final latencia = find.byKey(const ValueKey('latencia-ao-vivo'));
      expect(tester.widget<Text>(latencia).data, '$ms ms');
      final cores = Paleta.escura;
      final esperada = switch (papel) {
        'neutra' => cores.textoSecundario,
        'âmbar' => cores.tallyTinta,
        _ => cores.erro,
      };
      expect(tester.widget<Text>(latencia).style?.color, esperada);
      expect(find.byTooltip(RegExp('$ms ms.*500 ms')), findsOneWidget, reason: 'a dica explica os limites');
    });
  }

  testWidgets('should_show_the_ai_indicator_only_while_mcp_listens', (tester) async {
    await abrirDemonstracao(tester);
    expect(find.byKey(const ValueKey('selo-mcp')), findsNothing);

    final mcp = containerDaTela(tester).read(controladorMcpProvider.notifier);
    await mcp.ativar(true);
    await tester.pumpAndSettle();
    final porta = (containerDaTela(tester).read(controladorMcpProvider).situacao as McpEscutando).porta;
    expect(_naBarra(find.byKey(const ValueKey('selo-mcp'))), findsOneWidget);
    expect(find.byTooltip(RegExp('porta $porta')), findsOneWidget);
    final selo = tester.getRect(find.byKey(const ValueKey('selo-mcp')));
    expect(selo.right, lessThanOrEqualTo(tester.getRect(find.byKey(const ValueKey('botao-configuracoes'))).left),
        reason: 'logo antes da engrenagem');

    await mcp.ativar(false);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('selo-mcp')), findsNothing);
  });
}
