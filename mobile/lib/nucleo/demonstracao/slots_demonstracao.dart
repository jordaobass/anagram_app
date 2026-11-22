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

/// Falha injetada: a pedaleira confirma a gravação, mas as próximas
/// [releituras] leituras ainda devolvem os slots de antes de gravar.
class GravacaoAtrasada {
  int releituras = 0;
  Map<int, dynamic>? _antes;

  /// Guarda os slots como estavam; devolve os mesmos, para gravar neles.
  Map<int, dynamic> antesDeGravar(Map<int, dynamic> slots) {
    if (releituras > 0) _antes = {for (final e in slots.entries) e.key: jsonDecode(jsonEncode(e.value))};
    return slots;
  }

  Map<int, dynamic> paraLer(Map<int, dynamic> slots) {
    final antes = _antes;
    if (antes == null || releituras == 0) return slots;
    releituras--;
    return antes;
  }
}
