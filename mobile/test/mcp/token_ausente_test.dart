// Configuração salva com o MCP ligado mas sem token (preferência apagada pela
// metade, versão antiga): o app abre com um token novo em vez de quebrar.
import 'package:anagram_app/aplicacao/mcp/controlador_mcp.dart';
import 'package:anagram_app/aplicacao/versao_app.dart';
import 'package:anagram_app/dados/preferencias_mcp.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/app_de_teste.dart' show PreferenciasMcpEmMemoria, ServidorMcpFalso;

void main() {
  test('should_listen_with_a_new_saved_token_when_mcp_was_left_on_without_one', () async {
    final preferencias = PreferenciasMcpEmMemoria()..salvo = const ConfiguracaoMcp(ativo: true);
    final servidor = ServidorMcpFalso();
    final container = ProviderContainer(overrides: [
      servidorMcpProvider.overrideWithValue(servidor),
      preferenciasMcpProvider.overrideWithValue(preferencias),
      mcpDisponivelProvider.overrideWithValue(true),
      versaoAppProvider.overrideWith((ref) async => '9.9.9'),
    ]);
    addTearDown(container.dispose);
    final erros = <Object>[];

    container.read(controladorMcpProvider);
    await container.read(controladorMcpProvider.notifier).definirPorta(ConfiguracaoMcp.portaPadrao).catchError(erros.add);

    expect(erros, isEmpty);
    expect(container.read(controladorMcpProvider).situacao, isA<McpEscutando>());
    expect(preferencias.salvo.token, hasLength(greaterThan(30)));
    expect(servidor.tokenEmUso, preferencias.salvo.token, reason: 'o token salvo é o que o servidor exige');
  });
}
