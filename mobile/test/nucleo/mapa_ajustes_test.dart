// O mapa dos ajustes globais é a ponte entre a tela e as chaves que a Anagram
// v1.19.2.24 aceitou de verdade (2026-11-21). Uma chave errada aqui faz o
// fader mexer e a pedaleira ignorar; um ajuste pendente enviado escreveria
// uma chave que a pedaleira não conhece.
import 'package:anagram_app/nucleo/ajustes/ajustes_pedaleira.dart';
import 'package:anagram_app/nucleo/ajustes/curva_global_eq.dart';
import 'package:anagram_app/nucleo/ajustes/mapa_ajustes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('should_map_each_output_to_the_flat_key_proven_on_the_pedal_in_the_mixer_order', () {
    final saidas = ajustesConfirmados(GrupoAjuste.saidas).map((a) => a.chave).toList();

    expect(saidas, [
      'mixer.jack.left.vol',
      'mixer.jack.right.vol',
      'mixer.xlr.left.vol',
      'mixer.xlr.right.vol',
      'mixer.headphones.vol',
      'mixer.speaker.vol',
    ]);
    expect(ajustePorIdOuChave('eq_low_gain')!.chave, 'globaleq.ls.gain');
    expect(ajustePorIdOuChave('eq_high_freq')!.chave, 'globaleq.hs.freq');
    expect(ajustePorIdOuChave('input_gain_1')!.chave, 'input-gain-preset0.db');
  });

  test('should_keep_settings_without_a_known_key_out_of_the_confirmed_list', () {
    final pendentes = mapaAjustes.where((a) => !a.confirmado).map((a) => a.id);

    expect(pendentes, containsAll(['master', 'eq_band2_gain', 'input_gain_2', 'input_gain_6']));
    expect(ajustesConfirmados().map((a) => a.id), isNot(contains('master')));
  });

  test('should_read_the_flat_export_and_a_nested_one_the_same_way', () {
    final plano = AjustesPedaleira.daResposta({
      'settings': {'mixer.headphones.vol': 6.0, 'globaleq.ls.gain': -3.0},
      'soundcard': {'Headphone Gain': 2},
    });
    final aninhado = AjustesPedaleira.daResposta({
      'data': {
        'settings': {
          'mixer': {'headphones': {'vol': 6.0}},
        },
      },
    });
    final fone = ajustePorIdOuChave('headphones')!;

    expect(plano.valor(fone), 6.0);
    expect(plano.valor(ajustePorIdOuChave('eq_low_gain')!), -3.0);
    expect(plano.placa, {'Headphone Gain': 2});
    expect(aninhado.valor(fone), 6.0);
  });

  test('should_cut_the_lows_and_leave_the_highs_when_the_low_shelf_gain_is_negative', () {
    const grave = [BandaGlobalEq(TipoBandaEq.lowShelf, 100, -6)];
    const agudo = [BandaGlobalEq(TipoBandaEq.highShelf, 5000, 6)];

    expect(respostaEmDb(grave, 20), closeTo(-6, 0.5));
    expect(respostaEmDb(grave, 10000), closeTo(0, 0.1));
    expect(respostaEmDb(agudo, 18000), closeTo(6, 0.7));
    expect(respostaEmDb(agudo, 50), closeTo(0, 0.1));
    expect(respostaEmDb(const [BandaGlobalEq(TipoBandaEq.lowShelf, 100, 0)], 50), 0);
  });
}
