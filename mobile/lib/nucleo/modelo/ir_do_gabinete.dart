// O arquivo que o bloco carrega (IR do gabinete, tom do TONE3000) mora na
// property "1", no formato que a pedaleira grava:
//   gabinete (exemplo 2, presets de fábrica do Darkglass Suite):
//     {"name": "Cabinet File", "uri": "<uri do bloco>#file", "value": "/factory-data/cabinets/x.dat"}
//   neural (preset real com TONE3000, fw 1.19.2.24; presets do Suite):
//     {"name": "Neural Model", "uri": "<uri do bloco>#model", "value": "/factory-data/neural-models-t3k/28202/379991.nam"}
// O que a property já tem (nome, uri, outras chaves) é preservado; só o
// valor muda.
import '../catalogo/variantes_uri.dart';
import 'json_util.dart';

void gravarArquivoDeIr(Map<String, dynamic> bloco, String caminho) {
  // a pedaleira às vezes grava `properties` como lista vazia: vira mapa
  if (bloco['properties'] is! Map<String, dynamic>) bloco['properties'] = <String, dynamic>{};
  final propriedades = bloco['properties'] as Map<String, dynamic>;
  final atual = mapaOuVazio(propriedades['1']);
  final (nome, sufixo) = _nomeESufixoPadrao(textoOuNulo(bloco['uri']) ?? '');
  propriedades['1'] = <String, dynamic>{
    ...atual,
    'name': atual['name'] ?? nome,
    // sem o sufixo de canal: "cabinet-tone3000#stereo" vira "cabinet-tone3000#file"
    'uri': atual['uri'] ?? '${semSufixoDeCanal(textoOuNulo(bloco['uri']) ?? '')}#$sufixo',
    'value': caminho,
  };
}

/// Os blocos neurais (`urn:darkglass:neural:*`) carregam "Neural Model";
/// os gabinetes, "Cabinet File".
(String, String) _nomeESufixoPadrao(String uri) =>
    uri.startsWith('urn:darkglass:neural:') ? ('Neural Model', 'model') : ('Cabinet File', 'file');
