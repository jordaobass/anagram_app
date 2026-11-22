// Bloco fora do catálogo: a faixa é estimada a partir do valor guardado e
// nunca pode cortar esse valor nem fazer o primeiro movimento saltar (RV3).
import 'package:anagram_app/apresentacao/componentes/painel_parametros.dart';
import 'package:anagram_app/apresentacao/componentes/passo_controle.dart';
import 'package:anagram_app/nucleo/catalogo/definicao_bloco.dart';
import 'package:anagram_app/nucleo/catalogo/escala_parametro.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:flutter_test/flutter_test.dart';

const _desconhecido = DefinicaoBloco(uri: 'urn:marketplace:x', nome: 'X', abreviacao: 'X', categoria: 'Outros', parametros: []);

DefinicaoParametro _estimado(num valor) => parametrosVisiveis(
      _desconhecido,
      BlocoPreset(const PosicaoBloco(1, 1), {
        'uri': _desconhecido.uri,
        'parameters': {
          '0': {'symbol': 'Level', 'value': valor},
        },
      }),
    ).single;

/// O valor depois de um passo fino do knob a partir do valor guardado.
num _umPasso(DefinicaoParametro p, num valor) => p.valorDepoisDoPasso(p.valorDe(p.fracaoDe(valor)), fracaoPassoFino);

void main() {
  test('should_keep_a_negative_value_and_move_a_little_when_the_block_is_not_in_the_catalog', () {
    final level = _estimado(-6);

    expect(level.limitar(-6), -6, reason: '−6 dB fica −6 até mexer');
    expect(level.valorDe(level.fracaoDe(-6)), closeTo(-6, 1e-9));
    expect(_umPasso(level, -6), allOf(greaterThan(-6), lessThan(-5)), reason: 'um passo muda pouco');
  });
}
