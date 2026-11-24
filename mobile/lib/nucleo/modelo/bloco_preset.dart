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
  const BlocoPreset(this.posicao, this.bruto, {this.quantidadeCenas = 3});

  final PosicaoBloco posicao;
  final Map<String, dynamic> bruto;

  /// Quantas cenas o preset tem (o bloco sozinho não sabe: a cena sem foto
  /// segue o bloco, ver [DocumentoPreset.quantidadeCenas]).
  final int quantidadeCenas;

  Iterable<int> get _todasAsCenas => [for (var cena = 1; cena <= quantidadeCenas; cena++) cena];

  // O JSON vem do aparelho ou de arquivo importado: campo com tipo inesperado
  // vale como ausente, em vez de derrubar a tela com TypeError.
  String get uri => textoOuNulo(bruto['uri']) ?? '';
  bool get habilitado => bruto['enabled'] != false;

  /// O arquivo escolhido nos blocos que carregam um (IR do gabinete, modelo
  /// neural): a pedaleira grava o caminho em `properties`, na entrada "1".
  /// Decide a foto do gabinete, como no Darkglass Suite.
  String? get arquivoDeIr {
    final propriedade = mapaOuVazio(bruto['properties'])['1'];
    final valor = propriedade is Map<String, dynamic> ? textoOuNulo(propriedade['value']) : null;
    return valor == null || valor.isEmpty ? null : valor;
  }

  Map<String, dynamic> get _parametros => mapaOuVazio(bruto['parameters']);
  Map<String, dynamic> get _cenas => mapaOuVazio(bruto['scenes']);

  /// Habilitado na cena (a partir de 1). Sem registro da cena, vale o do bloco.
  bool habilitadoNaCena(int cena) {
    final registro = _cenas['$cena'];
    if (registro is Map<String, dynamic> && registro['enabled'] is bool) {
      return registro['enabled'] as bool;
    }
    return habilitado;
  }

  /// O liga/desliga desta cena difere de outra cena do preset (o bloco em si
  /// sempre acompanha a cena ativa, então a comparação é entre as cenas).
  bool bypassSoNaCena(int cena) =>
      _todasAsCenas.any((outra) => outra != cena && habilitadoNaCena(outra) != habilitadoNaCena(cena));

  /// O valor desta cena difere do de outra cena (selo "SÓ NA CENA"): editar
  /// só na cena ativa grava o parâmetro em todas, e o selo só aparece onde o
  /// som de fato muda de uma cena para outra.
  bool valorSoNaCena(String simbolo, int cena) =>
      sobreposicaoDaCena(simbolo, cena) != null &&
      _todasAsCenas.any((outra) => outra != cena && valorNaCena(simbolo, outra) != valorNaCena(simbolo, cena));

  /// Valor que soa na cena: a sobreposição da cena, senão o valor base.
  /// `null` quando o preset não guarda o parâmetro (vale o padrão do bloco).
  num? valorNaCena(String simbolo, int cena) =>
      sobreposicaoDaCena(simbolo, cena) ?? valorBase(simbolo);

  num? valorBase(String simbolo) {
    for (final entrada in _parametros.values) {
      if (entrada is Map<String, dynamic> && entrada['symbol'] == simbolo) {
        return numeroOuNulo(entrada['value']);
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
        return numeroOuNulo(item['value']);
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
