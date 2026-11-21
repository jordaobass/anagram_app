// O painel do Axioma não pode perder nem inventar parâmetro, e os desenhos
// têm de seguir os knobs: a onda escolhida, o pico da ressonância no corte e
// o envelope mais longo quando o knob sobe.
import 'package:anagram_app/apresentacao/componentes/painel_parametros.dart';
import 'package:anagram_app/nucleo/catalogo/arranjo_sintetizador.dart';
import 'package:anagram_app/nucleo/catalogo/desenho_sintetizador.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';

const _axioma = 'urn:darkglass:axioma_synth';

void main() {
  final catalogo = lerCatalogo();
  final arranjo = arranjoSintetizador(_axioma)!;

  test('should_place_every_visible_axioma_parameter_in_a_section_and_cite_none_that_does_not_exist', () {
    final definicao = catalogo.definicao(_axioma);
    final visiveis = parametrosVisiveis(definicao, const BlocoPreset(PosicaoBloco(1, 1), {'uri': _axioma}))
        .map((p) => p.simbolo)
        .toSet();

    expect(arranjo.simbolos, visiveis, reason: 'nenhum some do painel, nenhum é inventado');
    for (final s in [arranjo.corte, arranjo.ressonancia, arranjo.ataque, arranjo.decaimento, arranjo.liberacao]) {
      expect(visiveis, contains(s), reason: 'o desenho lê um parâmetro real: $s');
    }
  });

  test('should_map_each_catalog_wave_option_to_a_drawable_shape', () {
    final ondas = catalogo.definicao(_axioma).parametro('osc1_wave')!.opcoes;

    expect(ondas.map(formaDaOpcao), [FormaOnda.serra, FormaOnda.quadrada, FormaOnda.triangulo]);
    expect(formaDaOpcao('Noise'), isNull, reason: 'opção desconhecida não vira desenho chutado');
  });

  test('should_draw_a_square_wave_with_vertical_walls_and_a_saw_that_ramps_then_drops', () {
    final quadrada = pontosDaOnda(FormaOnda.quadrada, ciclos: 1);
    expect(quadrada[1].$1, quadrada[2].$1, reason: 'a parede da quadrada é vertical');
    expect({for (final p in quadrada) p.$2}, {1, -1});

    final serra = pontosDaOnda(FormaOnda.serra, ciclos: 2);
    expect(serra.first, (0.0, -1.0));
    expect(serra[1], (0.5, 1.0), reason: 'sobe o ciclo inteiro');
    expect(serra[2], (0.5, -1.0), reason: 'e cai de uma vez');
    expect(serra.last.$1, 1);
  });

  test('should_peak_near_the_cutoff_when_resonance_is_high_and_stay_flat_without_it', () {
    final fc = frequenciaDeCorte(5);
    final xCorte = posicaoDaFrequencia(fc);
    double pico(List<(double, double)> curva) => curva.map((p) => p.$2).reduce((a, b) => a > b ? a : b);

    final ressonante = respostaDoFiltro(corte: 5, ressonancia: 10);
    final ondePica = ressonante.firstWhere((p) => p.$2 == pico(ressonante)).$1;
    expect(pico(ressonante), greaterThan(15), reason: 'Q alto, pico alto');
    expect((ondePica - xCorte).abs(), lessThan(0.03), reason: 'o pico fica no corte');
    expect(pico(respostaDoFiltro(corte: 5, ressonancia: 0)), lessThan(0.5), reason: 'sem ressonância, sem pico');
    expect(ressonante.last.$2, lessThan(-40), reason: 'passa-baixas: os agudos caem');
  });

  test('should_move_the_cutoff_right_when_the_knob_goes_up', () {
    expect(frequenciaDeCorte(0), closeTo(40, 0.01));
    expect(frequenciaDeCorte(10), closeTo(18000, 0.1));
    expect(frequenciaDeCorte(7), greaterThan(frequenciaDeCorte(3)));
  });

  test('should_stretch_each_envelope_stage_with_its_knob_and_end_silent', () {
    final curto = curvaDoEnvelope(ataque: 0, decaimento: 3, liberacao: 0);
    final longo = curvaDoEnvelope(ataque: 10, decaimento: 3, liberacao: 0);

    expect(curto.first, (0.0, 0.0));
    expect(curto[1].$2, 1, reason: 'o attack chega ao topo');
    expect(longo[1].$1, greaterThan(curto[1].$1), reason: 'attack maior, subida mais longa');
    expect(curto[2].$2, nivelSegurado);
    expect(curto.last, (1.0, 0.0), reason: 'o release volta ao silêncio no fim');
  });
}
