// A derivação desenhada na cadeia segue a pedaleira: o Split manda o sinal
// para o COMEÇO da linha 2 (a primeira casa ocupada dela, qualquer que seja a
// coluna do Split) e o fim da linha 2 volta no Merge. Antes ela descia em 45°
// a partir do Split e apontava para a casa seguinte, não para a linha 2.
import 'package:anagram_app/apresentacao/componentes/pintor_linha_sinal.dart';
import 'package:flutter_test/flutter_test.dart';

const _geo = GeometriaGrade(larguraCasa: 80, vao: 4, alturaLinha: 120, centroArte: 40);

bool _passaPor(List<Offset> pontos, double x, double y) => pontos.any((p) => (p.dx - x).abs() < 0.01 && (p.dy - y).abs() < 0.01);

void main() {
  final y1 = _geo.yDaLinha(1);
  final y2 = _geo.yDaLinha(2);

  test('should_reach_the_first_row_two_block_when_it_is_left_of_the_split', () {
    // como o exemplo real 1: split na casa 3, linha 2 nas casas 1 e 2, merge na 6
    final pontos = pontosDaDerivacao(_geo, casaSplit: 3, casaMerge: 6, ocupadas2: [1, 2], saida: 1000);

    expect(pontos.first, Offset(_geo.xDaCasa(3), y1), reason: 'sai do Split');
    expect(_passaPor(pontos, _geo.xDaCasa(1) - 40 - 2, y2), isTrue, reason: 'entra na linha 2 antes da casa 1');
    expect(_passaPor(pontos, _geo.xDaCasa(2), y2), isTrue, reason: 'passa pelo último bloco da linha 2');
    expect(pontos.last, Offset(_geo.xDaCasa(6), y1), reason: 'volta no Merge');
    expect(pontos.where((p) => p.dy == y2).every((p) => p.dx <= _geo.xDaCasa(2) + 42.01), isTrue,
        reason: 'na linha 2 o fio não passa do último bloco dela');
  });

  test('should_come_back_to_the_merge_when_the_row_two_blocks_are_after_it', () {
    final pontos = pontosDaDerivacao(_geo, casaSplit: 2, casaMerge: 4, ocupadas2: [6, 7], saida: 1000);

    expect(_passaPor(pontos, _geo.xDaCasa(7), y2), isTrue);
    expect(pontos.last, Offset(_geo.xDaCasa(4), y1));
  });

  test('should_go_straight_from_split_to_merge_between_the_rows_when_row_two_is_empty', () {
    final pontos = pontosDaDerivacao(_geo, casaSplit: 2, casaMerge: 5, ocupadas2: const [], saida: 1000);

    expect(pontos.any((p) => p.dy == y2), isFalse, reason: 'sem bloco na linha 2 o fio não desce até ela');
    expect(pontos.last, Offset(_geo.xDaCasa(5), y1));
  });

  test('should_place_row_two_one_row_height_plus_the_row_gap_below_row_one', () {
    expect(y2 - y1, _geo.alturaLinha + _geo.vaoEntreLinhas, reason: 'a grade separa as linhas por esse vão');
  });
}
