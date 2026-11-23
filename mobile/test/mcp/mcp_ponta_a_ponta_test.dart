// A IA local falando com o app de verdade: servidor HTTP real numa porta
// livre, pedaleira de demonstração, preset aberto. Cada chamada tem de soar
// pelo mesmo caminho da tela (ao vivo, "não salvo") e o undo tem de voltar.
// Gravar só acontece se a pessoa confirmar.
import 'dart:convert';
import 'dart:io';

import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/aplicacao/mcp/avisos_mcp.dart';
import 'package:anagram_app/aplicacao/mcp/controlador_mcp.dart';
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/aplicacao/versao_app.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:anagram_app/nucleo/protocolo/api_anagram.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../apoio/app_de_teste.dart' show PreferenciasMcpEmMemoria;
import '../apoio/fixtures.dart';

/// App conectado à demonstração com o 01C aberto e o MCP escutando numa porta livre.
/// [extras]: sobreposições a mais (a pasta de backups, por exemplo).
Future<(ProviderContainer, String, String)> appComMcp({List<Override> extras = const []}) async {
  final container = ProviderContainer(overrides: [
    ...extras,
    presetsDemonstracaoProvider.overrideWith((ref) async => lerPresetsDemonstracao()),
    catalogoProvider.overrideWith((ref) async => lerCatalogo()),
    indiceMiniaturasProvider.overrideWith((ref) async => lerIndiceMiniaturas()),
    explicacoesProvider.overrideWith((ref) async => lerExplicacoes()),
    conhecimentoProvider.overrideWith((ref) async => lerConhecimento()),
    versaoAppProvider.overrideWith((ref) async => '9.9.9'),
    preferenciasMcpProvider.overrideWithValue(PreferenciasMcpEmMemoria()),
    mcpDisponivelProvider.overrideWithValue(true),
    prazoConfirmarSalvarProvider.overrideWithValue(const Duration(seconds: 5)),
  ]);
  addTearDown(container.dispose);
  await container.read(catalogoProvider.future);
  await container.read(conexaoProvider.notifier).conectarDemonstracao();
  await container.read(editorProvider.notifier).abrirSlot(SlotPreset.doRotulo('01C'));
  final mcp = container.read(controladorMcpProvider.notifier);
  await mcp.definirPorta(0);
  await mcp.ativar(true);
  final estado = container.read(controladorMcpProvider);
  final escutando = estado.situacao as McpEscutando;
  return (container, escutando.endereco, estado.configuracao.token!);
}

int _id = 0;

/// Um POST JSON-RPC; devolve o status HTTP e o corpo decodificado (se houver).
Future<(int, Map<String, dynamic>?)> chamar(String endereco, String? token, String metodo,
    [Map<String, dynamic>? parametros, bool notificacao = false]) async {
  final cliente = HttpClient();
  try {
    final pedido = await cliente.postUrl(Uri.parse(endereco));
    pedido.headers.contentType = ContentType.json;
    pedido.headers.set(HttpHeaders.acceptHeader, 'application/json, text/event-stream');
    if (token != null) pedido.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    pedido.write(jsonEncode({'jsonrpc': '2.0', if (!notificacao) 'id': ++_id, 'method': metodo, 'params': ?parametros}));
    final resposta = await pedido.close();
    final texto = await utf8.decodeStream(resposta);
    return (resposta.statusCode, texto.isEmpty ? null : jsonDecode(texto) as Map<String, dynamic>);
  } finally {
    cliente.close();
  }
}

/// `tools/call` e o JSON que a ferramenta devolveu em texto.
Future<(bool, Object?)> ferramenta(String endereco, String token, String nome, [Map<String, dynamic>? args]) async {
  final (_, corpo) = await chamar(endereco, token, 'tools/call', {'name': nome, 'arguments': args ?? {}});
  final resultado = corpo!['result'] as Map<String, dynamic>;
  final texto = (resultado['content'] as List).first['text'] as String;
  final erro = resultado['isError'] as bool;
  return (erro, erro ? texto : jsonDecode(texto));
}

