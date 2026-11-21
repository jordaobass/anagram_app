// O bloco Parametric EQ vira as bandas da curva do Global EQ: todo parâmetro
// visível está no painel, os cortes derrubam as pontas, banda desligada não
// mexe no som e o ganho geral sobe a curva inteira.
import 'package:anagram_app/apresentacao/componentes/painel_parametros.dart';
import 'package:anagram_app/nucleo/ajustes/curva_global_eq.dart';
import 'package:anagram_app/nucleo/ajustes/mapa_ajustes.dart';
import 'package:anagram_app/nucleo/catalogo/arranjo_parametros.dart';
import 'package:anagram_app/nucleo/catalogo/curva_eq_parametrico.dart';
import 'package:anagram_app/nucleo/catalogo/definicao_bloco.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';

void main() {
  final definicao = lerCatalogo().definicao('urn:darkglass:fil4#mono');
  final visiveis = parametrosVisiveis(definicao, const BlocoPreset(PosicaoBloco(1, 1), {'uri': 'urn:darkglass:fil4#mono'}));
  final grupos = agruparParametros(definicao, visiveis);
  num padrao(DefinicaoParametro p) => p.padrao;

  test('should_place_every_visible_parameter_of_the_block_in_the_panel', () {
    final noPainel = {
      for (final g in grupos) ...[for (final p in g.parametros) p.parametro.simbolo, if (g.chave != null) g.chave!.simbolo],
    };

    expect(noPainel, {for (final p in visiveis) p.simbolo});
    expect(noPainel, isNot(contains('peakreset')), reason: 'zera um medidor, não muda o som');
  });

  test('should_give_the_six_selector_bands_a_parameter_for_every_mode', () {
    final seletor = grupos.where(ehBandaDoSeletor).toList();

    expect(seletor, hasLength(6));
    for (final g in seletor) {
      for (final modo in ModoEq.values) {
        expect(parametroDoModo(g, modo), isNotNull, reason: '${g.banda} sem ${modo.name}');
      }
    }
    expect(parametroDoModo(seletor[2], ModoEq.freq)!.parametro.padrao, 397, reason: 'igual ao Global EQ');
  });

  test('should_cut_the_lows_and_highs_when_the_pass_filters_are_on', () {
    const passaAltas = [BandaGlobalEq(TipoBandaEq.highPass, 100, 0, 0.7)];
    const passaBaixas = [BandaGlobalEq(TipoBandaEq.lowPass, 2000, 0, 0.7)];

    expect(respostaEmDb(passaAltas, 25), lessThan(-18));
    expect(respostaEmDb(passaAltas, 2000).abs(), lessThan(0.5));
    expect(respostaEmDb(passaBaixas, 10000), lessThan(-18));
    expect(respostaEmDb(passaBaixas, 100).abs(), lessThan(0.5));
  });

  test('should_ignore_a_band_that_is_switched_off', () {
    const desligada = [BandaGlobalEq(TipoBandaEq.peak, 1000, 12, 0.5, false)];
    const corteDesligado = [BandaGlobalEq(TipoBandaEq.highPass, 1000, 0, 0.7, false)];

    expect(respostaEmDb(desligada, 1000), 0);
    expect(respostaEmDb(corteDesligado, 30), 0);
  });

  test('should_draw_the_block_defaults_flat_and_shift_the_curve_by_the_overall_gain', () {
    final curva = [for (final (_, banda) in bandasDaCurva(grupos, padrao)) banda];

    expect(curva.where((b) => b.ehCorte).every((b) => !b.ligada), isTrue, reason: 'cortes vêm desligados');
    expect(respostaEmDb(curva, 1000).abs(), lessThan(0.01));
    expect(respostaEmDb(curva, 1000, ganhoGeral: 6), closeTo(6, 0.01));
    expect(ganhoGeralDoBloco(grupos, padrao), 0);
  });
}
