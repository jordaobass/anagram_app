// Transporte Streamable HTTP do MCP com dart:io: um POST por mensagem
// JSON-RPC em /mcp, resposta em application/json (sem SSE: nenhuma
// ferramenta precisa mandar nada por conta própria). Três travas: só
// 127.0.0.1, token Bearer e Origin de fora recusado (página da internet
// tentando falar com o app pelo navegador da pessoa).
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../nucleo/mcp/protocolo_mcp.dart';
import '../nucleo/registro.dart';
import 'servidor_mcp.dart';

bool get mcpDisponivel => Platform.isWindows || Platform.isMacOS || Platform.isLinux;

ServidorMcp criarServidorMcp() => ServidorMcpIo();

class ServidorMcpIo implements ServidorMcp {
  static const caminho = '/mcp';
  static const _limiteCorpo = 1024 * 1024;
  static const _hostsLocais = {'localhost', '127.0.0.1', '[::1]', '::1'};

  HttpServer? _servidor;

  @override
  Future<int> iniciar({required int porta, required String token, required ProtocoloMcp protocolo}) async {
    await parar();
    try {
      _servidor = await HttpServer.bind(InternetAddress.loopbackIPv4, porta);
    } on SocketException catch (erro) {
      throw ErroPortaOcupada(porta, erro);
    }
    _servidor!.listen((requisicao) => unawaited(_atender(requisicao, token, protocolo)));
    registro.i('mcp: escutando em 127.0.0.1:${_servidor!.port}$caminho');
    return _servidor!.port;
  }

  @override
  Future<void> parar() async {
    final servidor = _servidor;
    _servidor = null;
    await servidor?.close(force: true);
  }

  Future<void> _atender(HttpRequest requisicao, String token, ProtocoloMcp protocolo) async {
    final resposta = requisicao.response;
    try {
      if (_recusa(requisicao, token) case (final int codigo, final String motivo)) {
        return await _responder(resposta, codigo, {'error': motivo});
      }
      final corpo = await _lerCorpo(requisicao);
      final saida = await protocolo.responder(corpo);
      if (saida == null) return await _responder(resposta, HttpStatus.accepted, null);
      await _responder(resposta, HttpStatus.ok, saida);
    } on FormatException catch (erro) {
      await _responder(resposta, HttpStatus.badRequest, _erroDeLeitura(erro.message));
    } on Object catch (erro, pilha) {
      registro.e('mcp: falha ao atender ${requisicao.method} ${requisicao.uri}', error: erro, stackTrace: pilha);
      await _responder(resposta, HttpStatus.internalServerError, {'error': 'internal error'});
    }
  }

  /// O que barra a requisição antes de ler o corpo, ou `null` se ela passa.
  (int, String)? _recusa(HttpRequest requisicao, String token) {
    if (requisicao.uri.path != caminho) return (HttpStatus.notFound, 'use POST $caminho');
    final origem = requisicao.headers.value('origin');
    if (origem != null && !_hostsLocais.contains(Uri.tryParse(origem)?.host)) {
      return (HttpStatus.forbidden, 'origin not allowed');
    }
    if (!_tokenConfere(requisicao.headers.value(HttpHeaders.authorizationHeader), token)) {
      requisicao.response.headers.set(HttpHeaders.wwwAuthenticateHeader, 'Bearer');
      return (HttpStatus.unauthorized, 'missing or wrong Bearer token');
    }
    if (requisicao.method != 'POST') {
      requisicao.response.headers.set(HttpHeaders.allowHeader, 'POST');
      return (HttpStatus.methodNotAllowed, 'only POST is supported (no SSE stream)');
    }
    return null;
  }

  /// Compara sem parar no primeiro caractere diferente (não vaza o token pelo tempo).
  static bool _tokenConfere(String? cabecalho, String token) {
    final esperado = 'Bearer $token';
    if (cabecalho == null || cabecalho.length != esperado.length) return false;
    var diferenca = 0;
    for (var i = 0; i < esperado.length; i++) {
      diferenca |= cabecalho.codeUnitAt(i) ^ esperado.codeUnitAt(i);
    }
    return diferenca == 0;
  }

  static Future<Object?> _lerCorpo(HttpRequest requisicao) async {
    final bytes = <int>[];
    await for (final pedaco in requisicao) {
      bytes.addAll(pedaco);
      if (bytes.length > _limiteCorpo) throw const FormatException('body too large');
    }
    return jsonDecode(utf8.decode(bytes));
  }

  static Map<String, dynamic> _erroDeLeitura(String detalhe) => {
        'jsonrpc': '2.0',
        'id': null,
        'error': {'code': -32700, 'message': 'Parse error: $detalhe'},
      };

  static Future<void> _responder(HttpResponse resposta, int codigo, Object? corpo) async {
    resposta.statusCode = codigo;
    if (corpo != null) {
      resposta.headers.contentType = ContentType.json;
      resposta.write(jsonEncode(corpo));
    }
    await resposta.close();
  }
}
