// Os slots de uma área da pedaleira de demonstração, como a Anagram responde
// a `get_anagram_preset_positions`, `fetch_anagram_preset`,
// `edit_anagram_presets` e `delete_anagram_preset`. Cada área é um mapa
// número do slot → envelope do preset.
import 'dart:convert';

import '../modelo/slot_preset.dart';

/// Cópia funda dos presets dados, para a demonstração não mexer no original.
Map<int, dynamic> copiaDosSlots(Map<int, Map<String, dynamic>> presets) =>
    {for (final e in presets.entries) e.key: jsonDecode(jsonEncode(e.value))};

List<Map<String, dynamic>> posicoesDosSlots(Map<int, dynamic> slots) {
  final numeros = slots.keys.toList()..sort();
  return [
    for (final n in numeros)
      {
        'filename': '$n.json',
        'id': (slots[n]['preset'] as Map<String, dynamic>)['uuid'] ?? '',
        'name': (slots[n]['preset'] as Map<String, dynamic>)['name'] ?? '',
      },
  ];
}

Map<String, dynamic> lerSlot(Map<int, dynamic> slots, String? arquivo) {
  final conteudo = slots[_numero(arquivo)];
  return {
    'data': {'presetFile': conteudo == null ? <String, dynamic>{} : {'content': conteudo}},
  };
}

Map<String, dynamic> gravarSlots(Map<int, dynamic> slots, Object? presets) {
  for (final item in (presets as List<dynamic>? ?? const [])) {
    final mapa = item as Map<String, dynamic>;
    slots[_numero(mapa['name'] as String?)] = jsonDecode(jsonEncode(mapa['content']));
  }
  return {'status': 'ok'};
}

Map<String, dynamic> excluirSlot(Map<int, dynamic> slots, String? arquivo) {
  slots.remove(_numero(arquivo));
  return {'status': 'ok'};
}

int _numero(String? arquivo) => SlotPreset.numeroDoArquivo('$arquivo') ?? -1;
