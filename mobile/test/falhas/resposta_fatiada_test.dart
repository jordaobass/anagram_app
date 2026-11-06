import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/protocolo/api_anagram.dart';
import 'package:anagram_app/nucleo/protocolo/cliente_anagram.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';

void main() {
  test('should_reassemble_reply_split_across_many_reports_after_leftover_bytes', () async {
    final base = lerPresetsDemonstracao()[3]!;
    final presets = {for (var n = 1; n <= 126; n++) n: base};
    final pedaleira = TransporteDemonstracao(presets: presets)..enviarSobraAntes = true;
    var relatoriosDeResposta = 0;
    pedaleira.relatoriosRecebidos.listen((_) => relatoriosDeResposta++);
    await pedaleira.abrir();
    final api = ApiAnagram(ClienteAnagram(pedaleira));

    final slots = await api.listarSlots();

    expect(relatoriosDeResposta, greaterThan(40), reason: 'a lista precisa vir fatiada');
    expect(slots, hasLength(126));
    expect(slots.last.slot.rotulo, '42C');
    expect(slots.last.nome, 'Grave Limpo');
  });
}
