// O app conectado à pedaleira de demonstração com o servidor MCP de verdade
// escutando numa porta livre, e as chamadas JSON-RPC que uma IA local faria.
import 'dart:convert';
import 'dart:io';

import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/aplicacao/estado/escopo_cenas.dart';
import 'package:anagram_app/aplicacao/mcp/avisos_mcp.dart';
import 'package:anagram_app/aplicacao/mcp/controlador_mcp.dart';
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/aplicacao/versao_app.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'app_de_teste.dart' show PreferenciasCenasEmMemoria, PreferenciasMcpEmMemoria;
import 'fixtures.dart';

/// App conectado à demonstração com o [slot] aberto e o MCP escutando numa porta livre.
/// [extras]: sobreposições a mais (a pasta de backups, por exemplo).
Future<(ProviderContainer, String, String)> appComMcp({String slot = '01C', List<Override> extras = const []}) async {
  final container = ProviderContainer(overrides: [
    ...extras,
    preferenciasCenasProvider.overrideWithValue(PreferenciasCenasEmMemoria()),
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
  await container.read(editorProvider.notifier).abrirSlot(SlotPreset.doRotulo(slot));
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

/// A pedaleira de demonstração por trás da conexão do [container].
TransporteDemonstracao pedaleiraDe(ProviderContainer container) =>
    container.read(conexaoProvider.notifier).transporte! as TransporteDemonstracao;
