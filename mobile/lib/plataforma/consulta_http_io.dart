// Consulta pelo HttpClient do dart:io: nenhum pacote a mais para um GET.
import 'dart:convert';
import 'dart:io';

import 'consulta_http.dart';

/// Celular fica de fora: no Android não há release publicada para baixar, e o
/// app nem pede a permissão de internet lá.
bool get verificacaoVersaoDisponivel => Platform.isWindows || Platform.isMacOS || Platform.isLinux;

ConsultaHttp criarConsultaHttp() => const ConsultaHttpIo();

class ConsultaHttpIo implements ConsultaHttp {
  const ConsultaHttpIo();

  @override
  Future<String> obter(Uri endereco, {required Map<String, String> cabecalhos, required Duration limite}) async {
    final cliente = HttpClient()..connectionTimeout = limite;
    try {
      return await _ler(cliente, endereco, cabecalhos).timeout(limite);
    } finally {
      cliente.close(force: true);
    }
  }

  static Future<String> _ler(HttpClient cliente, Uri endereco, Map<String, String> cabecalhos) async {
    final pedido = await cliente.getUrl(endereco);
    cabecalhos.forEach(pedido.headers.set);
    final resposta = await pedido.close();
    if (resposta.statusCode != HttpStatus.ok) {
      await resposta.drain<void>();
      throw ErroConsultaHttp(resposta.statusCode);
    }
    return resposta.transform(utf8.decoder).join();
  }
}
