// Arquivos de referência lidos direto do disco nos testes.
import 'dart:convert';
import 'dart:io';

import 'package:anagram_app/aplicacao/arte/indice_miniaturas.dart';
import 'package:anagram_app/aplicacao/provedores.dart' show CaminhosAssets;
import 'package:anagram_app/nucleo/catalogo/catalogo_blocos.dart';
import 'package:anagram_app/nucleo/catalogo/explicacoes_parametros.dart';
import 'package:anagram_app/nucleo/catalogo/templates_bloco.dart';
import 'package:anagram_app/nucleo/modelo/presets_fabrica.dart';

Map<String, dynamic> lerExemplo(String nome) =>
    jsonDecode(File('assets/referencia/exemplos/$nome.json').readAsStringSync())
        as Map<String, dynamic>;

CatalogoBlocos lerCatalogo() =>
    CatalogoBlocos.doTexto(File('assets/referencia/blocks-factory.json').readAsStringSync());

TemplatesBlocos lerTemplates() => TemplatesBlocos.doTexto(File(CaminhosAssets.templates).readAsStringSync());

ExplicacoesParametros lerExplicacoes() =>
    ExplicacoesParametros.doTexto(File(CaminhosAssets.explicacoes).readAsStringSync());

Map<int, Map<String, dynamic>> lerPresetsDemonstracao() {
  final bruto = jsonDecode(File('assets/demonstracao/presets.json').readAsStringSync())
      as Map<String, dynamic>;
  return {
    for (final e in bruto.entries) int.parse(e.key): e.value as Map<String, dynamic>,
    for (final n in CaminhosAssets.exemplos) n: lerExemplo('$n'),
  };
}

/// Capturas usam só a arte própria (as miniaturas de terceiros ficam fora do
/// git), a não ser com COM_MINIATURAS=1 e a pasta local preenchida.
bool get comMiniaturas =>
    Platform.environment['COM_MINIATURAS'] == '1' && File('assets/blocos_terceiros/indice.json').existsSync();

/// Fábrica pequena para os testes, no formato do fabrica.json que a
/// ferramenta de arte gera do Suite: dois presets reais nos slots 01A e 01B.
String textoFabricaDeTeste() {
  Map<String, dynamic> comNome(String exemplo, String nome) => lerExemplo(exemplo)..['preset']['name'] = nome;
  return jsonEncode({
    'presets': [
      {'arquivo': '1.json', 'nome': 'Harmonic Booster', 'preset': comNome('1', 'Harmonic Booster')},
      {'arquivo': '2.json', 'nome': 'Vintage Microtubes', 'preset': comNome('2', 'Vintage Microtubes')},
    ],
  });
}

/// Com a arte (COM_MINIATURAS=1), a fábrica de verdade, se a ferramenta já a
/// gerou; senão, a pequena dos testes.
PresetsDeFabrica lerFabrica() {
  final arquivo = File('assets/blocos_terceiros/fabrica.json');
  return PresetsDeFabrica.doTexto(
      comMiniaturas && arquivo.existsSync() ? arquivo.readAsStringSync() : textoFabricaDeTeste());
}

/// O indice.json versionado (DECISOES A16), sem depender de COM_MINIATURAS:
/// para conferir o casamento da arte real, não para capturas.
IndiceMiniaturas lerIndiceVersionado() =>
    IndiceMiniaturas.doTexto(File('assets/blocos_terceiros/indice.json').readAsStringSync());

IndiceMiniaturas lerIndiceMiniaturas() => comMiniaturas
    ? IndiceMiniaturas.doTexto(File('assets/blocos_terceiros/indice.json').readAsStringSync())
    : IndiceMiniaturas.vazio();
