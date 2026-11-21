// Servidor MCP (Streamable HTTP) só no computador: escuta em 127.0.0.1 para
// a IA local ajustar o timbre. Atrás de import condicional porque o web não
// tem dart:io; lá (e no celular) a opção nem aparece.
import '../nucleo/mcp/protocolo_mcp.dart';
import 'servidor_mcp_io.dart' if (dart.library.js_interop) 'servidor_mcp_web.dart' as plataforma;

abstract interface class ServidorMcp {
  /// Começa a escutar; devolve a porta em uso (0 pede uma livre, nos testes).
  Future<int> iniciar({required int porta, required String token, required ProtocoloMcp protocolo});

  Future<void> parar();
}

/// A porta já tem dono (outro programa, ou outra cópia do app aberta).
class ErroPortaOcupada implements Exception {
  const ErroPortaOcupada(this.porta, this.causa);
  final int porta;
  final Object causa;

  @override
  String toString() => 'porta $porta ocupada: $causa';
}

/// Só Windows, macOS e Linux: no celular a IA local não roda ao lado do app.
bool get mcpDisponivel => plataforma.mcpDisponivel;

ServidorMcp criarServidorMcp() => plataforma.criarServidorMcp();
