// Uma ferramenta que a IA pode chamar pelo MCP. A descrição e o esquema vão
// em inglês: é o idioma em que os modelos locais acertam mais o uso de
// ferramentas. O que volta é JSON em texto, que o modelo lê de novo.
import 'dart:convert';

abstract class FerramentaMcp {
  const FerramentaMcp();

  String get nome;
  String get descricao;

  /// JSON Schema dos argumentos (sempre um objeto).
  Map<String, dynamic> get esquema;

  Future<ResultadoFerramenta> executar(Map<String, dynamic> argumentos);

  Map<String, dynamic> paraLista() => {'name': nome, 'description': descricao, 'inputSchema': esquema};
}

/// Erro de uso que a IA consegue corrigir sozinha (bloco vazio, valor fora
/// da faixa): volta como resultado com `isError`, não como erro de protocolo.
class RecusaFerramenta implements Exception {
  const RecusaFerramenta(this.mensagem);
  final String mensagem;

  @override
  String toString() => mensagem;
}

class ResultadoFerramenta {
  const ResultadoFerramenta._(this.texto, {required this.erro});

  factory ResultadoFerramenta.dados(Object? dados) => ResultadoFerramenta._(jsonEncode(dados), erro: false);

  factory ResultadoFerramenta.recusa(String mensagem) => ResultadoFerramenta._(mensagem, erro: true);

  final String texto;
  final bool erro;

  Map<String, dynamic> paraJson() => {
        'content': [
          {'type': 'text', 'text': texto},
        ],
        'isError': erro,
      };
}

/// Esquema de objeto com as propriedades dadas; [obrigatorias] em ordem.
Map<String, dynamic> esquemaObjeto(Map<String, Map<String, dynamic>> propriedades,
        {List<String> obrigatorias = const []}) =>
    {
      'type': 'object',
      'properties': propriedades,
      if (obrigatorias.isNotEmpty) 'required': obrigatorias,
      'additionalProperties': false,
    };

Map<String, dynamic> inteiro(String descricao, {int? minimo, int? maximo}) => {
      'type': 'integer',
      'description': descricao,
      'minimum': ?minimo,
      'maximum': ?maximo,
    };

Map<String, dynamic> texto(String descricao) => {'type': 'string', 'description': descricao};

/// Leitura dos argumentos com a mensagem de erro que a IA entende.
extension ArgumentosMcp on Map<String, dynamic> {
  int inteiroObrigatorio(String chave) {
    final valor = this[chave];
    if (valor is num && valor == valor.roundToDouble()) return valor.toInt();
    if (valor is String && int.tryParse(valor) != null) return int.parse(valor);
    throw RecusaFerramenta('"$chave" must be an integer.');
  }

  String textoObrigatorio(String chave) {
    final valor = this[chave];
    if (valor is String && valor.trim().isNotEmpty) return valor.trim();
    throw RecusaFerramenta('"$chave" must be a non-empty string.');
  }

  String? textoOpcional(String chave) {
    final valor = this[chave];
    return valor is String && valor.trim().isNotEmpty ? valor.trim() : null;
  }
}
