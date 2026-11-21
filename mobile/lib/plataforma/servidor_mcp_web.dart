// No navegador não há como abrir porta: o MCP fica indisponível.
import '../nucleo/mcp/protocolo_mcp.dart';
import 'servidor_mcp.dart';

bool get mcpDisponivel => false;

ServidorMcp criarServidorMcp() => const _SemServidor();

class _SemServidor implements ServidorMcp {
  const _SemServidor();

  @override
  Future<int> iniciar({required int porta, required String token, required ProtocoloMcp protocolo}) =>
      throw UnsupportedError('MCP indisponível no navegador');

  @override
  Future<void> parar() async {}
}
