// Os painéis da bateria (Auto Drummer) e do metrônomo (Cognate Metro) não
// podem perder nem inventar parâmetro e seguem a ordem da tela da Anagram;
// a lista rolante mostra a marcada com as vizinhas; e o "Bater" do app acha o
// BPM pelos intervalos entre os toques.
import 'package:anagram_app/apresentacao/componentes/painel_parametros.dart';
import 'package:anagram_app/nucleo/catalogo/arranjo_utilitario.dart';
import 'package:anagram_app/nucleo/catalogo/definicao_bloco.dart';
import 'package:anagram_app/nucleo/catalogo/toque_de_tempo.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';

const _bateria = 'https://falktx.com/plugins/auto-drummer';
const _metro = 'https://cognate.audio/plugins/cognate-metro';

Duration _ms(int ms) => Duration(milliseconds: ms);

void main() {
  final catalogo = lerCatalogo();

  for (final uri in [_bateria, _metro]) {
    test('should_place_every_visible_parameter_of_$uri and cite none that does not exist', () {
      final visiveis = parametrosVisiveis(catalogo.definicao(uri), BlocoPreset(const PosicaoBloco(1, 1), {'uri': uri}))
          .map((p) => p.simbolo)
          .toSet();

      expect(arranjoUtilitario(uri)!.simbolos, visiveis);
    });
  }

  test('should_follow_the_order_of_the_pedal_screen_with_outputs_as_cards', () {
    List<List<String>> ordem(String uri) => [
          for (final s in arranjoUtilitario(uri)!.secoes) [for (final c in s.controles) c.simbolo],
        ];

    expect(ordem(_bateria), [
      ['style', 'level', 'action', 'status', 'useHostTempo', 'userTempo'],
    ]);
    expect(ordem(_metro), [
      ['tempo', 'mode', 'time_signature', 'sound', 'level'],
      ['gap_mode', 'accuracy'],
    ]);
    expect(arranjoUtilitario(_bateria)!.controle('action')!.tipo, TipoControleUtil.chave,
        reason: 'na tela da Anagram o Action é chave');
    expect(arranjoUtilitario(_bateria)!.simbolos, isNot(contains('status')), reason: 'saída não é parâmetro');
    expect(arranjoUtilitario(_metro)!.semControle, contains('tap'), reason: 'o tap do plugin não aparece na tela da pedaleira');
  });

  test('should_dim_the_tempo_knob_when_the_tempo_comes_from_elsewhere', () {
    final bateria = arranjoUtilitario(_bateria)!.controle('userTempo')!.apagamento!;
    final metro = arranjoUtilitario(_metro)!.controle('tempo')!.apagamento!;

    expect([bateria.simbolo, bateria.apaga(1), bateria.apaga(0)], ['useHostTempo', true, false]);
    expect([metro.simbolo, metro.apaga(0), metro.apaga(1), metro.apaga(2)], ['mode', false, true, true],
        reason: 'só o Fixed Tempo usa o knob');
  });

  test('should_show_the_marked_option_between_its_neighbours', () {
    expect(opcoesVisiveis(17, 5), [4, 5, 6], reason: 'Funk / [Jazz Ballad] / Jazz Jump Swing');
    expect(opcoesVisiveis(17, 0), [0, 1, 2], reason: 'no começo, as duas seguintes');
    expect(opcoesVisiveis(17, 16), [14, 15, 16], reason: 'no fim, as duas anteriores');
    expect(opcoesVisiveis(3, 1), [0, 1, 2]);
    expect(opcoesVisiveis(0, 0), isEmpty);
  });

  test('should_find_120_bpm_from_four_taps_500_ms_apart', () {
    final toque = ToqueDeTempo();

    final bpms = [for (final t in [0, 500, 1000, 1500]) toque.tocar(_ms(t))];

    expect(bpms, [null, 120, 120, 120], reason: 'o primeiro toque só marca o começo');
  });

  test('should_average_uneven_taps_and_start_over_after_a_long_pause', () {
    final toque = ToqueDeTempo();
    for (final t in [0, 480, 1000]) {
      toque.tocar(_ms(t));
    }
    expect(toque.tocar(_ms(1500)), 120, reason: 'média de 480, 520 e 500 ms');

    expect(toque.tocar(_ms(5000)), isNull, reason: 'depois de uma pausa longa, recomeça');
    expect(toque.tocar(_ms(5600)), 100);
  });

  test('should_keep_the_tapped_tempo_inside_the_parameter_range', () {
    const tempo = DefinicaoParametro(simbolo: 'tempo', nome: 'Tempo', minimo: 0, maximo: 300, padrao: 120, inteiro: true);
    final toque = ToqueDeTempo();
    toque.tocar(_ms(0));

    expect(tempo.limitar(toque.tocar(_ms(150))!), 300, reason: '400 bpm passa do máximo do plugin');
  });
}
