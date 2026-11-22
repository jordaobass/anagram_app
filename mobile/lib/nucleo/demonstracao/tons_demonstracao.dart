// Tons do TONE3000 da pedaleira simulada: um recorte da resposta real de
// `get_t3k_factory_tones` (fw 1.19.2.24; ids, títulos e modelos como vieram,
// sem descrição nem imagens) e um tom fictício "da pessoa", no formato de
// `get_t3k_tones_metadata` com itens (o da pesquisa do Darkglass Suite).

Map<String, dynamic> _modelo(int tom, int id, String nome, String extensao) => {
      'id': id,
      'tone_id': tom,
      'name': nome,
      'model_url': 'https://www.tone3000.com/api/v1/models/$id/download/demonstracao.$extensao',
      'architecture_version': extensao == 'nam' ? '2' : null,
      'size': null,
    };

Map<String, dynamic> _tom(int id, String titulo, String formato, String gear, String autor, List<(int, String)> modelos) =>
    {
      'id': id,
      'title': titulo,
      'format': formato,
      'gear': gear,
      'license': 't3k',
      'user': {'username': autor},
      'a2_models': [for (final (mid, nome) in modelos) _modelo(id, mid, nome, formato == 'ir' ? 'wav' : 'nam')],
    };

final List<Map<String, dynamic>> tonsDeFabricaDemonstracao = [
  _tom(28202, 'Ampeg SVT Classic with 6x10', 'nam', 'amp-cab', 'tone3000', [
    (379991, 'Ampeg SVT - Gain 10 Ultra Lo and Hi MD 421'),
    (379990, 'Ampeg SVT - Gain 10 Ultra Lo and Hi SM57'),
    (379989, 'Ampeg SVT - Ultra Lo MD 421'),
  ]),
  _tom(31010, 'TECH21 Sansamp Bass Driver', 'nam', 'pedal', 'everipper', [
    (395229, 'Sansamp Bass Driver (Driven)'),
    (395228, 'Sansamp Bass Driver'),
  ]),
  _tom(45809, 'AMPEG SVT-CL BASS HEAD', 'nam', 'amp', 'deathblossomaudio', [
    (382800, 'SVT DIRTY PUSHED'),
    (382799, 'SVT DIRTY'),
  ]),
  _tom(1612, 'Mesa OS 4x12 IR', 'ir', 'cab', 'scottcorgan', [(81565, 'Mesa_OS_4x12_57_m160')]),
  _tom(27465, 'Fender Deluxe Reverb Mix Ready', 'ir', 'cab', 'vulturized', [
    (220918, 'DELUXE REVERB OXFORD - BIG - 48 24'),
    (220917, 'DELUXE REVERB OXFORD - LEAN - 48 24'),
  ]),
];

/// Fictício: a pedaleira do dono não tem nenhum tom próprio.
final List<Map<String, dynamic>> tonsDoUsuarioDemonstracao = [
  {
    'data': _tom(990001, 'Meu SVT do ensaio', 'nam', 'amp', 'demonstracao', [(990101, 'SVT ensaio DI')]),
    'metadata': {
      'id': 1,
      't3k_tone_id': 990001,
      'models': [
        {'id': 1, 't3k_model_id': 990101, 'visible': true},
      ],
    },
  },
];

/// `get_t3k_tones_metadata` paginado, como a pedaleira real responde.
Map<String, dynamic> paginaDeTonsDemonstracao(Object? pagina, Object? porPagina) {
  final tamanho = porPagina is int && porPagina > 0 ? porPagina : 10;
  final numero = pagina is int && pagina > 0 ? pagina : 1;
  final itens = tonsDoUsuarioDemonstracao.skip((numero - 1) * tamanho).take(tamanho).toList();
  return {
    'success': 1,
    'data': {
      'info': {
        'all_items_length': tonsDoUsuarioDemonstracao.length,
        'items_length': itens.length,
        'page': numero,
        'items_per_page': tamanho,
      },
      't3k_data': itens,
    },
    'err_message': '',
  };
}
