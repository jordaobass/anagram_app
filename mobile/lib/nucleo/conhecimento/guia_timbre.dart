// O guia de construção de timbre por tópico (ordem da cadeia, gain
// staging, linha paralela, EQ, cenas…), escrito para a IA ler pelo MCP. O
// conteúdo fica em assets/conhecimento/guia_timbre.json; os ids dos tópicos
// são fixos aqui porque viram o enum do esquema da ferramenta.
import 'dart:convert';

/// Ids dos tópicos, na ordem em que a IA costuma precisar deles. O teste
/// confere que o arquivo tem exatamente estes.
abstract final class TopicosTimbre {
  static const workflow = 'workflow';
  static const chainOrder = 'chain_order';
  static const gainStaging = 'gain_staging';
  static const parallel = 'parallel';
  static const eq = 'eq';
  static const compression = 'compression';
  static const drive = 'drive';
  static const cabinets = 'cabinets';
  static const scenes = 'scenes';
  static const timeAndModulation = 'time_and_modulation';

  static const todos = [
    workflow,
    chainOrder,
    gainStaging,
    parallel,
    eq,
    compression,
    drive,
    cabinets,
    scenes,
    timeAndModulation,
  ];
}

class TopicoTimbre {
  const TopicoTimbre({required this.id, required this.titulo, required this.resumo, required this.pontos});

  factory TopicoTimbre.doJson(Map<String, dynamic> json) => TopicoTimbre(
        id: json['id'] as String,
        titulo: json['title'] as String,
        resumo: json['summary'] as String,
        pontos: [for (final p in json['points'] as List<dynamic>) p as String],
      );

  final String id;
  final String titulo;

  /// Uma frase: é o que a lista de tópicos mostra.
  final String resumo;
  final List<String> pontos;
}

class GuiaTimbre {
  GuiaTimbre(this.topicos) : _porId = {for (final t in topicos) t.id: t};

  factory GuiaTimbre.doTexto(String texto) => GuiaTimbre.doJson(jsonDecode(texto) as Map<String, dynamic>);

  factory GuiaTimbre.doJson(Map<String, dynamic> json) =>
      GuiaTimbre([for (final t in json['topics'] as List<dynamic>) TopicoTimbre.doJson(t as Map<String, dynamic>)]);

  static final vazio = GuiaTimbre(const []);

  final List<TopicoTimbre> topicos;
  final Map<String, TopicoTimbre> _porId;

  TopicoTimbre? topico(String id) => _porId[id];
}
