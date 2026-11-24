// Parâmetro registrado só em algumas fotos de cena (o Microtubes do 02A da
// demonstração: high_drive 5 no bloco e 8.5 só na foto da cena 3). Sem
// registro, a cena segue o bloco; mas o bloco muda a cada troca de cena, e
// as cenas sem registro passavam a tocar o valor da última cena visitada.
// Ao abrir, as fotos sem o registro recebem o valor do bloco (DECISOES CE2).
import 'dart:convert';
import 'dart:io';

import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:anagram_app/nucleo/modelo/documento_preset.dart';
import 'package:anagram_app/nucleo/modelo/json_util.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';

Map<String, dynamic> _bloco({required Map<String, dynamic> scenes, bool enabled = true}) => {
      'uri': 'urn:teste:bloco',
      'enabled': enabled,
      'parameters': {
        '0': {'symbol': 'high_drive', 'value': 5},
      },
      'scenes': scenes,
    };

Map<String, dynamic> _preset(Map<String, dynamic> bloco) => {
      'type': 'preset',
      'version': 1,
      'preset': {
        'name': 'Parcial',
        'scene': 1,
        'chains': {
          '1': {
            'blocks': {'1': bloco}
          }
        },
      },
    };

const _casa = PosicaoBloco(1, 1);

void main() {
  test('should_fill_the_scenes_without_the_parameter_with_the_block_value_when_opening', () {
    final documento = DocumentoPreset.doJson(_preset(_bloco(scenes: {
      '3': {
        'parameters': [
          {'symbol': 'high_drive', 'value': 8.5}
        ]
      },
    })));

    final bloco = documento.bloco(_casa)!;
    expect([for (final cena in [1, 2, 3]) bloco.sobreposicaoDaCena('high_drive', cena)], [5, 5, 8.5]);
    final ida = documento.comCena(3).comCena(2).bloco(_casa)!;
    expect(ida.valorBase('high_drive'), 5, reason: 'voltar da cena 3 não deixa o 8.5 no bloco');
  });

  test('should_fill_the_on_off_of_the_scenes_that_do_not_register_it_with_the_block_state', () {
    final documento = DocumentoPreset.doJson(_preset(_bloco(enabled: true, scenes: {
      '3': {'enabled': false, 'parameters': <dynamic>[]},
    })));

    final ida = documento.comCena(3).comCena(1).bloco(_casa)!;
    expect(ida.habilitado, isTrue, reason: 'a cena 1 segue o ligado do bloco, não o desligado da 3');
    expect(documento.comCena(3).bloco(_casa)!.habilitado, isFalse);
  });

  test('should_leave_presets_without_partial_scene_photos_identical_when_opening', () {
    final reais = {
      for (final n in ['1', '2']) 'exemplo $n': lerExemplo(n),
      ..._fabricaReal(),
    };
    expect(reais, isNotEmpty);
    for (final MapEntry(key: nome, value: json) in reais.entries) {
      expect(DocumentoPreset.doJson(json).paraJson(), json, reason: nome);
    }
  });
}

/// A fábrica de verdade, quando o build a tem (fica fora do git, U18).
Map<String, Map<String, dynamic>> _fabricaReal() {
  final arquivo = File('assets/blocos_terceiros/fabrica.json');
  if (!arquivo.existsSync()) return const {};
  final lista = mapaOuVazio(jsonDecode(arquivo.readAsStringSync()))['presets'] as List;
  return {
    for (final entrada in lista.cast<Map<String, dynamic>>())
      'fábrica ${entrada['arquivo']}': entrada['preset'] as Map<String, dynamic>,
  };
}
