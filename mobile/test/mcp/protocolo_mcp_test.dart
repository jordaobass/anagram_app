// Uma ferramenta que quebra de um jeito que ninguém previu não pode derrubar a
// resposta HTTP: a IA tem de receber um erro JSON-RPC com o id do pedido.
import 'package:anagram_app/nucleo/mcp/ferramenta_mcp.dart';
import 'package:anagram_app/nucleo/mcp/protocolo_mcp.dart';
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
}
