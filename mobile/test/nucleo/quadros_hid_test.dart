import 'dart:convert';

import 'package:anagram_app/nucleo/protocolo/quadros_hid.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('should_reassemble_the_message_when_it_is_framed_in_64_byte_reports', () {
    const mensagem = MensagemAnagram('fetch_anagram_preset', {'filename': '49.json', 'nome': 'Ação'});
    final relatorios = const CodificadorQuadros().codificar(mensagem);

    expect(relatorios.every((r) => r.length == 64 && r.first == 0x01), isTrue);
    expect(relatorios.last.skip(1).every((b) => b == 0), isTrue, reason: 'flush final');
    final texto = utf8.decode(relatorios.expand((r) => r.skip(1)).where((b) => b != 0).toList());
    expect(texto, startsWith('DSTART{"action":"fetch_anagram_preset"'));

    final montador = MontadorQuadros();
    Map<String, dynamic>? quadro;
    for (final r in relatorios) {
      quadro ??= montador.acrescentar(r);
    }
    expect(quadro, {'action': 'fetch_anagram_preset', 'payload': {'filename': '49.json', 'nome': 'Ação'}});
  });
}