void main() {
  const limiar = PosicaoBloco(1, 1);

  test('should_change_the_sound_live_and_undo_it_when_a_local_ai_calls_the_mcp_tools', () async {
    final (container, endereco, token) = await appComMcp();
    final pedaleira = container.read(conexaoProvider.notifier).transporte! as TransporteDemonstracao;
    final antes = container.read(editorProvider).atual!.bloco(limiar)!.valorBase('Threshold');

    final (_, inicio) = await chamar(endereco, token, 'initialize', {'protocolVersion': '2025-06-18'});
    expect(inicio!['result']['protocolVersion'], '2025-06-18');
    expect(inicio['result']['serverInfo']['version'], '9.9.9', reason: 'o cliente vê qual app responde');
    final (status, semCorpo) = await chamar(endereco, token, 'notifications/initialized', null, true);
    expect((status, semCorpo), (HttpStatus.accepted, null), reason: 'notificação não leva resposta');
    final (_, lista) = await chamar(endereco, token, 'tools/list');
    expect([for (final t in lista!['result']['tools'] as List) t['name']],
        containsAll(['set_parameter', 'save_preset', 'get_block_guide', 'get_tone_building_guide', 'get_tone_recipe']));

    final enviosAntes = pedaleira.comandosRecebidos.where((c) => c.acao == AcoesAnagram.tocarAoVivo).length;
    final (erro, mudou) = await ferramenta(endereco, token, 'set_parameter',
        {'row': 1, 'column': 1, 'parameter': 'Threshold', 'value': -12});
    expect(erro, isFalse, reason: '$mudou');

    final (_, lido) = await ferramenta(endereco, token, 'get_current_preset');
    final bloco = ((lido! as Map)['rows']['1'] as List).first as Map;
    expect((bloco['parameters'] as List).firstWhere((p) => p['symbol'] == 'Threshold')['value'], -12);
    expect(container.read(editorProvider).atual!.bloco(limiar)!.valorBase('Threshold'), -12);
    expect(container.read(editorProvider).naoSalvo, isTrue);
    expect(pedaleira.comandosRecebidos.where((c) => c.acao == AcoesAnagram.tocarAoVivo).length, greaterThan(enviosAntes),
        reason: 'a mudança da IA soa ao vivo, como o knob');
    expect(container.read(avisosMcpProvider)?.resumo, contains('Threshold'), reason: 'a tela avisa que foi a IA');

    final (erroUndo, _) = await ferramenta(endereco, token, 'undo');
    expect(erroUndo, isFalse);
    expect(container.read(editorProvider).atual!.bloco(limiar)!.valorBase('Threshold'), antes);
  });

  test('should_build_the_chain_a_tone_recipe_suggests_on_the_demo_pedal_when_the_ai_asks_for_a_player_tone',
      () async {
    final (container, endereco, token) = await appComMcp();
    final pedaleira = container.read(conexaoProvider.notifier).transporte! as TransporteDemonstracao;
    await chamar(endereco, token, 'initialize', {'protocolVersion': '2025-06-18'});

    // a IA estuda: receita + guia do primeiro bloco da cadeia
    final (erroReceita, receita) = await ferramenta(endereco, token, 'get_tone_recipe', {'query': 'Steve Harris tone'});
    expect(erroReceita, isFalse, reason: '$receita');
    final cadeia = ((receita! as Map)['chain'] as List).cast<Map<String, dynamic>>();
    final (erroGuia, guia) = await ferramenta(endereco, token, 'get_block_guide', {'type': cadeia.first['type']});
    expect(erroGuia, isFalse, reason: '$guia');
    expect((guia! as Map)['role'], isNotEmpty);

    // limpa o 01C e monta a cadeia sugerida, bloco a bloco, com os valores da receita
    final (_, aberto) = await ferramenta(endereco, token, 'get_current_preset');
    for (final linha in const ['1', '2']) {
      for (final bloco in ((aberto! as Map)['rows'][linha] as List).cast<Map<String, dynamic>>().reversed) {
        final (erro, _) = await ferramenta(endereco, token, 'remove_block', {'row': bloco['row'], 'column': bloco['column']});
        expect(erro, isFalse);
      }
    }
    final enviosAntes = pedaleira.comandosRecebidos.where((c) => c.acao == AcoesAnagram.tocarAoVivo).length;
    for (final passo in cadeia) {
      final posicao = {'row': passo['row'], 'column': passo['column']};
      final (erroAdd, adicionado) = await ferramenta(endereco, token, 'add_block', {...posicao, 'type': passo['type']});
      expect(erroAdd, isFalse, reason: '$adicionado');
      for (final ajuste in ((passo['settings'] as Map?) ?? const {}).entries) {
        final (erroSet, aplicado) =
            await ferramenta(endereco, token, 'set_parameter', {...posicao, 'parameter': ajuste.key, 'value': ajuste.value});
        expect(erroSet, isFalse, reason: '${passo['type']} ${ajuste.key}: $aplicado');
        expect((aplicado! as Map)['clamped'], isFalse, reason: 'a receita só traz valores dentro da faixa');
      }
    }

    final preset = container.read(editorProvider).atual!;
    // o último set_parameter deixa um envio ao vivo em voo: drená-lo antes de fechar o container
    await container.read(editorProvider.notifier).aplicarDocumento(preset);
    expect([for (final b in preset.blocosDaLinha(1)) b.uri], [for (final p in cadeia) p['type']]);
    expect(container.read(editorProvider).naoSalvo, isTrue, reason: 'montado ao vivo, nada gravado');
    expect(pedaleira.comandosRecebidos.where((c) => c.acao == AcoesAnagram.tocarAoVivo).length, greaterThan(enviosAntes),
        reason: 'cada passo soou na pedaleira de demonstração');
  });

  test('should_answer_401_and_change_nothing_when_the_token_is_missing_or_wrong', () async {
    final (container, endereco, token) = await appComMcp();
    final antes = container.read(editorProvider).atual;
    const mudar = {'name': 'set_parameter', 'arguments': {'row': 1, 'column': 1, 'parameter': 'Threshold', 'value': -12}};
    // mesmo tamanho, último caractere trocado: só a comparação inteira recusa
    final parecido = '${token.substring(0, token.length - 1)}${token.endsWith('A') ? 'B' : 'A'}';

    final (semToken, _) = await chamar(endereco, null, 'tools/call', mudar);
    final (curto, _) = await chamar(endereco, 'outro-token', 'tools/call', mudar);
    final (quase, _) = await chamar(endereco, parecido, 'tools/call', mudar);

    expect([semToken, curto, quase], everyElement(HttpStatus.unauthorized));
    expect(identical(container.read(editorProvider).atual, antes), isTrue);
  });

  test('should_not_write_to_the_pedal_when_the_player_declines_the_save_request', () async {
    final (container, endereco, token) = await appComMcp();
    final pedaleira = container.read(conexaoProvider.notifier).transporte! as TransporteDemonstracao;
    await ferramenta(endereco, token, 'set_parameter', {'row': 1, 'column': 1, 'parameter': 'Threshold', 'value': -12});
    final gravado = pedaleira.conteudoDoSlot(3);
    container.listen(pedidoSalvarProvider, (_, pedido) => pedido?.responder(false));

    final (erro, resposta) = await ferramenta(endereco, token, 'save_preset');

    expect(erro, isFalse);
    expect((resposta! as Map)['status'], 'declined');
    expect(pedaleira.conteudoDoSlot(3), gravado, reason: 'recusado, nada vai para o slot');
    expect(container.read(editorProvider).naoSalvo, isTrue);
  });

  test('should_save_nothing_when_the_preset_changed_while_the_player_was_confirming', () async {
    final (container, endereco, token) = await appComMcp();
    final pedaleira = container.read(conexaoProvider.notifier).transporte! as TransporteDemonstracao;
    await ferramenta(endereco, token, 'set_parameter', {'row': 1, 'column': 1, 'parameter': 'Threshold', 'value': -12});
    final gravado = pedaleira.conteudoDoSlot(3);
    container.listen(pedidoSalvarProvider, (_, pedido) async {
      if (pedido == null) return;
      // outra chamada da IA muda o som enquanto a pessoa lê a pergunta
      await ferramenta(endereco, token, 'set_parameter', {'row': 1, 'column': 1, 'parameter': 'Threshold', 'value': -30});
      pedido.responder(true);
    });

    final (erro, motivo) = await ferramenta(endereco, token, 'save_preset');

    expect(erro, isTrue, reason: 'a pessoa confirmou outro preset, não este');
    expect(motivo, contains('changed'));
    expect(pedaleira.conteudoDoSlot(3), gravado, reason: 'nada vai para o slot');
  });

  test('should_refuse_to_change_outputs_global_eq_and_input_through_mcp_and_send_nothing', () async {
    final (container, endereco, token) = await appComMcp();
    final pedaleira = container.read(conexaoProvider.notifier).transporte! as TransporteDemonstracao;

    final (_, lidos) = await ferramenta(endereco, token, 'get_global_settings');
    final recusas = [
      for (final (ajuste, valor) in [('headphones', -10), ('globaleq.3.gain', -18), ('eq_2_freq', 700), ('input_gain_1', 3)])
        await ferramenta(endereco, token, 'set_global_setting', {'setting': ajuste, 'value': valor}),
    ];

    final ajustes = ((lidos! as Map)['settings'] as List).cast<Map<String, dynamic>>();
    final fone = ajustes.firstWhere((s) => s['setting'] == 'headphones');
    expect(fone['value'], 6.0, reason: 'continua lendo o que a pedaleira tem');
    expect(fone['readOnly'], isTrue);
    for (final (recusado, motivo) in recusas) {
      expect(recusado, isTrue);
      expect(motivo, contains('no access to this pedal feature'));
      expect(motivo, contains('on the pedal'));
    }
    expect(pedaleira.comandosRecebidos.where((m) => m.acao == AcoesAnagram.gravarAjustes), isEmpty);
  });

  test('should_change_the_footswitch_mode_through_set_global_setting', () async {
    final (container, endereco, token) = await appComMcp();
    final pedaleira = container.read(conexaoProvider.notifier).transporte! as TransporteDemonstracao;

    final (erro, resposta) = await ferramenta(endereco, token, 'set_global_setting', {'setting': 'mode', 'value': 'scene'});

    expect(erro, isFalse, reason: '$resposta');
    expect((resposta! as Map)['value'], 'scene');
    expect(pedaleira.ajustesGlobais['mode'], 'scene');
    expect(container.read(editorProvider).naoSalvo, isFalse, reason: 'ajuste global não é do preset');
  });
}
