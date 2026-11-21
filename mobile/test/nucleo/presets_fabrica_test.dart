// Presets de fábrica lidos do arquivo gerado do Suite: cada um no slot do
// nome do arquivo (1.json = 01A), e uma entrada estragada não derruba as outras.
import 'dart:convert';

import 'package:anagram_app/nucleo/modelo/presets_fabrica.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';

void main() {
  test('should_place_each_factory_preset_in_the_slot_of_its_file_when_the_suite_file_is_read', () {
    final fabrica = PresetsDeFabrica.doTexto(textoFabricaDeTeste());

    expect(
      {for (final r in fabrica.resumos) r.slot.rotulo: r.nome},
      {'01A': 'Harmonic Booster', '01B': 'Vintage Microtubes'},
    );
    expect(fabrica.documento(SlotPreset(2))!.nome, 'Vintage Microtubes');
    expect(fabrica.documento(SlotPreset(3)), isNull);
  });

  test('should_skip_entries_that_are_not_anagram_presets_when_the_file_is_partly_broken', () {
    final texto = jsonEncode({
      'presets': [
        {
          'arquivo': '1.json',
          'nome': 'Quebrado',
          'preset': {'type': 'outra coisa'},
        },
        {'arquivo': 'sem-numero', 'nome': 'Sem slot', 'preset': lerExemplo('1')},
        {'arquivo': '4.json', 'nome': 'Bom', 'preset': lerExemplo('1')},
      ],
    });

    final fabrica = PresetsDeFabrica.doTexto(texto);

    expect(fabrica.resumos.map((r) => r.slot.rotulo), ['02A']);
  });
}
