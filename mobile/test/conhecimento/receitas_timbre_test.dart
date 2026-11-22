// Uma receita é uma cadeia que a IA vai montar com add_block e set_parameter:
// cada bloco tem de existir no catálogo, cada ajuste tem de ser um parâmetro
// real com valor na faixa, e as posições têm de ser as que o editor aceita
// (Split antes do Merge na linha 1, linha 2 só com Split). O guia por
// tópico tem de ter exatamente os tópicos que o esquema da ferramenta anuncia.
import 'package:anagram_app/nucleo/catalogo/linha_paralela.dart';
import 'package:anagram_app/nucleo/conhecimento/base_conhecimento.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';
import '../apoio/validacao_catalogo.dart';

void main() {
  final catalogo = lerCatalogo();
  final receitas = lerReceitas();

  test('should_only_use_blocks_and_parameters_that_exist_in_the_catalog_with_values_in_range', () {
    final problemas = <String>[];
    for (final receita in receitas.receitas) {
      for (final passo in receita.cadeia) {
        final definicao = catalogo.definicao(passo.uri);
        if (definicao.parametros.isEmpty) {
          problemas.add('${receita.id}: block "${passo.uri}" is not in the catalog');
          continue;
        }
        for (final ajuste in passo.ajustes.entries) {
          if (problemaDoAjuste(definicao, ajuste.key, ajuste.value) case final problema?) {
            problemas.add('${receita.id}: $problema');
          }
        }
      }
    }

    expect(receitas.receitas.length, greaterThanOrEqualTo(15), reason: 'estilos e baixistas de referência');
    expect(problemas, isEmpty, reason: problemas.join('\n'));
  });

  test('should_place_blocks_where_the_editor_accepts_them_split_before_merge_and_row_2_only_with_both', () {
    for (final receita in receitas.receitas) {
      final posicoes = <(int, int)>{};
      int? split;
      int? merge;
      for (final passo in receita.cadeia) {
        expect(passo.linha, inInclusiveRange(1, PosicaoBloco.linhas), reason: receita.id);
        expect(passo.casa, inInclusiveRange(1, PosicaoBloco.casasPorLinha), reason: receita.id);
        expect(posicoes.add((passo.linha, passo.casa)), isTrue, reason: '${receita.id}: duplicated position');
        if (passo.uri == uriSplit) expect(split = passo.casa, isNotNull);
        if (passo.uri == uriMerge) expect(merge = passo.casa, isNotNull);
        if (ehBlocoDeRoteamento(passo.uri)) expect(passo.linha, 1, reason: '${receita.id}: Split/Merge go on row 1');
        if (passo.linha == 2) {
          expect(split, isNotNull, reason: '${receita.id}: row 2 before the Split in the chain order');
        }
      }
      expect(receita.cadeia.where((p) => p.uri == uriSplit).length, lessThanOrEqualTo(1), reason: receita.id);
      if (split != null || merge != null) {
        expect(split, isNotNull, reason: '${receita.id}: Merge without Split');
        expect(merge, isNotNull, reason: '${receita.id}: Split without Merge');
        expect(split!, lessThan(merge!), reason: '${receita.id}: Split must come before the Merge');
      }
    }
  });

  test('should_find_a_recipe_by_style_by_player_reference_and_by_band_alias', () {
    expect(receitas.buscar('Steve Harris tone').first.id, 'steve_harris');
    expect(receitas.buscar('iron maiden').first.id, 'steve_harris');
    expect(receitas.buscar('funk slap').first.tipo, 'style');
    expect(receitas.buscar('funk slap').first.id, 'funk_slap');
    expect(receitas.buscar('modern metal').first.id, 'modern_metal');
    expect(receitas.buscar('reggae dub').first.id, 'reggae');
    expect(receitas.buscar('something nobody plays'), isEmpty);
  });

  test('should_give_every_recipe_an_idea_a_chain_questions_for_the_player_and_how_much_to_trust_it', () {
    for (final receita in receitas.receitas) {
      expect(receita.cadeia, isNotEmpty, reason: receita.id);
      expect(receita.perguntar, isNotEmpty, reason: '${receita.id}: what to ask the player');
      expect(receita.ideia.length, greaterThan(40), reason: receita.id);
      expect(receita.confianca, isNotEmpty, reason: receita.id);
      expect(['style', 'player'], contains(receita.tipo), reason: receita.id);
    }
  });

  test('should_have_exactly_the_tone_building_topics_the_tool_schema_announces', () {
    final guia = lerGuiaTimbre();

    expect([for (final t in guia.topicos) t.id], TopicosTimbre.todos);
    for (final topico in guia.topicos) {
      expect(topico.pontos.length, greaterThanOrEqualTo(3), reason: topico.id);
      expect(topico.resumo.length, greaterThan(20), reason: topico.id);
    }
  });
}
