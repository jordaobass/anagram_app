// Metadados de bloco lidos de blocks-factory.json (get_plugin_info do
// firmware v1.18.1.23): nome, categoria e faixas reais dos parâmetros.
import 'familia_bloco.dart';

class DefinicaoParametro {
  const DefinicaoParametro({
    required this.simbolo,
    required this.nome,
    required this.minimo,
    required this.maximo,
    required this.padrao,
    this.unidade,
    this.alternavel = false,
    this.inteiro = false,
    this.logaritmico = false,
    this.opcoes = const [],
    this.papel,
  });

  factory DefinicaoParametro.doJson(Map<String, dynamic> json) => DefinicaoParametro(
        simbolo: json['symbol'] as String,
        nome: json['name'] as String? ?? json['symbol'] as String,
        minimo: (json['min'] as num?) ?? 0,
        maximo: (json['max'] as num?) ?? 1,
        padrao: (json['def'] as num?) ?? 0,
        unidade: json['unit'] as String?,
        alternavel: json['toggle'] == true,
        inteiro: json['integer'] == true,
        logaritmico: json['log'] == true,
        opcoes: [for (final o in (json['options'] as List<dynamic>? ?? const [])) '$o'],
        papel: json['role'] as String?,
      );

  final String simbolo;
  final String nome;
  final num minimo;
  final num maximo;
  final num padrao;
  final String? unidade;
  final bool alternavel;
  final bool inteiro;
  final bool logaritmico;
  final List<String> opcoes;
  final String? papel;

  bool get ehDiscreto => alternavel || inteiro || opcoes.isNotEmpty;

  /// Valor gravado de cada opção. O catálogo só dá min/max: quando os
  /// rótulos são números dentro da faixa ("2:1" … "100:1"), eles são o
  /// valor; senão as opções andam de 1 em 1 ou se espalham de min a max.
  List<num> get valoresOpcoes {
    if (opcoes.length < 2) return [minimo];
    final numeros = [for (final o in opcoes) num.tryParse(RegExp(r'^-?[\d.]+').stringMatch(o) ?? '')];
    final todos = numeros.whereType<num>().toList();
    if (todos.length == opcoes.length && todos.first == minimo && todos.last == maximo) return todos;
    if (maximo - minimo == opcoes.length - 1) return [for (var i = 0; i < opcoes.length; i++) minimo + i];
    return [for (var i = 0; i < opcoes.length; i++) minimo + (maximo - minimo) * i / (opcoes.length - 1)];
  }

  /// Índice da opção cujo valor é o mais próximo.
  int indiceOpcao(num valor) {
    final valores = valoresOpcoes;
    var melhor = 0;
    for (var i = 1; i < valores.length; i++) {
      if ((valores[i] - valor).abs() < (valores[melhor] - valor).abs()) melhor = i;
    }
    return melhor;
  }

  num valorDaOpcao(int indice) => valoresOpcoes[indice.clamp(0, valoresOpcoes.length - 1)];

  num limitar(num valor) {
    final limitado = valor.clamp(minimo, maximo);
    if (opcoes.isNotEmpty) return valorDaOpcao(indiceOpcao(limitado));
    return alternavel || inteiro ? limitado.round() : limitado;
  }
}

class DefinicaoBloco {
  const DefinicaoBloco({
    required this.uri,
    required this.nome,
    required this.abreviacao,
    required this.categoria,
    required this.parametros,
  });

  factory DefinicaoBloco.doJson(String uri, Map<String, dynamic> json) => DefinicaoBloco(
        uri: uri,
        nome: json['name'] as String? ?? uri,
        abreviacao: json['abbr'] as String? ?? '',
        categoria: json['category'] as String? ?? '',
        parametros: [
          for (final p in (json['params'] as List<dynamic>? ?? const []))
            DefinicaoParametro.doJson(p as Map<String, dynamic>),
        ],
      );

  /// Bloco que não está no catálogo (comprado no Marketplace, firmware novo):
  /// mostra o fim da uri e os parâmetros que o preset guardar.
  factory DefinicaoBloco.desconhecido(String uri) {
    final fim = uri.split(RegExp('[:/#]')).lastWhere((p) => p.isNotEmpty, orElse: () => uri);
    return DefinicaoBloco(uri: uri, nome: fim, abreviacao: '', categoria: '', parametros: const []);
  }

  final String uri;
  final String nome;
  final String abreviacao;
  final String categoria;
  final List<DefinicaoParametro> parametros;

  FamiliaBloco get familia => FamiliaBloco.de(uri: uri, nome: nome, categoria: categoria);

  DefinicaoParametro? parametro(String simbolo) {
    for (final p in parametros) {
      if (p.simbolo == simbolo) return p;
    }
    return null;
  }
}
