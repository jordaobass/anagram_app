// A cópia dos presets de fábrica que vem do Darkglass Suite grava o nível do
// Gentle como `level`; a pedaleira grava `output_lvl` (lido do 01A real). Sem a
// troca, o Harmonic Booster mostrava -3 dB (o padrão) em vez dos -12 dB gravados.
import 'dart:convert';

import 'package:anagram_app/nucleo/modelo/presets_fabrica.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('should_read_the_gentle_level_of_a_factory_preset_under_the_firmware_symbol', () {
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
              'chains': {
                '1': {
                  'blocks': {
                    '1': {
                      'uri': 'urn:darkglass:neural-plugins:gentle',
                      'enabled': true,
                      'parameters': {
                        '1': {'name': 'Level', 'symbol': 'level', 'value': -12},
                      },
                    },
                  },
                },
              },
            },
          },
        },
      ],
    });

    final gentle = PresetsDeFabrica.doTexto(texto).documento(SlotPreset(1))!.blocosDaLinha(1).single;

    expect(gentle.valorBase('output_lvl'), -12);
  });
}
