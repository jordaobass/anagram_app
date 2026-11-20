// Texto de um valor de parâmetro com a unidade real do bloco.
// "1dPt" no catálogo significa "uma casa decimal, sem unidade" (escala 0–10).
import 'definicao_bloco.dart';

abstract final class FormatadorValor {
  /// A tela passa o separador decimal e as palavras de liga/desliga do
  /// idioma em uso; o padrão é o português (vírgula decimal).
  static String formatar(DefinicaoParametro parametro, num valor,
      {String separadorDecimal = ',', String ligado = 'Ligado', String desligado = 'Desligado'}) {
    if (parametro.opcoes.isNotEmpty) return _opcao(parametro, valor);
    if (parametro.alternavel) return DefinicaoParametro.estaLigado(valor) ? ligado : desligado;
    final sep = separadorDecimal;
    return switch (parametro.unidade) {
      'dB' => '${_decimal(valor, 1, sep)} dB',
      'Hz' => _hertz(valor, sep),
      '%' => '${_decimal(valor, 0, sep)} %',
      'ms' => '${_decimal(valor, 0, sep)} ms',
      'ct' => '${_decimal(valor, 0, sep)} ct',
      _ => parametro.inteiro ? '${valor.round()}' : _decimal(valor, 1, sep),
    };
  }

  static String _opcao(DefinicaoParametro parametro, num valor) =>
      parametro.opcoes[parametro.indiceOpcao(valor)];

  static String _hertz(num valor, String sep) =>
      valor >= 1000 ? '${_decimal(valor / 1000, 2, sep)} kHz' : '${_decimal(valor, valor < 10 ? 2 : 0, sep)} Hz';

  static String _decimal(num valor, int casas, String separador) {
    var texto = valor.toStringAsFixed(casas);
    if (double.parse(texto) == 0 && texto.startsWith('-')) texto = texto.substring(1);
    return texto.replaceAll('.', separador);
  }
}

