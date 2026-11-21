// O lado JSON-RPC do MCP, sem rede: recebe uma mensagem já decodificada e
// devolve a resposta (ou nada, para notificação). O transporte HTTP fica na
// plataforma; aqui é Dart puro, testável sem socket.

import '../registro.dart';
import 'ferramenta_mcp.dart';

abstract final class CodigosJsonRpc {
  static const requisicaoInvalida = -32600;
  static const metodoInexistente = -32601;
  static const parametrosInvalidos = -32602;
  static const erroInterno = -32603;
}

class ProtocoloMcp {
  ProtocoloMcp(List<FerramentaMcp> ferramentas, {required this.versaoApp})
      : _ferramentas = {for (final f in ferramentas) f.nome: f};

  /// Versões da especificação que este servidor fala, da mais nova à mais velha.
  static const versoesSuportadas = ['2025-06-18', '2025-03-26', '2024-11-05'];

  static const instrucoes = 'Controls a Darkglass Anagram bass pedal through the Anagram App. '
      'Always call get_current_preset first. Changes are heard live but are NOT saved: '
      'ask the player how it sounds, adjust, and only call save_preset when they are happy. '
      'You cannot hear the audio; rely on what the player describes.';

  final Map<String, FerramentaMcp> _ferramentas;
  final String versaoApp;

  /// `null` quando a mensagem é notificação (não leva resposta).
  Future<Map<String, dynamic>?> responder(Object? mensagem) async {
    if (mensagem is! Map<String, dynamic> || mensagem['jsonrpc'] != '2.0' || mensagem['method'] is! String) {
      return _erro(null, CodigosJsonRpc.requisicaoInvalida, 'Invalid JSON-RPC 2.0 request.');
    }
    final id = mensagem['id'];
    if (!mensagem.containsKey('id')) return null;
    final parametros = mensagem['params'] is Map<String, dynamic> ? mensagem['params'] as Map<String, dynamic> : const <String, dynamic>{};
    return switch (mensagem['method'] as String) {
      'initialize' => _sucesso(id, _inicializar(parametros)),
      'ping' => _sucesso(id, const <String, dynamic>{}),
      'tools/list' => _sucesso(id, {'tools': [for (final f in _ferramentas.values) f.paraLista()]}),
      'tools/call' => _chamar(id, parametros),
      final outro => _erro(id, CodigosJsonRpc.metodoInexistente, 'Method not found: $outro'),
    };
  }

  Map<String, dynamic> _inicializar(Map<String, dynamic> parametros) {
    final pedida = parametros['protocolVersion'];
    return {
      'protocolVersion': versoesSuportadas.contains(pedida) ? pedida : versoesSuportadas.first,
      'capabilities': {
        'tools': {'listChanged': false},
      },
      'serverInfo': {'name': 'anagram-app', 'title': 'Anagram App', 'version': versaoApp},
      'instructions': instrucoes,
    };
  }

  Future<Map<String, dynamic>> _chamar(Object? id, Map<String, dynamic> parametros) async {
    final ferramenta = _ferramentas[parametros['name']];
    if (ferramenta == null) {
      return _erro(id, CodigosJsonRpc.parametrosInvalidos, 'Unknown tool: ${parametros['name']}');
    }
    final argumentos = parametros['arguments'];
    final mapa = argumentos is Map<String, dynamic> ? argumentos : const <String, dynamic>{};
    try {
      return _sucesso(id, (await ferramenta.executar(mapa)).paraJson());
    } on RecusaFerramenta catch (recusa) {
      return _sucesso(id, ResultadoFerramenta.recusa(recusa.mensagem).paraJson());
    } on Object catch (erro, pilha) {
      // erro que a IA não tem como corrigir: vira erro JSON-RPC com o id do
      // pedido (DECISOES RN3), e a causa fica só no log
      registro.e('mcp: a ferramenta ${ferramenta.nome} falhou', error: erro, stackTrace: pilha);
      return _erro(id, CodigosJsonRpc.erroInterno, 'Internal error while running ${ferramenta.nome}.');
    }
  }

  static Map<String, dynamic> _sucesso(Object? id, Map<String, dynamic> resultado) =>
      {'jsonrpc': '2.0', 'id': id, 'result': resultado};

  static Map<String, dynamic> _erro(Object? id, int codigo, String mensagem) => {
        'jsonrpc': '2.0',
        'id': id,
        'error': {'code': codigo, 'message': mensagem},
      };
}
