// A consulta de verdade, contra um servidor local: leva só os cabeçalhos
// pedidos, transforma status diferente de 200 em erro com o número e desiste
// no limite em vez de segurar a abertura do app.
import 'dart:async';
import 'dart:io';

import 'package:anagram_app/plataforma/consulta_http.dart';
import 'package:anagram_app/plataforma/consulta_http_io.dart';
import 'package:flutter_test/flutter_test.dart';

Future<(HttpServer, Uri)> _servidor(Future<void> Function(HttpRequest pedido) responder) async {
  final servidor = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  addTearDown(() => servidor.close(force: true));
  servidor.listen(responder);
  return (servidor, Uri.parse('http://127.0.0.1:${servidor.port}/releases/latest'));
}

const _cabecalhos = {'Accept': 'application/vnd.github+json', 'User-Agent': 'AnagramApp/0.1.17'};

void main() {
  test('should_send_the_requested_headers_and_return_the_body', () async {
    HttpHeaders? recebidos;
    final (_, endereco) = await _servidor((pedido) async {
      recebidos = pedido.headers;
      pedido.response.write('{"tag_name":"v0.1.18"}');
      await pedido.response.close();
    });

    final corpo = await const ConsultaHttpIo().obter(endereco, cabecalhos: _cabecalhos, limite: const Duration(seconds: 5));

    expect(corpo, '{"tag_name":"v0.1.18"}');
    expect(recebidos?.value('user-agent'), 'AnagramApp/0.1.17');
    expect(recebidos?.value('accept'), 'application/vnd.github+json');
    expect(recebidos?.value('cookie'), isNull);
  });

  test('should_fail_with_the_status_when_the_answer_is_not_200', () async {
    final (_, endereco) = await _servidor((pedido) async {
      pedido.response.statusCode = HttpStatus.forbidden;
      await pedido.response.close();
    });

    final consulta = const ConsultaHttpIo().obter(endereco, cabecalhos: _cabecalhos, limite: const Duration(seconds: 5));

    await expectLater(consulta, throwsA(isA<ErroConsultaHttp>().having((erro) => erro.status, 'status', 403)));
  });

  test('should_give_up_at_the_time_limit_when_the_server_never_answers', () async {
    final (_, endereco) = await _servidor((pedido) => Completer<void>().future);
    final relogio = Stopwatch()..start();

    final consulta = const ConsultaHttpIo().obter(endereco, cabecalhos: _cabecalhos, limite: const Duration(milliseconds: 300));

    await expectLater(consulta, throwsA(isA<TimeoutException>()));
    expect(relogio.elapsed, lessThan(const Duration(seconds: 3)));
  });
}
