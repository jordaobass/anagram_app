// O quadro HID termina no primeiro "DEND": um texto do preset com o marcador
// corta o pedido no meio, e a pedaleira real fica sem responder até o prazo.
// O app tem de recusar antes de mandar, com a causa dita.
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/modelo/documento_preset.dart';
import 'package:anagram_app/nucleo/protocolo/api_anagram.dart';
import 'package:anagram_app/nucleo/protocolo/cliente_anagram.dart';
import 'package:anagram_app/nucleo/protocolo/erros_anagram.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('should_refuse_before_sending_when_the_preset_carries_a_frame_marker', () async {
    final pedaleira = TransporteDemonstracao();
    await pedaleira.abrir();
    final api = ApiAnagram(ClienteAnagram(pedaleira));

    final envio = api.tocarAoVivo(DocumentoPreset.vazio('LEGENDEND'));

    await expectLater(
      envio,
      throwsA(isA<ErroRespostaInvalida>().having((erro) => erro.mensagem, 'mensagem', contains('DEND'))),
    );
    expect(pedaleira.comandosRecebidos, isEmpty);
  });
}
