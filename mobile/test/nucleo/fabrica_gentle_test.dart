// A cópia dos presets de fábrica que vem do Darkglass Suite grava o nível do
// Gentle como `level`; a pedaleira grava `output_lvl` (lido do 01A real). Sem a
// troca, o Harmonic Booster mostrava -3 dB (o padrão) em vez dos -12 dB gravados.
import 'dart:convert';

import 'package:anagram_app/nucleo/modelo/documento_preset.dart';
import 'package:anagram_app/nucleo/modelo/presets_fabrica.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:flutter_test/flutter_test.dart';

const _gentle = 'urn:darkglass:neural-plugins:gentle';

/// Um preset de fábrica com o Gentle na casa 1 da linha 1, como no Suite.
DocumentoPreset _deFabrica(Map<String, dynamic> gentle, {Map<String, dynamic> bindings = const {}}) {
  final texto = jsonEncode({
    'presets': [
      {
        'arquivo': '1.json',
        'nome': 'Harmonic Booster',
        'preset': {
          'type': 'preset',
          'version': 1,
          'preset': {
            'name': 'Harmonic Booster',
            'bindings': bindings,
            'chains': {
              '1': {
                'blocks': {'1': gentle},
              },
            },
          },
        },
      },
    ],
  });
  return PresetsDeFabrica.doTexto(texto).documento(SlotPreset(1))!;
}

Map<String, dynamic> _blocoGentle({Map<String, dynamic> scenes = const {}}) => {
      'uri': _gentle,
      'enabled': true,
      'parameters': {
        '1': {'name': 'Level', 'symbol': 'level', 'value': -12},
      },
      'scenes': scenes,
    };

void main() {
  test('should_read_the_gentle_level_of_a_factory_preset_under_the_firmware_symbol', () {
    final gentle = _deFabrica(_blocoGentle()).blocosDaLinha(1).single;

    expect(gentle.valorBase('output_lvl'), -12);
  });

  test('should_read_the_gentle_level_of_each_scene_under_the_firmware_symbol', () {
    final cenas = {
      for (final (cena, nivel) in [(1, -12), (2, -5.9), (3, -3)])
        '$cena': {
          'enabled': true,
          'parameters': [
            {'symbol': 'level', 'value': nivel},
          ],
        },
    };

    final gentle = _deFabrica(_blocoGentle(scenes: cenas)).blocosDaLinha(1).single;

    expect(gentle.sobreposicaoDaCena('output_lvl', 2), -5.9);
    expect(gentle.sobreposicaoDaCena('level', 2), isNull);
  });

  test('should_point_a_control_bound_to_the_gentle_level_at_the_firmware_symbol', () {
    final bindings = {
      'pot1': {
        'name': 'Level',
        'parameters': [
          {'block': 1, 'row': 1, 'symbol': 'level'},
        ],
      },
    };

    final preset = _deFabrica(_blocoGentle(), bindings: bindings).paraJson()['preset'] as Map<String, dynamic>;

    expect(preset['bindings']['pot1']['parameters'][0]['symbol'], 'output_lvl');
  });
}
