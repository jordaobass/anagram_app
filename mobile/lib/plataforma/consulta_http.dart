// Uma consulta GET simples, só para saber se saiu versão nova (DECISOES AV1).
// Atrás de import condicional porque o web não tem dart:io; lá a verificação
// nem existe (o navegador já abre a versão publicada).
import 'consulta_http_io.dart' if (dart.library.js_interop) 'consulta_http_web.dart' as plataforma;

abstract interface class ConsultaHttp {
  /// Corpo da resposta 200 de [endereco]; lança [ErroConsultaHttp] em outro
  /// status e desiste depois de [limite].
  Future<String> obter(Uri endereco, {required Map<String, String> cabecalhos, required Duration limite});
}

/// O servidor respondeu, mas não com 200 (limite da API, página fora do ar).
class ErroConsultaHttp implements Exception {
  const ErroConsultaHttp(this.status);
  final int status;

  @override
  String toString() => 'resposta HTTP $status';
}

/// Windows, macOS e Linux: é onde a release é baixada à mão do GitHub.
bool get verificacaoVersaoDisponivel => plataforma.verificacaoVersaoDisponivel;

ConsultaHttp criarConsultaHttp() => plataforma.criarConsultaHttp();
