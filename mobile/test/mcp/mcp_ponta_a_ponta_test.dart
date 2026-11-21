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
import 'package:flutter_test/flutter_test.dart';

import '../apoio/app_de_teste.dart' show PreferenciasMcpEmMemoria;
import '../apoio/fixtures.dart';

/// App conectado à demonstração com o 01C aberto e o MCP escutando numa porta livre.
Future<(ProviderContainer, String, String)> appComMcp() async {
  final container = ProviderContainer(overrides: [
    presetsDemonstracaoProvider.overrideWith((ref) async => lerPresetsDemonstracao()),
    catalogoProvider.overrideWith((ref) async => lerCatalogo()),
    indiceMiniaturasProvider.overrideWith((ref) async => lerIndiceMiniaturas()),
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
    expect([for (final t in lista!['result']['tools'] as List) t['name']], containsAll(['set_parameter', 'save_preset']));

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

  test('should_change_a_global_output_on_the_pedal_and_refuse_a_setting_without_a_known_key', () async {
    final (container, endereco, token) = await appComMcp();
    final pedaleira = container.read(conexaoProvider.notifier).transporte! as TransporteDemonstracao;

    final (_, lidos) = await ferramenta(endereco, token, 'get_global_settings');
    final (erro, resposta) =
        await ferramenta(endereco, token, 'set_global_setting', {'setting': 'headphones', 'value': -40});
    final (recusado, motivo) = await ferramenta(endereco, token, 'set_global_setting', {'setting': 'master', 'value': 0});

    expect(((lidos! as Map)['settings'] as List).map((s) => (s as Map)['setting']), contains('headphones'));
    expect(erro, isFalse);
    expect((resposta! as Map)['value'], -30, reason: 'fora da faixa do mixer, fica no mínimo');
    expect(pedaleira.ajustesGlobais['mixer.headphones.vol'], -30);
    expect(container.read(editorProvider).naoSalvo, isFalse, reason: 'ajuste global não é do preset');
    expect(recusado, isTrue);
    expect(motivo, contains('not yet supported'));
  });

  test('should_change_a_mid_band_of_the_global_eq_through_mcp_with_the_pedal_key', () async {
    final (container, endereco, token) = await appComMcp();
    final pedaleira = container.read(conexaoProvider.notifier).transporte! as TransporteDemonstracao;

    final (erro, resposta) =
        await ferramenta(endereco, token, 'set_global_setting', {'setting': 'globaleq.3.gain', 'value': -18});

    expect(erro, isFalse);
    expect((resposta! as Map)['value'], -18, reason: 'o Global EQ vai a −18 dB, como a pedaleira aceitou');
    expect(pedaleira.ajustesGlobais['globaleq.3.gain'], -18);
  });
}
