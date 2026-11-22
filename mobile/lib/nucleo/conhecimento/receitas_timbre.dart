// Receitas de timbre: por estilo (rock, slap, reggae…) e por baixista de
// referência, sempre como PONTO DE PARTIDA em termos dos blocos que existem
// na Anagram. Cada passo da cadeia já vem com linha, coluna e valores, na
// ordem em que `add_block` aceita (Split antes do Merge, linha 2 depois).
// Conteúdo em assets/conhecimento/receitas.json; o teste cruza cada tipo e
// cada símbolo com o catálogo, para receita inválida não chegar à IA.
import 'dart:convert';

class PassoReceita {
  const PassoReceita({
    required this.linha,
    required this.casa,
    required this.uri,
    this.ajustes = const {},
    this.nota,
  });

  factory PassoReceita.doJson(Map<String, dynamic> json) => PassoReceita(
        linha: json['row'] as int,
        casa: json['column'] as int,
        uri: json['type'] as String,
        ajustes: {for (final e in ((json['settings'] as Map<String, dynamic>?) ?? const {}).entries) e.key: e.value as Object},
        nota: json['note'] as String?,
      );

  final int linha;
  final int casa;
  final String uri;

  /// símbolo → valor (número ou rótulo de opção), como `set_parameter` aceita.
  final Map<String, Object> ajustes;
  final String? nota;
}

class ReceitaTimbre {
  const ReceitaTimbre({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.apelidos,
    required this.ideia,
    required this.confianca,
    required this.cadeia,
    required this.perguntar,
    this.cenas = const [],
    this.observacoes = const [],
  });

  factory ReceitaTimbre.doJson(Map<String, dynamic> json) => ReceitaTimbre(
        id: json['id'] as String,
        nome: json['name'] as String,
        tipo: json['kind'] as String,
        apelidos: _lista(json['aliases']),
        ideia: json['idea'] as String,
        confianca: json['confidence'] as String,
        cadeia: [for (final p in json['chain'] as List<dynamic>) PassoReceita.doJson(p as Map<String, dynamic>)],
        perguntar: _lista(json['ask']),
        cenas: _lista(json['scenes']),
        observacoes: _lista(json['notes']),
      );

  static List<String> _lista(Object? json) => [for (final item in (json as List<dynamic>?) ?? const []) item as String];

  final String id;
  final String nome;

  /// "style" ou "player".
  final String tipo;

  /// Outras palavras que acham a receita ("iron maiden" acha Steve Harris).
  final List<String> apelidos;

  /// A ideia do som, em termos de frequência, dinâmica e saturação.
  final String ideia;

  /// Quanto se pode confiar: ponto de partida, equipamento incerto etc.
  final String confianca;
  final List<PassoReceita> cadeia;

  /// O que a IA deve perguntar ao músico antes ou depois de aplicar.
  final List<String> perguntar;
  final List<String> cenas;
  final List<String> observacoes;

  /// Palavras pelas quais a busca casa: id, nome e apelidos, normalizados.
  Iterable<String> get termos => [id.replaceAll('_', ' '), nome, ...apelidos].map(normalizarBusca);
}

/// Minúsculas, sem acento nem pontuação, espaços únicos.
String normalizarBusca(String texto) {
  const acentos = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
  const simples = 'aaaaaeeeeiiiiooooouuuucn';
  final buffer = StringBuffer();
  for (final letra in texto.toLowerCase().split('')) {
    final i = acentos.indexOf(letra);
    buffer.write(i >= 0 ? simples[i] : letra);
  }
  return buffer.toString().replaceAll(RegExp(r'[^a-z0-9 ]+'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
}

class ReceitasTimbre {
  ReceitasTimbre(this.receitas) : _porId = {for (final r in receitas) r.id: r};

  factory ReceitasTimbre.doTexto(String texto) => ReceitasTimbre.doJson(jsonDecode(texto) as Map<String, dynamic>);

  factory ReceitasTimbre.doJson(Map<String, dynamic> json) =>
      ReceitasTimbre([for (final r in json['recipes'] as List<dynamic>) ReceitaTimbre.doJson(r as Map<String, dynamic>)]);

  static final vazio = ReceitasTimbre(const []);

  final List<ReceitaTimbre> receitas;
  final Map<String, ReceitaTimbre> _porId;

  ReceitaTimbre? porId(String id) => _porId[id];

  /// As receitas que casam com o pedido, da mais parecida à menos; vazia se
  /// nenhuma palavra bate. Casa inteiro vale mais que casar uma palavra.
  List<ReceitaTimbre> buscar(String pedido) {
    final consulta = normalizarBusca(pedido);
    if (consulta.isEmpty) return const [];
    final pontuadas = [
      for (final r in receitas)
        if (_pontuacao(r, consulta) case final pontos when pontos > 0) (pontos, r),
    ]..sort((a, b) => b.$1.compareTo(a.$1));
    return [for (final (_, r) in pontuadas) r];
  }

  static int _pontuacao(ReceitaTimbre receita, String consulta) {
    var pontos = 0;
    final palavrasDaConsulta = consulta.split(' ').where((p) => p.length >= 3).toSet();
    for (final termo in receita.termos) {
      if (termo == consulta) return 1000;
      if (consulta.contains(termo) || termo.contains(consulta)) pontos += 100 + termo.length;
      pontos += 10 * termo.split(' ').where(palavrasDaConsulta.contains).length;
    }
    return pontos;
  }
}
