// A derivação desenhada na cadeia segue a pedaleira: o Split liga sempre na
// casa 1 da linha 2 e o Merge recebe sempre da casa 12, qualquer que seja a
// coluna dos dois e onde estejam os blocos da linha 2. Antes o fio ia até o
// primeiro e voltava do último BLOCO da linha 2, o que o dono da pedaleira
// apontou como errado.
import 'package:anagram_app/apresentacao/componentes/pintor_linha_sinal.dart';
import 'package:flutter_test/flutter_test.dart';

const _geo = GeometriaGrade(larguraCasa: 80, vao: 4, alturaLinha: 120, centroArte: 40);

void main() {
  final y1 = _geo.yDaLinha(1);
  final y2 = _geo.yDaLinha(2);
  final corredor = _geo.yCorredor;

  test('should_connect_the_split_to_row_two_slot_one_and_row_two_slot_twelve_to_the_merge', () {
    final (ida, volta) = trechosDaDerivacao(_geo, casaSplit: 5, casaMerge: 9, saida: 1000);

    expect(ida.first, Offset(_geo.xDaCasa(5), y1), reason: 'o amarelo sai do Split');
    expect(ida.last, Offset(_geo.vaoAntes(1), y2), reason: 'e entra na linha 2 pela casa 1');
    expect(volta.first, Offset(_geo.vaoDepois(12), y2), reason: 'o verde-água sai depois da casa 12');
    expect(volta.last, Offset(_geo.xDaCasa(9), y1), reason: 'e chega ao Merge');
  });

  test('should_keep_the_way_out_and_the_way_back_apart_in_the_corridor', () {
    final (ida, volta) = trechosDaDerivacao(_geo, casaSplit: 3, casaMerge: 6, saida: 1000);

    final idaNoCorredor = ida.where((p) => p.dy == corredor).map((p) => p.dx);
    final voltaNoCorredor = volta.where((p) => p.dy == corredor).map((p) => p.dx);
    expect(idaNoCorredor.reduce((a, b) => a > b ? a : b),
        lessThanOrEqualTo(voltaNoCorredor.reduce((a, b) => a < b ? a : b)),
        reason: 'a ida corre à esquerda do Split e a volta à direita do Merge');
  });

  test('should_use_separate_verticals_when_the_merge_is_right_after_the_split', () {
    final (ida, volta) = trechosDaDerivacao(_geo, casaSplit: 6, casaMerge: 7, saida: 1000);

    final descida = ida[1].dx;
    final subida = volta[volta.length - 2].dx;
    expect(subida, greaterThan(descida), reason: 'no mesmo vão, a volta sobe à direita da descida da ida');
  });

  test('should_return_to_the_out_jack_when_there_is_no_merge', () {
    final (_, volta) = trechosDaDerivacao(_geo, casaSplit: 2, saida: 1000);

    expect(volta.last, Offset(1000, y1));
  });

  test('should_place_row_two_one_row_height_plus_the_row_gap_below_row_one', () {
    expect(y2 - y1, _geo.alturaLinha + _geo.vaoEntreLinhas, reason: 'a grade separa as linhas por esse vão');
  });
}
