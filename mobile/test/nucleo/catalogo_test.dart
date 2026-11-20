import 'package:anagram_app/nucleo/catalogo/familia_bloco.dart';
import 'package:anagram_app/nucleo/catalogo/formatador_valor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';

void main() {
  test('should_read_real_ranges_units_and_options_when_loading_the_factory_catalog', () {
    final catalogo = lerCatalogo();
    expect(catalogo.quantidade, 99);

    final supressor = catalogo.definicao('urn:darkglass:Suppressor');
    final limiar = supressor.parametro('Threshold')!;
    expect([limiar.minimo, limiar.maximo, limiar.unidade], [-80, 0, 'dB']);
    expect(FormatadorValor.formatar(limiar, -43.900001525878906), '-43,9 dB');
    expect(FormatadorValor.formatar(supressor.parametro('Amount')!, 6), 'More');
    final razao = catalogo.definicao('urn:darkglass:CompLim').parametro('Ratio')!;
    expect(FormatadorValor.formatar(razao, 8), '8:1', reason: 'opção pelo valor do rótulo');
    expect(supressor.familia, FamiliaBloco.compressor);
    expect(catalogo.definicao('urn:darkglass-anagram:cabinet-bass').familia, FamiliaBloco.gabinete);
    expect(catalogo.definicao('urn:marketplace:desconhecido').nome, 'desconhecido');
  });
}
