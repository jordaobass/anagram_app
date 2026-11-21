// Linha paralela: Split e Merge são blocos comuns, postos um de cada vez
// (DECISOES M11). A pedaleira grava os dois na linha 1 (exemplos reais 1 e 2:
// split na casa 5 ou 6, merge depois); a linha 2 é uma cadeia própria.
import 'package:anagram_app/nucleo/catalogo/biblioteca_blocos.dart';
import 'package:anagram_app/nucleo/catalogo/linha_paralela.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:anagram_app/nucleo/modelo/documento_preset.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';

void main() {
  final catalogo = lerCatalogo();
  // exemplo 41: linha 1 nas casas 1 a 5, sem linha paralela
  final semParalela = DocumentoPreset.doJson(lerExemplo('41'));
  // exemplo 1: Split na casa 5, Merge na 11, linha 2 com blocos
  final comParalela = DocumentoPreset.doJson(lerExemplo('1'));

  test('should_accept_a_split_on_row_one_and_refuse_it_on_row_two_or_when_there_is_one_already', () {
    expect(recusaAoAdicionar(semParalela, const PosicaoBloco(1, 6), uriSplit), isNull);
    expect(recusaAoAdicionar(semParalela, const PosicaoBloco(2, 6), uriSplit), RecusaAdicionar.foraDaLinha1);
    expect(recusaAoAdicionar(comParalela, const PosicaoBloco(1, 12), uriSplit), RecusaAdicionar.splitRepetido);
  });

  test('should_accept_a_merge_only_after_the_split_and_only_once', () {
    final soSplit = semParalela.comBlocoColado(const PosicaoBloco(1, 7), blocoNovo(catalogo.definicao(uriSplit)));

    expect(recusaAoAdicionar(semParalela, const PosicaoBloco(1, 8), uriMerge), RecusaAdicionar.mergeSemSplit);
    expect(recusaAoAdicionar(soSplit, const PosicaoBloco(1, 6), uriMerge), RecusaAdicionar.mergeAntesDoSplit);
    expect(recusaAoAdicionar(soSplit, const PosicaoBloco(1, 9), uriMerge), isNull);
    expect(recusaAoAdicionar(comParalela, const PosicaoBloco(1, 12), uriMerge), RecusaAdicionar.mergeRepetido);
  });

  test('should_refuse_a_split_after_an_existing_merge', () {
    final soMerge = comParalela.semBloco(const PosicaoBloco(1, 5));

    expect(recusaAoAdicionar(soMerge, const PosicaoBloco(1, 12), uriSplit), RecusaAdicionar.splitDepoisDoMerge);
    expect(recusaAoAdicionar(soMerge, const PosicaoBloco(1, 5), uriSplit), isNull);
  });

  test('should_write_the_split_in_the_same_shape_the_pedal_saves', () {
    final split = blocoNovo(catalogo.definicao(uriSplit));
    final real = (lerExemplo('1')['preset']['chains']['1']['blocks'] as Map<String, dynamic>)['5'] as Map<String, dynamic>;

    expect(split.keys.toSet().containsAll(real.keys), isTrue, reason: 'mesmas chaves do split gravado pela pedaleira');
    expect(split['quickpot'], real['quickpot']);
    final simbolos = (split['parameters'] as Map<String, dynamic>).values.map((p) => (p as Map<String, dynamic>)['symbol']);
    expect(simbolos, ['LevelRow1', 'LevelRow2', 'Crossover', 'CrossoverFreq']);
  });

  test('should_take_the_merge_and_the_row_two_blocks_along_when_the_split_is_removed', () {
    expect(comParalela.blocosDaLinha(2), isNotEmpty);

    final depois = semSplit(comParalela);

    expect(temLinhaParalela(depois), isFalse);
    expect(depois.blocosDaLinha(1).map((b) => b.uri), isNot(contains(uriMerge)));
    expect(depois.blocosDaLinha(2), isEmpty);
  });
}
