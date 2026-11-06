// Catálogo de blocos de fábrica, carregado do JSON de referência.
import 'dart:convert';

import 'definicao_bloco.dart';

class CatalogoBlocos {
  CatalogoBlocos(Map<String, DefinicaoBloco> blocos, {this.firmware = ''})
      : _blocos = Map.unmodifiable(blocos);

  factory CatalogoBlocos.doTexto(String texto) {
    final json = jsonDecode(texto) as Map<String, dynamic>;
    final blocos = json['blocks'] as Map<String, dynamic>;
    return CatalogoBlocos(
      {
        for (final entrada in blocos.entries)
          entrada.key: DefinicaoBloco.doJson(entrada.key, entrada.value as Map<String, dynamic>),
      },
      firmware: json['firmware'] as String? ?? '',
    );
  }

  final Map<String, DefinicaoBloco> _blocos;
  final String firmware;

  int get quantidade => _blocos.length;
  Iterable<DefinicaoBloco> get todos => _blocos.values;

  DefinicaoBloco definicao(String uri) => _blocos[uri] ?? DefinicaoBloco.desconhecido(uri);
}
