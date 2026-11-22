// Preset da demonstração com um bloco TONE3000 NAM Loader na casa 3 da
// linha 1, com a property do preset real da v1.19.2.24 (Ampeg SVT, tom 28202,
// primeiro modelo 379991). Os testes trocam o valor para os outros casos.
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:anagram_app/nucleo/modelo/json_util.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import 'fixtures.dart';

const uriTone3000 = 'urn:darkglass:neural:tone3000';
const uriGabineteTone3000 = 'urn:darkglass-anagram:cabinet-tone3000#stereo';
const caminhoDoPresetReal = '/factory-data/neural-models-t3k/28202/379991.nam';

/// O slot 3 (01C, "Grave Limpo") ganha o bloco; a casa 3 está livre nele.
const slotComTone3000 = 3;
const posicaoTone3000 = PosicaoBloco(1, 3);

/// [uri]: o NAM Loader (padrão) ou o Tone3000 Cabinet, com a property de cada um.
Map<String, dynamic> blocoTone3000(String valor, {String uri = uriTone3000}) {
  final neural = uri == uriTone3000;
  return {
    'enabled': true,
    'parameters': <String, dynamic>{},
    'properties': {
      '1': neural
          ? {'name': 'Neural Model', 'uri': '$uri#model', 'value': valor}
          : {'name': 'Cabinet File', 'uri': 'urn:darkglass-anagram:cabinet-tone3000#file', 'value': valor},
    },
    'quickpot': neural ? 'INPUT' : 'Level',
    'scenes': <String, dynamic>{},
    'uri': uri,
  };
}

Map<String, dynamic> presetComTone3000(String valor, {String uri = uriTone3000}) {
  final preset = copiaProfunda(lerPresetsDemonstracao()[slotComTone3000]!);
  (preset['preset']['chains']['1']['blocks'] as Map<String, dynamic>)['3'] = blocoTone3000(valor, uri: uri);
  return preset;
}

/// Põe o bloco na pedaleira simulada assim que ela nasce; [ajuste] mexe no resto.
Override pedaleiraComTone3000(
        {String valor = caminhoDoPresetReal,
        String uri = uriTone3000,
        void Function(TransporteDemonstracao)? ajuste}) =>
    ajusteDemonstracaoProvider.overrideWithValue((pedaleira) {
      pedaleira.substituirSlot(slotComTone3000, presetComTone3000(valor, uri: uri));
      ajuste?.call(pedaleira);
    });

/// A property "1" do bloco TONE3000 num documento cru (o tocado ou o gravado).
Map<String, dynamic>? propriedadeDoTone3000(Map<String, dynamic>? documento) =>
    documento?['preset']['chains']['1']['blocks']['3']['properties']['1'] as Map<String, dynamic>?;
