// Linha paralela: a pedaleira grava Split e Merge na linha 1 (exemplos reais
// 1 e 2: split na casa 5 ou 6, merge depois); a linha 2 é uma cadeia própria
// que sai do Split e volta no Merge.
import 'package:anagram_app/nucleo/catalogo/linha_paralela.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:anagram_app/nucleo/modelo/documento_preset.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';

String? _uriEm(DocumentoPreset d, int linha, int casa) => d.bloco(PosicaoBloco(linha, casa))?.uri;

void main() {
  final catalogo = lerCatalogo();

  test('should_put_split_and_merge_after_the_last_block_of_row_one_when_nothing_is_chosen', () {
    // exemplo 41: linha 1 com blocos nas casas 1 a 5 e sem linha paralela
    final antes = DocumentoPreset.doJson(lerExemplo('41'));
    expect(temLinhaParalela(antes), isFalse);

    final depois = comLinhaParalela(antes, catalogo)!;

    expect(_uriEm(depois, 1, 6), 'urn:darkglass-anagram:split');
    expect(_uriEm(depois, 1, 7), 'urn:darkglass-anagram:merge');
    expect(temLinhaParalela(depois), isTrue);
  });

  test('should_write_split_and_merge_in_the_same_shape_the_pedal_saves', () {
    final depois = comLinhaParalela(DocumentoPreset.doJson(lerExemplo('41')), catalogo)!;
    final real = (lerExemplo('1')['preset']['chains']['1']['blocks'] as Map<String, dynamic>)['5'] as Map<String, dynamic>;

    final split = depois.bloco(const PosicaoBloco(1, 6))!.bruto;
    expect(split.keys.toSet().containsAll(real.keys), isTrue, reason: 'mesmas chaves do split gravado pela pedaleira');
    expect(split['quickpot'], real['quickpot']);
    final simbolos = (split['parameters'] as Map<String, dynamic>).values.map((p) => (p as Map<String, dynamic>)['symbol']);
    expect(simbolos, ['LevelRow1', 'LevelRow2', 'Crossover', 'CrossoverFreq']);
  });

  test('should_split_right_after_the_chosen_block_when_the_next_slots_are_free', () {
    // exemplo 2: linha 1 nas casas 2, 4, 6–9 (com split/merge); sem eles, a 3 e a 5 ficam livres depois do 2
    final semParalela = semLinhaParalela(DocumentoPreset.doJson(lerExemplo('2')));

    final depois = comLinhaParalela(semParalela, catalogo, depoisDe: 2)!;

    expect(_uriEm(depois, 1, 3), 'urn:darkglass-anagram:split');
    expect(_uriEm(depois, 1, 5), 'urn:darkglass-anagram:merge');
  });

  test('should_remove_split_merge_and_the_row_two_blocks_when_the_parallel_row_is_removed', () {
    final antes = DocumentoPreset.doJson(lerExemplo('1'));
    expect(antes.blocosDaLinha(2), isNotEmpty);

    final depois = semLinhaParalela(antes);

    expect(temLinhaParalela(depois), isFalse);
    expect(depois.blocosDaLinha(1).map((b) => b.uri), isNot(contains('urn:darkglass-anagram:merge')));
    expect(depois.blocosDaLinha(2), isEmpty);
  });

  test('should_refuse_when_row_one_has_no_two_free_slots_for_split_and_merge', () {
    var cheia = DocumentoPreset.doJson(lerExemplo('41'));
    for (var casa = 6; casa <= PosicaoBloco.casasPorLinha; casa++) {
      cheia = cheia.comBlocoColado(PosicaoBloco(1, casa), cheia.bloco(const PosicaoBloco(1, 1))!.bruto);
    }

    expect(comLinhaParalela(cheia, catalogo), isNull);
  });
}
