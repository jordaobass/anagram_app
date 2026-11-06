// Leitura de um bloco dentro do preset. Só leitura: alterações passam pelo
// [DocumentoPreset], que copia o JSON antes de mudar.
import 'json_util.dart';

class PosicaoBloco {
  const PosicaoBloco(this.linha, this.casa);

  static const int linhas = 2;
  static const int casasPorLinha = 12;

  final int linha;
  final int casa;

  @override
  bool operator ==(Object other) =>
      other is PosicaoBloco && other.linha == linha && other.casa == casa;

  @override
  int get hashCode => Object.hash(linha, casa);

  @override
  String toString() => 'L$linha·$casa';
}

class BlocoPreset {
  const BlocoPreset(this.posicao, this.bruto);

  final PosicaoBloco posicao;
  final Map<String, dynamic> bruto;

  String get uri => bruto['uri'] as String? ?? '';
  bool get habilitado => bruto['enabled'] != false;

  Map<String, dynamic> get _parametros => mapaOuVazio(bruto['parameters']);
  Map<String, dynamic> get _cenas => mapaOuVazio(bruto['scenes']);

  /// Habilitado na cena (1–3). Sem registro da cena, vale o do bloco.
  bool habilitadoNaCena(int cena) {
    final registro = _cenas['$cena'];
    if (registro is Map<String, dynamic> && registro['enabled'] is bool) {
      return registro['enabled'] as bool;
    }
    return habilitado;
  }

  /// Valor que soa na cena: a sobreposição da cena, senão o valor base.
  /// `null` quando o preset não guarda o parâmetro (vale o padrão do bloco).
  /// A cena liga/desliga o bloco diferente da base (selo "SÓ NA CENA").
  bool bypassSoNaCena(int cena) => habilitadoNaCena(cena) != habilitado;

  num? valorNaCena(String simbolo, int cena) =>
      sobreposicaoDaCena(simbolo, cena) ?? valorBase(simbolo);

  num? valorBase(String simbolo) {
    for (final entrada in _parametros.values) {
      if (entrada is Map<String, dynamic> && entrada['symbol'] == simbolo) {
        return entrada['value'] as num?;
      }
    }
    return null;
  }

  num? sobreposicaoDaCena(String simbolo, int cena) {
    final registro = mapaOuVazio(_cenas['$cena']);
    final lista = registro['parameters'];
    if (lista is! List) return null;
    for (final item in lista) {
      if (item is Map<String, dynamic> && item['symbol'] == simbolo) {
        return item['value'] as num?;
      }
    }
    return null;
  }

  /// Símbolos guardados no preset, na ordem do arquivo.
  List<String> get simbolosGuardados => [
        for (final chave in chavesNumericas(_parametros))
          if (_parametros[chave] case {'symbol': final String simbolo}) simbolo,
      ];

}
