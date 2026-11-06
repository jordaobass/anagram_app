import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/protocolo/api_anagram.dart';
import 'package:anagram_app/nucleo/protocolo/cliente_anagram.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('should_finish_a_pending_call_without_error_when_the_client_is_closed_meanwhile', () async {
    final pedaleira = TransporteDemonstracao(latencia: const Duration(milliseconds: 20));
    await pedaleira.abrir();
    final cliente = ClienteAnagram(pedaleira);

    final pendente = cliente.chamar(AcoesAnagram.firmware);
    await cliente.encerrar();
    await cliente.encerrar();

    expect(await pendente, containsPair('data', {'version': pedaleira.firmware}));
  });
}
