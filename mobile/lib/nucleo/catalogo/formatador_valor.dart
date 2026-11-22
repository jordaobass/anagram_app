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
    if (parametro.rotuloDoPonto(valor) case final rotulo?) return rotulo;
    final sep = separadorDecimal;
    return switch (parametro.unidade) {
      'dB' => '${_decimal(valor, 1, sep)} dB',
      'Hz' => _hertz(valor, sep),
      '%' => '${_decimal(valor, 0, sep)} %',
      'ms' => '${_decimal(valor, 0, sep)} ms',
      'ct' => '${_decimal(valor, 0, sep)} ct',
      'bpm' => '${valor.round()} bpm',
      _ => parametro.inteiro ? '${valor.round()}' : _decimal(valor, _casasSemUnidade(parametro), sep),
    };
  }

  /// A escala 0–10 dos pedais pede uma casa; largura e ressonância (0–1,4)
  /// pedem duas, senão 0,33 e 0,30 aparecem iguais.
  static int _casasSemUnidade(DefinicaoParametro parametro) =>
      parametro.maximo - parametro.minimo <= _faixaCurta ? 2 : 1;

  static const _faixaCurta = 2;

  /// "8 kHz", "2,5 kHz", "1,25 kHz": duas casas só quando fazem diferença.
  static String _quilo(num valor, String sep) {
    final texto = _decimal(valor / 1000, 2, sep);
    return texto.contains(sep) ? texto.replaceFirst(RegExp('0+\$'), '').replaceFirst(RegExp('[$sep]\$'), '') : texto;
  }

  /// O que a pessoa digitou no lugar do knob, na unidade que ela vê: aceita
  /// vírgula ou ponto, a unidade escrita junto e "k" de quilo ("1,5k" = 1500
  /// Hz). Fora da faixa vira o limite mais perto; inteiro é arredondado.
  /// Texto que não é número volta nulo.
  static num? lerDigitado(DefinicaoParametro parametro, String texto) {
    final achado = _numeroDigitado.firstMatch(texto.trim().toLowerCase());
    if (achado == null) return null;
    final numero = double.tryParse(achado.group(1)!.replaceAll(',', '.'));
    if (numero == null) return null;
    final valor = achado.group(2) == 'k' ? numero * 1000 : numero;
    final dentro = valor.clamp(parametro.minimo, parametro.maximo);
    return parametro.inteiro ? dentro.round() : dentro;
  }

  /// Número com sinal e no máximo um separador decimal, um "k" opcional e,
  /// depois, só a unidade (letras, % ou espaço): "1,2,3" não passa.
  static final _numeroDigitado = RegExp(r'^([+-]?\d+(?:[.,]\d+)?|[+-]?[.,]\d+)\s*(k)?[a-z%\s]*$');

  static String _opcao(DefinicaoParametro parametro, num valor) =>
      parametro.opcoes[parametro.indiceOpcao(valor)];

  static String _hertz(num valor, String sep) =>
      valor >= 1000 ? '${_quilo(valor, sep)} kHz' : '${_decimal(valor, valor < 10 ? 2 : 0, sep)} Hz';

  static String _decimal(num valor, int casas, String separador) {
    var texto = valor.toStringAsFixed(casas);
    if (double.parse(texto) == 0 && texto.startsWith('-')) texto = texto.substring(1);
    return texto.replaceAll('.', separador);
  }
}

