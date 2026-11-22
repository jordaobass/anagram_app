// O que a IA precisa saber de cada bloco além do catálogo: papel no som,
// o que ele modela (atribuição da comunidade, não da Darkglass), os
// parâmetros que mais importam, um ponto de partida com base (preset de
// fábrica ou padrão do catálogo) e as armadilhas. O texto é em inglês, o
// idioma em que os modelos acertam mais (DECISOES IC2). A curadoria fica em
// assets/conhecimento/blocos.json; faixas e nomes continuam no catálogo.
import 'dart:convert';

import '../catalogo/variantes_uri.dart';

class EntradaGuiaBloco {
  const EntradaGuiaBloco({
    required this.uris,
    required this.papel,
    this.modela,
    this.parametrosChave = const {},
    this.pontoDePartida = const {},
    this.origemDoPonto,
    this.armadilhas = const [],
    this.combinaCom = const [],
  });

  factory EntradaGuiaBloco.doJson(Map<String, dynamic> json) => EntradaGuiaBloco(
        uris: [for (final u in json['uris'] as List<dynamic>) u as String],
        papel: json['role'] as String,
        modela: json['models'] as String?,
        parametrosChave: _textos(json['key_parameters']),
        pontoDePartida: {
          for (final e in ((json['starting_point'] as Map<String, dynamic>?) ?? const {}).entries) e.key: e.value as Object,
        },
        origemDoPonto: json['starting_point_source'] as String?,
        armadilhas: _lista(json['pitfalls']),
        combinaCom: _lista(json['pairs_with']),
      );

  static Map<String, String> _textos(Object? json) =>
      {for (final e in ((json as Map<String, dynamic>?) ?? const {}).entries) e.key: e.value as String};

  static List<String> _lista(Object? json) => [for (final item in (json as List<dynamic>?) ?? const []) item as String];

  /// Uris do catálogo que esta entrada descreve (mono e estéreo juntas).
  final List<String> uris;

  /// O que o bloco faz no som, em uma ou duas frases.
  final String papel;

  /// O equipamento que o bloco modela, quando se sabe; sempre com a ressalva.
  final String? modela;

  /// símbolo → dica curada (vence a explicação genérica do parâmetro).
  final Map<String, String> parametrosChave;

  /// símbolo → valor (número ou rótulo de opção) de um ponto de partida.
  final Map<String, Object> pontoDePartida;

  /// De onde veio o ponto de partida ("factory preset …", "catalog defaults").
  final String? origemDoPonto;

  final List<String> armadilhas;

  /// Uris de blocos que costumam ir junto.
  final List<String> combinaCom;
}

class GuiaBlocos {
  GuiaBlocos(this.entradas, {this.fontes = const []}) : _porUri = {for (final e in entradas) for (final u in e.uris) u: e};

  factory GuiaBlocos.doTexto(String texto) => GuiaBlocos.doJson(jsonDecode(texto) as Map<String, dynamic>);

  factory GuiaBlocos.doJson(Map<String, dynamic> json) => GuiaBlocos(
        [for (final b in json['blocks'] as List<dynamic>) EntradaGuiaBloco.doJson(b as Map<String, dynamic>)],
        fontes: [for (final f in (json['sources'] as List<dynamic>?) ?? const []) f as String],
      );

  static final vazio = GuiaBlocos(const []);

  final List<EntradaGuiaBloco> entradas;
  final List<String> fontes;
  final Map<String, EntradaGuiaBloco> _porUri;

  /// A entrada da uri, aceitando o sufixo de canal que a pedaleira varia.
  EntradaGuiaBloco? de(String uri) => buscarPorVariantes(_porUri, uri);

  bool cobre(String uri) => de(uri) != null;
}
