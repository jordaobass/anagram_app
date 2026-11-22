// Valores com nome próprio no plugin: o Tempo do Cognate Metro em 0 é
// "Listening" (ouvindo o tempo tocado) e o Level no mínimo é "-Inf" (mudo).
// A pedaleira mostra esses rótulos; o app não pode mostrar "0" e "-40,0 dB".
import 'package:anagram_app/nucleo/catalogo/formatador_valor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';

const _metro = 'https://cognate.audio/plugins/cognate-metro';
const _bateria = 'https://falktx.com/plugins/auto-drummer';

void main() {
  final catalogo = lerCatalogo();

  test('should_show_the_plugin_label_for_a_named_value_and_the_number_elsewhere', () {
    final tempo = catalogo.definicao(_metro).parametro('tempo')!;
    final nivelMetro = catalogo.definicao(_metro).parametro('level')!;
    final nivelBateria = catalogo.definicao(_bateria).parametro('level')!;

    expect(FormatadorValor.formatar(tempo, 0), 'Listening');
    expect(FormatadorValor.formatar(tempo, 120), '120');
    expect(FormatadorValor.formatar(nivelMetro, -40), '-Inf');
    expect(FormatadorValor.formatar(nivelMetro, -39.5), '-39,5 dB');
    expect(FormatadorValor.formatar(nivelBateria, -30), '-Inf');
  });

  test('should_write_bpm_after_a_tempo_in_beats_per_minute', () {
    final tempo = catalogo.definicao(_bateria).parametro('userTempo')!.comUnidade('bpm', inteiro: true);

    expect(FormatadorValor.formatar(tempo, 120), '120 bpm');
    expect(tempo.limitar(96.6), 97, reason: 'tempo de metrônomo é inteiro');
  });
}
