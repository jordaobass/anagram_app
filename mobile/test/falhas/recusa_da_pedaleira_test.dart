// A pedaleira recusa no formato provado na bancada (DECISOES PD1):
// `{"success": 0, "err_message": "..."}`. Isso não pode virar "aceito".
import 'package:anagram_app/nucleo/protocolo/api_anagram.dart';
import 'package:anagram_app/nucleo/protocolo/cliente_anagram.dart';
import 'package:anagram_app/nucleo/protocolo/erros_anagram.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/pedaleira_roteirizada.dart';

void main() {
  for (final falhou in [0, false]) {
    test('should_report_the_refusal_when_the_pedal_answers_success_$falhou', () async {
      final pedaleira = PedaleiraRoteirizada((pedido) => [
            {
              'action': pedido.acao,
              'payload': {'success': falhou, 'err_message': 'Invalid settings key'},
            },
          ]);
      final cliente = ClienteAnagram(pedaleira);

      final chamada = cliente.chamar(AcoesAnagram.gravarAjustes, const {'settings': {'x': 1}});

      await expectLater(
        chamada,
        throwsA(isA<ErroRespostaInvalida>().having((erro) => erro.mensagem, 'mensagem', contains('Invalid settings key'))),
      );
    });
  }
}
