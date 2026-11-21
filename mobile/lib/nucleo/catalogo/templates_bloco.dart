// Templates de bloco: ajustes prontos para começar, como o "Select Block
// Template" da tela da pedaleira. Há dois tipos e a tela não os mistura:
// os da Darkglass (os da pedaleira, com os valores lidos de um preset em que
// o dono aplicou o template) e os do app (ajustes nossos, ditos como tais).
// O mecanismo vale para qualquer bloco: basta acrescentar dados por uri em
// assets/templates/blocos.json (DECISOES PP).
import 'dart:convert';

import 'explicacoes_parametros.dart' show TextoExplicacao;

enum OrigemTemplate { darkglass, app }

class TemplateBloco {
  const TemplateBloco({
    required this.id,
    required this.origem,
    required this.nome,
    required this.descricao,
    required this.valores,
  });

  factory TemplateBloco.doJson(Map<String, dynamic> json) => TemplateBloco(
        id: json['id'] as String,
        origem: OrigemTemplate.values.byName(json['origem'] as String),
        nome: TextoExplicacao.doJson(json['nome'] as Map<String, dynamic>),
        descricao: TextoExplicacao.doJson(json['descricao'] as Map<String, dynamic>),
        valores: switch (json['valores']) {
          final Map<String, dynamic> v => {for (final e in v.entries) e.key: e.value as num},
          _ => null,
        },
      );

  final String id;
  final OrigemTemplate origem;
  final TextoExplicacao nome;
  final TextoExplicacao descricao;

  /// Valor de cada parâmetro, pelo símbolo do catálogo. Nulo: template da
  /// pedaleira que existe (nome e descrição oficiais) mas cujos valores ainda
  /// não foram lidos de um preset — aparece, desabilitado, sem inventar valor.
  final Map<String, num>? valores;

  bool get disponivel => valores != null;

  /// O bloco está como o template: todo valor dele confere com o do bloco.
  bool aplicadoEm(num? Function(String simbolo) valorAtual) => (valores ?? const {}).isNotEmpty && valores!.entries.every((e) {
        final atual = valorAtual(e.key);
        return atual != null && (atual - e.value).abs() < _tolerancia(e.value);
      });

  /// Os valores voltam da pedaleira em float (0,3 vira 0,30000001).
  static double _tolerancia(num valor) => valor.abs() * 1e-4 + 1e-4;
}

class TemplatesBlocos {
  const TemplatesBlocos(this._porUri);

  factory TemplatesBlocos.doTexto(String texto) => TemplatesBlocos.doJson(jsonDecode(texto) as Map<String, dynamic>);

  factory TemplatesBlocos.doJson(Map<String, dynamic> json) => TemplatesBlocos({
        for (final bloco in (json['blocos'] as List).cast<Map<String, dynamic>>())
          bloco['uri'] as String: [
            for (final t in (bloco['templates'] as List).cast<Map<String, dynamic>>()) TemplateBloco.doJson(t),
          ],
      });

  static const vazio = TemplatesBlocos({});

  final Map<String, List<TemplateBloco>> _porUri;

  Iterable<String> get uris => _porUri.keys;

  /// Os da Darkglass primeiro (os da pedaleira), depois os do app. A variante
  /// estéreo (`uri#stereo`) usa os do bloco.
  List<TemplateBloco> de(String uri) {
    final lista = _porUri[uri.split('#').first] ?? const [];
    return [
      for (final origem in OrigemTemplate.values) ...lista.where((t) => t.origem == origem),
    ];
  }
}
