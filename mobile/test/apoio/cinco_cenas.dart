// Preset com cinco cenas (firmware 1.16+, issue #39), no formato dos presets
// de três: as cenas a mais são as chaves "4" e "5" de `scenes` e de
// `sceneNames`. HIPÓTESE (DECISOES CE3): nenhum preset real com mais de três
// cenas foi lido ainda; o formato é o mesmo das três que existem.
import 'package:anagram_app/nucleo/modelo/json_util.dart';

const uriMicrotubesX = 'urn:darkglass:neural-plugins:microtubes-x';

Map<String, dynamic> _foto(num highDrive) => {
      'enabled': true,
      'parameters': [
        {'symbol': 'high_drive', 'value': highDrive},
      ],
      'properties': <dynamic>[],
    };

/// Microtubes X na casa 1: high_drive 5 / 5 / 8,5 / 6 / 7 nas cenas,
/// low_level 3 e high_level 4 iguais em todas; cena ativa = 1.
Map<String, dynamic> presetCincoCenas() => {
      'type': 'preset',
      'version': 1,
      'preset': {
        'name': 'Cinco Cenas',
        'uuid': '0123456789abcdef-01234567-89abcdef-0123456789abcdef01234567',
        'bindings': <String, dynamic>{},
        'scene': 0,
        'sceneNames': {'1': 'LIMPO', '2': 'GRAVE', '3': 'SUJO', '4': 'SOLO', '5': 'FINAL'},
        'chains': {
          '1': {
            'blocks': {
              '1': {
                'uri': uriMicrotubesX,
                'enabled': true,
                'parameters': {
                  '1': {'name': 'Low Level', 'symbol': 'low_level', 'value': 3},
                  '2': {'name': 'High Level', 'symbol': 'high_level', 'value': 4},
                  '3': {'name': 'High Drive', 'symbol': 'high_drive', 'value': 5},
                },
                'properties': <String, dynamic>{},
                'quickpot': 'high_drive',
                'scenes': {'1': _foto(5), '2': _foto(5), '3': _foto(8.5), '4': _foto(6), '5': _foto(7)},
              },
            },
          },
        },
      },
    };

Map<String, dynamic> blocoDoPreset(Map<String, dynamic> json) =>
    mapaOuVazio(mapaOuVazio(mapaOuVazio(mapaOuVazio(json['preset'])['chains'])['1'])['blocks'])['1']
        as Map<String, dynamic>;
