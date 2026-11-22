// A tela de Configurações e o que o MCP mostra no editor: ligar dá o
// endereço e a configuração pronta para colar; porta ocupada vira frase
// clara; no celular a opção some; o pedido de gravação da IA só grava com o
// "Salvar" da pessoa; e a mudança feita pela IA aparece na tela.
import 'dart:async';

import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/aplicacao/mcp/avisos_mcp.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/app_de_teste.dart';
import '../apoio/demonstracao_na_tela.dart';

/// Abre as Configurações já rolada até a seção da IA local.
Future<void> abrirConfiguracoes(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('botao-configuracoes')));
  await tester.pumpAndSettle();
  final secao = find.byKey(const ValueKey('mcp-permitir'));
  if (secao.evaluate().isNotEmpty) await tester.ensureVisible(secao);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('should_show_the_address_and_copy_a_ready_lm_studio_config_when_mcp_is_allowed', (tester) async {
    final servidor = ServidorMcpFalso();
    await montarApp(tester, servidorMcp: servidor);
    String? copiado;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (chamada) async {
      if (chamada.method == 'Clipboard.setData') copiado = (chamada.arguments as Map)['text'] as String;
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    await abrirConfiguracoes(tester);

    await tester.tap(find.byKey(const ValueKey('mcp-permitir')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('mcp-copiar-lmStudio')));
    await tester.tap(find.byKey(const ValueKey('mcp-copiar-lmStudio')));
    await tester.pumpAndSettle();

    expect(find.text('Escutando em http://127.0.0.1:8765/mcp'), findsOneWidget);
    expect(copiado, contains('"url": "http://127.0.0.1:8765/mcp"'));
    expect(copiado, contains('Bearer ${servidor.tokenEmUso}'), reason: 'o token colado é o que o servidor exige');
    expect(servidor.tokenEmUso, hasLength(greaterThan(30)));
  });

  testWidgets('should_restart_the_server_with_a_new_token_only_when_the_new_token_is_confirmed', (tester) async {
    final servidor = ServidorMcpFalso();
    await montarApp(tester, servidorMcp: servidor);
    await abrirConfiguracoes(tester);
    await tester.tap(find.byKey(const ValueKey('mcp-permitir')));
    await tester.pumpAndSettle();
    final primeiro = servidor.tokenEmUso;
    final gerarNovo = find.byKey(const ValueKey('mcp-novo-token'));
    await tester.ensureVisible(gerarNovo);

    await tester.tap(gerarNovo);
    await tester.pumpAndSettle();
    await tester.tap(find.text('CANCELAR'));
    await tester.pumpAndSettle();
    expect(servidor.tokenEmUso, primeiro, reason: 'cancelar não troca o token que os clientes já usam');

    await tester.tap(gerarNovo);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirmar-novo-token')));
    await tester.pumpAndSettle();
    expect(servidor.tokenEmUso, isNot(primeiro));
    expect(servidor.tokenEmUso, hasLength(greaterThan(30)));
  });

  testWidgets('should_explain_the_port_is_taken_when_the_server_cannot_listen', (tester) async {
    await montarApp(tester, servidorMcp: ServidorMcpFalso(ocupada: true));
    await abrirConfiguracoes(tester);

    await tester.tap(find.byKey(const ValueKey('mcp-permitir')));
    await tester.pumpAndSettle();

    expect(find.textContaining('A porta 8765 já está em uso'), findsOneWidget);
  });

  testWidgets('should_refuse_a_system_port_and_keep_the_current_one_when_typed_in_settings', (tester) async {
    await montarApp(tester);
    await abrirConfiguracoes(tester);

    await tester.enterText(find.byKey(const ValueKey('mcp-porta')), '80');
    await tester.tap(find.byKey(const ValueKey('mcp-aplicar-porta')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('mcp-permitir')));
    await tester.pumpAndSettle();

    expect(find.text('Use um número de 1024 a 65535.'), findsOneWidget);
    expect(find.text('Escutando em http://127.0.0.1:8765/mcp'), findsOneWidget);
  });

  testWidgets('should_hide_the_mcp_option_where_the_platform_cannot_run_it', (tester) async {
    await montarApp(tester, mcpDisponivel: false);
    await abrirConfiguracoes(tester);

    expect(find.byKey(const ValueKey('mcp-permitir')), findsNothing);
    expect(find.byKey(const ValueKey('idioma-en')), findsOneWidget, reason: 'o idioma continua lá');
  });

  testWidgets('should_write_only_after_the_player_taps_save_when_the_ai_asks_to_save', (tester) async {
    final c = await abrirDemonstracao(tester);
    unawaited(c.read(editorProvider.notifier).abrirSlot(SlotPreset.doRotulo('02A')));
    await tester.pumpAndSettle();
    bool? resposta;
    unawaited(c.read(pedidoSalvarProvider.notifier).pedir('Sujo de Ensaio', '02A', const Duration(minutes: 1)).then((r) => resposta = r));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('dialogo-pedido-salvar')), findsOneWidget);
    expect(resposta, isNull, reason: 'nada antes da pessoa responder');
    await tester.tap(find.byKey(const ValueKey('mcp-confirmar-salvar')));
    await tester.pumpAndSettle();

    expect(resposta, isTrue);
    expect(find.byKey(const ValueKey('dialogo-pedido-salvar')), findsNothing);
  });

  testWidgets('should_tell_the_player_when_the_ai_changed_the_sound', (tester) async {
    final c = await abrirDemonstracao(tester);

    c.read(avisosMcpProvider.notifier).mudancaDaIa('Compressor: Threshold = -12.0 dB');
    await tester.pump();

    expect(find.text('IA: Compressor: Threshold = -12.0 dB'), findsOneWidget);
  });
}
