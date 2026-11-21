// Trechos prontos para colar no cliente de IA. Cada cliente lê o servidor de
// um jeito: o LM Studio aceita URL com cabeçalho; o Claude Desktop só fala
// stdio, então vai pela ponte mcp-remote (com --transport http-only, senão
// ela tenta SSE primeiro e este servidor não tem SSE).
import 'dart:convert';

enum ClienteMcp { lmStudio, claudeDesktop, generico }

const _nomeServidor = 'anagram';

String trechoConfiguracao(ClienteMcp cliente, {required String endereco, required String token}) {
  const indentado = JsonEncoder.withIndent('  ');
  return switch (cliente) {
    ClienteMcp.lmStudio => indentado.convert({
        'mcpServers': {
          _nomeServidor: {
            'url': endereco,
            'headers': {'Authorization': 'Bearer $token'},
          },
        },
      }),
    ClienteMcp.claudeDesktop => indentado.convert({
        'mcpServers': {
          _nomeServidor: {
            'command': 'npx',
            'args': ['-y', 'mcp-remote', endereco, '--transport', 'http-only', '--header', 'Authorization: Bearer $token'],
          },
        },
      }),
    ClienteMcp.generico => 'Transport: Streamable HTTP\nURL: $endereco\nHeader: Authorization: Bearer $token',
  };
}
