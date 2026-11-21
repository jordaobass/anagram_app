// O painel do multibanda não pode esconder parâmetro nem inventar um que a
// pedaleira não tem, e os 37 drives do Entropia se agrupam pela família.
import 'package:anagram_app/apresentacao/componentes/painel_parametros.dart';
import 'package:anagram_app/nucleo/catalogo/arranjo_multibanda.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';

void main() {
  for (final uri in ['urn:darkglass:ignissor', 'urn:darkglass:entropia']) {
    test('should_place_every_parameter_of_$uri in_the_band_panel_and_only_real_ones', () {
      final definicao = lerCatalogo().definicao(uri);
      final arranjo = arranjoMultibanda(uri)!;
      final visiveis = parametrosVisiveis(definicao, BlocoPreset(const PosicaoBloco(1, 1), {'uri': uri}));
      final doCatalogo = {for (final p in definicao.parametros) p.simbolo};

      expect(arranjo.simbolos, containsAll(visiveis.map((p) => p.simbolo)));
      expect(doCatalogo, containsAll(arranjo.simbolos));
    });
  }

  test('should_group_drive_types_by_family_keeping_turbo_apart_when_options_are_many', () {
    final opcoes = lerCatalogo().definicao('urn:darkglass:entropia').parametro('mid_drive_typemode')!.opcoes;

    final grupos = agruparOpcoes(opcoes);

    expect(grupos.keys, ['Bypass', 'B3K', 'VMT', 'Alpha', 'Omega', 'Chinchilla', 'B3K Turbo', 'VMT Turbo', 'Alpha Turbo', 'Omega Turbo']);
    expect(grupos['B3K Turbo']!.map((o) => o.$2), contains('B3K Turbo Grunt'));
    expect(grupos.values.expand((g) => g).length, opcoes.length);
  });

  test('should_share_the_ignissor_crossover_between_neighbour_bands_and_keep_entropia_filters_apart', () {
    expect(arranjoMultibanda('urn:darkglass:ignissor')!.alcas['lomid_xo_freq'],
        [BandaMultibanda.graves, BandaMultibanda.medios]);
    expect(arranjoMultibanda('urn:darkglass:entropia')!.alcas['mid_hp_freq'], [BandaMultibanda.medios]);
    expect(arranjoMultibanda('urn:darkglass:fil4#mono'), isNull);
  });
}
