// Um envio de relatório que nunca volta (USB travado) não pode prender a fila:
// a chamada estoura o prazo e a próxima ação ainda é atendida.
import 'package:anagram_app/nucleo/protocolo/api_anagram.dart';
import 'package:anagram_app/nucleo/protocolo/cliente_anagram.dart';
import 'package:anagram_app/nucleo/protocolo/erros_anagram.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/pedaleira_roteirizada.dart';

void main() {
  test('should_time_out_and_free_the_queue_when_sending_a_report_never_finishes', () async {
    final pedaleira = PedaleiraRoteirizada((pedido) => [
          {
            'action': pedido.acao,
            'payload': {'data': 'v1.19.2.24'},
          },
        ])
      ..travarProximoEnvio = true;
    final cliente = ClienteAnagram(pedaleira, prazoPadrao: const Duration(milliseconds: 50));

    final travada = cliente.chamar(AcoesAnagram.firmware);
    final seguinte = cliente.chamar(AcoesAnagram.firmware);
    await expectLater(travada, throwsA(isA<ErroSemResposta>()));

    expect(await seguinte.timeout(const Duration(seconds: 1)), containsPair('data', 'v1.19.2.24'));
  });
}
