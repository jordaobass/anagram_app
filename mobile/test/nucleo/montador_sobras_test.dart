import 'dart:convert';

import 'package:anagram_app/nucleo/protocolo/quadros_hid.dart';
import 'package:flutter_test/flutter_test.dart';

/// Bytes como a pedaleira manda: texto cru fatiado em relatórios de 64 bytes.
List<List<int>> _relatorios(String texto) => const CodificadorQuadros().fatiar(utf8.encode(texto));

Map<String, dynamic>? _alimentar(MontadorQuadros montador, String texto) {
  Map<String, dynamic>? quadro;
  for (final relatorio in _relatorios(texto)) {
    quadro ??= montador.acrescentar(relatorio);
  }
  return quadro;
}

void main() {
  test('should_read_the_current_reply_when_a_late_reply_left_an_unfinished_start_marker', () {
    final montador = MontadorQuadros();

    expect(_alimentar(montador, 'DSTART{"action":"get_preset_positions","pay'), isNull);
    final quadro = _alimentar(montador, 'DSTART{"action":"fetch_firmware_version","payload":{}}DEND');

    expect(quadro, {'action': 'fetch_firmware_version', 'payload': <String, dynamic>{}});
  });

  test('should_keep_the_next_frame_when_one_report_carries_the_end_of_one_and_a_whole_other', () {
    final montador = MontadorQuadros();

    final primeiro = montador.acrescentar(
        _relatorios('DSTART{"action":"a"}DENDDSTART{"action":"b"}DEND').first);

    expect(primeiro, {'action': 'a'});
    expect(montador.proximoQuadro(), {'action': 'b'});
    expect(montador.proximoQuadro(), isNull);
  });
}
