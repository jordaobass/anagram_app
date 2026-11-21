// No navegador não há verificação de versão: o site já serve a publicada.
import 'consulta_http.dart';

bool get verificacaoVersaoDisponivel => false;

ConsultaHttp criarConsultaHttp() => const _SemConsulta();

class _SemConsulta implements ConsultaHttp {
  const _SemConsulta();

  @override
  Future<String> obter(Uri endereco, {required Map<String, String> cabecalhos, required Duration limite}) =>
      throw UnsupportedError('verificação de versão indisponível no navegador');
}
