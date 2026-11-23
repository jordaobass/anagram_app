// Trechos prontos para colar no cliente de IA. Cada cliente lê o servidor de
// um jeito: o LM Studio aceita URL com cabeçalho; o Claude Desktop só fala
// stdio, então vai pela ponte mcp-remote (com --transport http-only, senão
// ela tenta SSE primeiro e este servidor não tem SSE). O GitHub Copilot no
// VS Code lê `mcpServers` com `type: http` em ~/.copilot/mcp-config.json
// (referência de configuração MCP do VS Code, atualizada em 18/11/2026; o
// antigo `.vscode/mcp.json` com `servers` é do harness Local, descontinuado).
import 'dart:convert';

enum ClienteMcp { lmStudio, claudeDesktop, vsCodeCopilot, generico }

const _nomeServidor = 'anagram';

/// Onde a pessoa confere o formato do VS Code se ele mudar de novo.
final documentacaoMcpVsCode = Uri.parse('https://code.visualstudio.com/docs/copilot/reference/mcp-configuration');

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
    ClienteMcp.vsCodeCopilot => indentado.convert({
        'mcpServers': {
          _nomeServidor: {
            'type': 'http',
            'url': endereco,
            'headers': {'Authorization': 'Bearer $token'},
            'tools': ['*'],
          },
        },
      }),
    ClienteMcp.generico => 'Transport: Streamable HTTP\nURL: $endereco\nHeader: Authorization: Bearer $token',
  };
}
