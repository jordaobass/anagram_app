// Texto de um valor de parâmetro com a unidade real do bloco.
// "1dPt" no catálogo significa "uma casa decimal, sem unidade" (escala 0–10).
import 'definicao_bloco.dart';

abstract final class FormatadorValor {
  static String formatar(DefinicaoParametro parametro, num valor) {
    if (parametro.opcoes.isNotEmpty) return _opcao(parametro, valor);
    if (parametro.alternavel) return DefinicaoParametro.estaLigado(valor) ? 'Ligado' : 'Desligado';
    return switch (parametro.unidade) {
      'dB' => '${_decimal(valor, 1)} dB',
      'Hz' => _hertz(valor),
      '%' => '${_decimal(valor, 0)} %',
      'ms' => '${_decimal(valor, 0)} ms',
      'ct' => '${_decimal(valor, 0)} ct',
      _ => parametro.inteiro ? '${valor.round()}' : _decimal(valor, 1),
    };
  }

  static String _opcao(DefinicaoParametro parametro, num valor) =>
      parametro.opcoes[parametro.indiceOpcao(valor)];

  static String _hertz(num valor) =>
      valor >= 1000 ? '${_decimal(valor / 1000, 2)} kHz' : '${_decimal(valor, valor < 10 ? 2 : 0)} Hz';

  /// Vírgula decimal, como se escreve no Brasil.
  static String _decimal(num valor, int casas) {
    var texto = valor.toStringAsFixed(casas);
    if (double.parse(texto) == 0 && texto.startsWith('-')) texto = texto.substring(1);
    return texto.replaceAll('.', ',');
  }
}
