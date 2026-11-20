// Montar a cadeia: pôr um efeito novo numa casa e mudar blocos de lugar sem
// perder o que a pedaleira guarda (parâmetros, cenas, pots e footswitches).
import 'dart:convert';

import 'package:anagram_app/nucleo/catalogo/biblioteca_blocos.dart';
import 'package:anagram_app/nucleo/catalogo/familia_bloco.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:anagram_app/nucleo/modelo/documento_preset.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';

/// Onde cada controle (pot, foot, pedal de expressão) aponta: "linha·casa".
Map<String, List<String>> _alvosDosControles(DocumentoPreset documento) {
  final vinculos = (documento.paraJson()['preset'] as Map<String, dynamic>)['bindings'] as Map<String, dynamic>;
  return {
    for (final e in vinculos.entries)
      e.key: [
        for (final p in (e.value as Map<String, dynamic>)['parameters'] as List<dynamic>)
          '${(p as Map<String, dynamic>)['row']}·${p['block']}',
      ],
  };
}

void main() {
  final catalogo = lerCatalogo();

  test('should_build_the_block_in_the_device_format_with_catalog_defaults_when_picked_from_the_library', () {
    final bloco = blocoNovo(catalogo.definicao('urn:darkglass:Suppressor'));

    final real = (lerExemplo('1')['preset']['chains']['1']['blocks'] as Map<String, dynamic>)['1'] as Map<String, dynamic>;
    expect(bloco.keys.toSet(), real.keys.toSet(), reason: 'mesmas chaves de um bloco gravado pela pedaleira');
    expect(bloco['uri'], 'urn:darkglass:Suppressor');
    expect(bloco['quickpot'], 'Threshold');
    expect([for (final p in (bloco['parameters'] as Map<String, dynamic>).values) (p as Map)['value']], [-40, 6]);
    expect((bloco['scenes'] as Map<String, dynamic>).keys, ['1', '2', '3']);
  });

  test('should_leave_out_bypass_and_reset_controls_when_the_catalog_block_has_them', () {
    final bloco = blocoNovo(catalogo.definicao('urn:darkglass:neural:pedal'));

    final simbolos = [for (final p in (bloco['parameters'] as Map<String, dynamic>).values) (p as Map)['symbol']];
    expect(simbolos, isNot(contains('enabled')));
    expect(simbolos, isNot(contains('reset')));
  });

  test('should_put_the_new_block_in_the_empty_slot_and_survive_a_json_round_trip_when_added', () {
    final documento = DocumentoPreset.doJson(lerExemplo('1'));
    const vazia = PosicaoBloco(1, 4);

    final editado = documento.comBlocoColado(vazia, blocoNovo(catalogo.definicao('urn:darkglass:Suppressor')));

    expect(editado.bloco(vazia)?.uri, 'urn:darkglass:Suppressor');
    final ida = jsonEncode(editado.paraJson());
    expect(jsonEncode(DocumentoPreset.doJson(jsonDecode(ida) as Map<String, dynamic>).paraJson()), ida);
  });

  test('should_move_the_block_with_its_scenes_and_empty_the_origin_when_dropped_on_an_empty_slot', () {
    final documento = DocumentoPreset.doJson(lerExemplo('1'));
    const origem = PosicaoBloco(1, 1);
    const destino = PosicaoBloco(1, 4);
    final antes = documento.bloco(origem)!.bruto;

    final movido = documento.comBlocoMovido(origem, destino);

    expect(movido.bloco(origem), isNull);
    expect(jsonEncode(movido.bloco(destino)!.bruto), jsonEncode(antes));
    expect([for (final b in movido.blocosDaLinha(1)) b.posicao.casa], [2, 3, 4, 5, 6, 7, 8, 11]);
  });

  test('should_swap_both_blocks_and_their_controls_when_dropped_on_an_occupied_slot', () {
    final documento = DocumentoPreset.doJson(lerExemplo('1'));
    const wah = PosicaoBloco(1, 2);
    const b3k = PosicaoBloco(2, 2);
    expect(_alvosDosControles(documento), {'exp.pedal': ['1·2'], 'pot1': ['2·2'], 'pot2': ['1·8']});

    final trocado = documento.comBlocoMovido(wah, b3k);

    expect(trocado.bloco(b3k)?.uri, 'urn:darkglass:wah');
    expect(trocado.bloco(wah)?.uri, 'urn:darkglass:B3K');
    expect(_alvosDosControles(trocado), {'exp.pedal': ['2·2'], 'pot1': ['1·2'], 'pot2': ['1·8']},
        reason: 'o pedal de expressão segue o wah e o pot1 segue o B3K');
  });

  test('should_offer_effects_by_category_without_routing_blocks_and_filter_by_name', () {
    final grupos = blocosDaBiblioteca(catalogo);
    final uris = [for (final g in grupos) for (final b in g.blocos) b.uri];

    expect(uris, isNot(contains('urn:darkglass-anagram:split')));
    expect(uris, isNot(contains('urn:darkglass-anagram:merge')));
    expect(uris, contains('urn:darkglass:Suppressor'));
    expect(grupos.map((g) => g.familia).toSet().length, grupos.length, reason: 'uma seção por família');

    final busca = blocosDaBiblioteca(catalogo, busca: 'SUPPRESS');
    expect([for (final g in busca) for (final b in g.blocos) b.nome], ['Suppressor']);
  });

  test('should_refuse_to_move_split_or_merge_when_asked', () {
    final documento = DocumentoPreset.doJson(lerExemplo('1'));
    final split = documento.blocosDaLinha(1).firstWhere((b) => b.uri.endsWith(':split')).posicao;

    expect(podeMover(documento, split, const PosicaoBloco(1, 4)), isFalse);
    expect(podeMover(documento, const PosicaoBloco(1, 1), split), isFalse, reason: 'trocar também tiraria o split do lugar');
    expect(podeMover(documento, const PosicaoBloco(1, 1), const PosicaoBloco(1, 4)), isTrue);
  });

  test('should_release_the_controls_of_a_removed_block_when_another_block_takes_its_slot', () {
    final preset = DocumentoPreset.doJson(lerExemplo('1'));
    final wah = const PosicaoBloco(1, 2);
    expect(_alvosDosControles(preset)['exp.pedal'], ['1·2'], reason: 'no exemplo 1 o pedal move o wah');

    final semWah = preset.semBloco(wah);

    expect(_alvosDosControles(semWah).containsKey('exp.pedal'), isFalse,
        reason: 'o pedal não pode passar a mexer no próximo bloco posto nessa casa');
    expect(_alvosDosControles(semWah).keys, containsAll(['pot1', 'pot2']), reason: 'os outros controles ficam');
  });

  test('should_list_only_modulation_effects_when_the_modulation_filter_is_chosen', () {
    final grupos = blocosDaBiblioteca(catalogo, familia: FamiliaBloco.modulacao);
    final blocos = [for (final g in grupos) ...g.blocos];

    expect(blocos, isNotEmpty);
    expect(blocos.map((b) => b.familia).toSet(), {FamiliaBloco.modulacao});
    expect(grupos.map((g) => g.familia), [FamiliaBloco.modulacao], reason: 'as seções são as mesmas famílias do filtro');
  });

  test('should_combine_the_filter_with_the_name_search_when_both_are_used', () {
    final semFiltro = blocosDaBiblioteca(catalogo, busca: 'cabinet');
    final comFiltro = blocosDaBiblioteca(catalogo, busca: 'cabinet', familia: FamiliaBloco.drive);

    expect(semFiltro, isNotEmpty);
    expect(comFiltro, isEmpty, reason: 'nenhum gabinete é drive');
  });

  test('should_offer_as_filters_only_the_families_that_have_effects_in_the_library', () {
    final familias = familiasDaBiblioteca(catalogo);

    expect(familias, containsAll([FamiliaBloco.drive, FamiliaBloco.modulacao, FamiliaBloco.delay, FamiliaBloco.reverb]));
    for (final familia in familias) {
      expect(blocosDaBiblioteca(catalogo, familia: familia), isNotEmpty, reason: '$familia não pode ser filtro vazio');
    }
  });
}
