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
    expect(ajustePorIdOuChave('eq_ls_gain')!.chave, 'globaleq.ls.gain');
    expect(ajustePorIdOuChave('eq_hs_freq')!.chave, 'globaleq.hs.freq');
    expect(ajustePorIdOuChave('input_gain_1')!.chave, 'input-gain-preset0.db');
  });

  test('should_keep_settings_without_a_known_key_out_of_the_confirmed_list', () {
    final pendentes = mapaAjustes.where((a) => !a.confirmado).map((a) => a.id);

    expect(pendentes, containsAll(['master', 'input_gain_2', 'input_gain_6']));
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
    expect(plano.valor(ajustePorIdOuChave('eq_ls_gain')!), -3.0);
    expect(plano.placa, {'Headphone Gain': 2});
    expect(aninhado.valor(fone), 6.0);
  });

  test('should_map_the_six_global_eq_bands_to_the_keys_the_pedal_exported', () {
    final chaves = ajustesConfirmados(GrupoAjuste.globalEq).map((a) => a.chave).toSet();

    expect(chaves, {
      for (final banda in ['ls', '1', '2', '3', '4', 'hs'])
        for (final atributo in ['freq', 'gain', 'width']) 'globaleq.$banda.$atributo',
    });
    expect(ajustePorIdOuChave('eq_2_freq')!.padrao, 397, reason: 'o padrão real da banda 2, não os 400 da tela');
  });

  test('should_accept_minus_18_db_on_the_global_eq_since_the_pedal_stored_it', () {
    final ganho = ajustePorIdOuChave('eq_hs_gain')!;

    expect(ganho.limitar(-18), -18);
    expect(ganho.limitar(-30), -18);
  });

  test('should_widen_the_range_to_hold_a_value_the_pedal_returned_outside_it', () {
    final largura = ajustePorIdOuChave('eq_ls_width')!;

    final alargada = largura.abrangendo(6.5);

    expect(alargada.maximo, 6.5);
    expect(alargada.limitar(6.5), 6.5);
    expect(largura.abrangendo(1).maximo, largura.maximo, reason: 'valor dentro da faixa não muda nada');
  });

  test('should_draw_a_peak_at_its_gain_and_a_steep_shelf_without_breaking', () {
    const pico = [BandaGlobalEq(TipoBandaEq.peak, 1000, 6, 0.5)];
    const shelfLargura4 = [BandaGlobalEq(TipoBandaEq.lowShelf, 35, -7.8, 4.0)];

    expect(respostaEmDb(pico, 1000), closeTo(6, 0.1));
    expect(respostaEmDb(pico, 20000).abs(), lessThan(0.5));
    expect(respostaEmDb(shelfLargura4, 20), closeTo(-7.8, 1.5));
    expect(respostaEmDb(shelfLargura4, 1000).isFinite, isTrue);
  });

  test('should_cut_the_lows_and_leave_the_highs_when_the_low_shelf_gain_is_negative', () {
    const grave = [BandaGlobalEq(TipoBandaEq.lowShelf, 100, -6, 1)];
    const agudo = [BandaGlobalEq(TipoBandaEq.highShelf, 5000, 6, 1)];

    expect(respostaEmDb(grave, 20), closeTo(-6, 0.5));
    expect(respostaEmDb(grave, 10000), closeTo(0, 0.1));
    expect(respostaEmDb(agudo, 18000), closeTo(6, 0.7));
    expect(respostaEmDb(agudo, 50), closeTo(0, 0.1));
    expect(respostaEmDb(const [BandaGlobalEq(TipoBandaEq.lowShelf, 100, 0)], 50), 0);
  });
}
