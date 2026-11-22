// Uma ferramenta que quebra de um jeito que ninguém previu não pode derrubar a
// resposta HTTP: a IA tem de receber um erro JSON-RPC com o id do pedido.
// Recursos e prompts existem para o cliente que os lê (IC3): quem só usa
// ferramentas não perde nada, mas quem lê recebe o mesmo conhecimento.
import 'package:anagram_app/nucleo/mcp/ferramenta_mcp.dart';
import 'package:anagram_app/nucleo/mcp/protocolo_mcp.dart';
import 'package:anagram_app/nucleo/mcp/recursos_mcp.dart';
import 'package:flutter_test/flutter_test.dart';

class _FerramentaQueQuebra extends FerramentaMcp {
  const _FerramentaQueQuebra();

  @override
  String get nome => 'quebra';

  @override
  String get descricao => 'Always fails.';

  @override
  Map<String, dynamic> get esquema => esquemaObjeto(const {});

  @override
  Future<ResultadoFerramenta> executar(Map<String, dynamic> argumentos) async => throw StateError('estado impossível');
}

Map<String, dynamic> _pedido(int id, String metodo, [Map<String, dynamic>? params]) =>
    {'jsonrpc': '2.0', 'id': id, 'method': metodo, 'params': ?params};

void main() {
  test('should_answer_an_internal_json_rpc_error_when_a_tool_throws_unexpectedly', () async {
    final protocolo = ProtocoloMcp(const [_FerramentaQueQuebra()], versaoApp: '0.0.0');

    final resposta = await protocolo.responder({
      'jsonrpc': '2.0',
      'id': 7,
      'method': 'tools/call',
      'params': {'name': 'quebra', 'arguments': <String, dynamic>{}},
    });

    expect(resposta!['id'], 7);
    expect(resposta['error']['code'], CodigosJsonRpc.erroInterno);
  });

  test('should_serve_the_knowledge_as_resources_and_the_session_prompt_when_the_client_asks_for_them', () async {
    var leituras = 0;
    final protocolo = ProtocoloMcp(const [], versaoApp: '0.0.0', recursos: [
      RecursoMcp(uri: 'anagram://knowledge/blocks', nome: 'Blocks', descricao: 'Guide', ler: () async {
        leituras++;
        return '{"blocks":[]}';
      }),
    ], prompts: const [
      PromptMcp(nome: 'tone_session', descricao: 'Session', texto: 'Ask the player.'),
    ]);

    final inicio = await protocolo.responder(_pedido(1, 'initialize', {'protocolVersion': '2025-06-18'}));
    final lista = await protocolo.responder(_pedido(2, 'resources/list'));
    final leiturasAposListar = leituras;
    final leitura = await protocolo.responder(_pedido(3, 'resources/read', {'uri': 'anagram://knowledge/blocks'}));
    final inexistente = await protocolo.responder(_pedido(4, 'resources/read', {'uri': 'anagram://nada'}));
    final prompts = await protocolo.responder(_pedido(5, 'prompts/list'));
    final prompt = await protocolo.responder(_pedido(6, 'prompts/get', {'name': 'tone_session'}));

    expect((inicio!['result']['capabilities'] as Map).keys, containsAll(['tools', 'resources', 'prompts']));
    expect(inicio['result']['instructions'], contains('get_tone_recipe'), reason: 'o fluxo recomendado vai no initialize');
    expect((lista!['result']['resources'] as List).single['uri'], 'anagram://knowledge/blocks');
    expect(leiturasAposListar, 0, reason: 'listar não lê o arquivo');
    expect((leitura!['result']['contents'] as List).single['text'], '{"blocks":[]}');
    expect(leituras, 1);
    expect(inexistente!['error']['code'], CodigosJsonRpc.recursoInexistente);
    expect((prompts!['result']['prompts'] as List).single['name'], 'tone_session');
    expect((prompt!['result']['messages'] as List).single['content']['text'], 'Ask the player.');
  });

  test('should_not_announce_resources_or_prompts_when_the_server_has_none', () async {
    final protocolo = ProtocoloMcp(const [], versaoApp: '0.0.0');

    final inicio = await protocolo.responder(_pedido(1, 'initialize', {'protocolVersion': '2025-06-18'}));

    expect((inicio!['result']['capabilities'] as Map).keys, ['tools']);
  });
}
