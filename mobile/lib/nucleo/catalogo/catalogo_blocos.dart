// Catálogo de blocos de fábrica, carregado do JSON de referência.
import 'dart:convert';

import 'definicao_bloco.dart';
import 'variantes_uri.dart';

class CatalogoBlocos {
  CatalogoBlocos(Map<String, DefinicaoBloco> blocos, {this.firmware = '', Map<int, String> categorias = const {}})
      : _blocos = Map.unmodifiable(_marcarCanais(blocos)),
        _categorias = Map.unmodifiable(categorias);

  /// Blocos com o mesmo nome são as versões mono e estéreo de um efeito: a uri
  /// da estéreo diz "stereo" ("…#stereo", "…ReverbStereo"); a outra é a mono.
  static Map<String, DefinicaoBloco> _marcarCanais(Map<String, DefinicaoBloco> blocos) {
    final porNome = <String, int>{};
    for (final bloco in blocos.values) {
      porNome[bloco.nome] = (porNome[bloco.nome] ?? 0) + 1;
    }
    return blocos.map((uri, bloco) {
      if ((porNome[bloco.nome] ?? 0) < 2) return MapEntry(uri, bloco);
      final estereo = uri.toLowerCase().contains('stereo');
      return MapEntry(uri, bloco.comCanal(estereo ? CanalBloco.estereo : CanalBloco.mono));
    });
  }

  factory CatalogoBlocos.doTexto(String texto) {
    final json = jsonDecode(texto) as Map<String, dynamic>;
    final blocos = json['blocks'] as Map<String, dynamic>;
    return CatalogoBlocos(
      {
        for (final entrada in blocos.entries)
          entrada.key: DefinicaoBloco.doJson(entrada.key, entrada.value as Map<String, dynamic>),
      },
      firmware: json['firmware'] as String? ?? '',
      categorias: {
        for (final bloco in blocos.values.whereType<Map<String, dynamic>>())
          if (bloco['categoryCode'] case final int codigo) codigo: '${bloco['category'] ?? ''}',
      },
    );
  }

  final Map<String, DefinicaoBloco> _blocos;
  final Map<int, String> _categorias;
  final String firmware;

  /// O grupo do código de categoria que a pedaleira manda (`category` do
  /// `get_plugin_info`), pelos blocos de fábrica; código que nenhum usa
  /// fica sem grupo (a família sai do nome, senão Utilitário).
  String nomeDaCategoria(int codigo) => _categorias[codigo] ?? '';

  /// O bloco está aqui (com ou sem sufixo de canal).
  bool conhece(String uri) => buscarPorVariantes(_blocos, uri) != null;

  /// Este catálogo com os blocos lidos da pedaleira conectada (Marketplace).
  CatalogoBlocos comBlocos(Map<String, DefinicaoBloco> daPedaleira) =>
      CatalogoBlocos({..._blocos, ...daPedaleira}, firmware: firmware, categorias: _categorias);

  int get quantidade => _blocos.length;
  Iterable<DefinicaoBloco> get todos => _blocos.values;

  /// Aceita a uri com ou sem sufixo de canal ("#stereo", "#mono").
  DefinicaoBloco definicao(String uri) => buscarPorVariantes(_blocos, uri) ?? DefinicaoBloco.desconhecido(uri);
}
