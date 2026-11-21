// O arquivo de IR do gabinete mora na property "1" do bloco, no formato que a
// pedaleira grava (exemplo 2 e presets de fábrica do Darkglass Suite):
// {"name": "Cabinet File", "uri": "<uri do bloco>#file", "value": "/factory-data/cabinets/x.dat"}.
import 'json_util.dart';

void gravarArquivoDeIr(Map<String, dynamic> bloco, String caminho) {
  // a pedaleira às vezes grava `properties` como lista vazia: vira mapa
  if (bloco['properties'] is! Map<String, dynamic>) bloco['properties'] = <String, dynamic>{};
  final propriedades = bloco['properties'] as Map<String, dynamic>;
  final atual = mapaOuVazio(propriedades['1']);
  propriedades['1'] = <String, dynamic>{
    'name': atual['name'] ?? 'Cabinet File',
    'uri': atual['uri'] ?? '${bloco['uri']}#file',
    'value': caminho,
  };
}
