// A pedaleira toca o que está no PRÓPRIO bloco (enabled e valor de cada
// parâmetro); as cenas guardam a foto de cada cena. Nos presets reais o bloco
// sempre tem os valores da cena ativa. Mexer só na cena fazia o "ao vivo" não
// soar: o bloco desligado continuava ligado até salvar e recarregar.
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:anagram_app/nucleo/modelo/documento_preset.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';

Map<String, dynamic> _bruto(DocumentoPreset d, int linha, int casa) =>
    ((d.paraJson()['preset'] as Map<String, dynamic>)['chains'] as Map<String, dynamic>)['$linha']['blocks']['$casa']
        as Map<String, dynamic>;

num? _valorNoBloco(DocumentoPreset d, int linha, int casa, String simbolo) {
  final parametros = _bruto(d, linha, casa)['parameters'] as Map<String, dynamic>;
  return parametros.values.cast<Map<String, dynamic>>().firstWhere((p) => p['symbol'] == simbolo)['value'] as num?;
}

void main() {
  // exemplo 1: cena ativa 2; Suppressor na linha 1 casa 1, basshammer em 1·3 com Bass por cena
  final exemplo = DocumentoPreset.doJson(lerExemplo('1'));

  test('should_switch_the_block_itself_off_when_it_is_bypassed_in_the_active_scene', () {
    final desligado = exemplo.comBlocoHabilitado(const PosicaoBloco(1, 1), false);

    expect(_bruto(desligado, 1, 1)['enabled'], isFalse, reason: 'é o enabled do bloco que a pedaleira toca');
    expect(desligado.bloco(const PosicaoBloco(1, 1))!.habilitadoNaCena(2), isFalse);
    expect(desligado.bloco(const PosicaoBloco(1, 1))!.habilitadoNaCena(1), isTrue, reason: 'as outras cenas não mudam');
  });

  test('should_change_the_block_value_when_the_active_scene_has_its_own_value_for_the_parameter', () {
    final mexido = exemplo.comParametro(const PosicaoBloco(1, 3), 'Bass', 9);

    expect(_valorNoBloco(mexido, 1, 3, 'Bass'), 9, reason: 'o valor do bloco é o que soa');
    expect(mexido.bloco(const PosicaoBloco(1, 3))!.valorNaCena('Bass', 2), 9);
    expect(mexido.bloco(const PosicaoBloco(1, 3))!.valorNaCena('Bass', 1), 7.5, reason: 'a cena 1 guarda o dela');
  });

  test('should_load_the_new_scene_values_into_the_block_and_keep_the_old_ones_when_switching_scenes', () {
    final desligadoNa2 = exemplo.comBlocoHabilitado(const PosicaoBloco(1, 1), false);
    final na1 = desligadoNa2.comCena(1);

    expect(_valorNoBloco(na1, 1, 3, 'Bass'), 7.5, reason: 'o bloco passa a ter o valor da cena 1');
    expect(_bruto(na1, 1, 1)['enabled'], isTrue, reason: 'na cena 1 o Suppressor está ligado');

    final de2Volta = na1.comCena(2);
    expect(_bruto(de2Volta, 1, 1)['enabled'], isFalse, reason: 'voltar à cena 2 traz o desligado dela');
    expect(_valorNoBloco(de2Volta, 1, 3, 'Bass'), closeTo(6.12, 0.001));
  });
}
