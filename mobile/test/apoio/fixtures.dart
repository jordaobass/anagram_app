// Arquivos de referência lidos direto do disco nos testes.
import 'dart:convert';
import 'dart:io';

import 'package:anagram_app/aplicacao/arte/indice_miniaturas.dart';
import 'package:anagram_app/aplicacao/provedores.dart' show CaminhosAssets, exemploNaDemonstracao;
import 'package:anagram_app/nucleo/catalogo/catalogo_blocos.dart';
import 'package:anagram_app/nucleo/catalogo/explicacoes_parametros.dart';
import 'package:anagram_app/nucleo/catalogo/templates_bloco.dart';
import 'package:anagram_app/nucleo/conhecimento/base_conhecimento.dart';
import 'package:anagram_app/nucleo/modelo/presets_fabrica.dart';

Map<String, dynamic> lerExemplo(String nome) =>
    jsonDecode(File('assets/referencia/exemplos/$nome.json').readAsStringSync())
        as Map<String, dynamic>;

CatalogoBlocos lerCatalogo() =>
    CatalogoBlocos.doTexto(File('assets/referencia/blocks-factory.json').readAsStringSync());

TemplatesBlocos lerTemplates() => TemplatesBlocos.doTexto(File(CaminhosAssets.templates).readAsStringSync());

ExplicacoesParametros lerExplicacoes() =>
    ExplicacoesParametros.doTexto(File(CaminhosAssets.explicacoes).readAsStringSync());

GuiaBlocos lerGuiaBlocos() => GuiaBlocos.doTexto(File(CaminhosAssets.conhecimentoBlocos).readAsStringSync());

GuiaTimbre lerGuiaTimbre() => GuiaTimbre.doTexto(File(CaminhosAssets.conhecimentoTimbre).readAsStringSync());

ReceitasTimbre lerReceitas() => ReceitasTimbre.doTexto(File(CaminhosAssets.conhecimentoReceitas).readAsStringSync());

BaseConhecimento lerConhecimento() =>
    BaseConhecimento(guiaBlocos: lerGuiaBlocos(), guiaTimbre: lerGuiaTimbre(), receitas: lerReceitas());

Map<int, Map<String, dynamic>> lerPresetsDemonstracao() {
  final bruto = jsonDecode(File('assets/demonstracao/presets.json').readAsStringSync())
      as Map<String, dynamic>;
  return {
    for (final e in bruto.entries) int.parse(e.key): e.value as Map<String, dynamic>,
    for (final n in CaminhosAssets.exemplos) n: exemploNaDemonstracao(n, lerExemplo('$n')),
  };
}

/// Capturas saem com a arte real dos pedais (o indice.json versionado,
/// DECISOES A16): é o que a pessoa vê no app. SEM_MINIATURAS=1 tira a arte
/// (só a própria, por família), para quem precisar comparar sem ela.
bool get comMiniaturas =>
    Platform.environment['SEM_MINIATURAS'] != '1' && File('assets/blocos_terceiros/indice.json').existsSync();

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

/// Com a arte (o padrão das capturas), a fábrica de verdade, se a ferramenta
/// já a gerou; senão, a pequena dos testes.
PresetsDeFabrica lerFabrica() {
  final arquivo = File('assets/blocos_terceiros/fabrica.json');
  return PresetsDeFabrica.doTexto(
      comMiniaturas && arquivo.existsSync() ? arquivo.readAsStringSync() : textoFabricaDeTeste());
}

/// O indice.json versionado (DECISOES A16), sempre: para conferir o
/// casamento da arte real.
IndiceMiniaturas lerIndiceVersionado() =>
    IndiceMiniaturas.doTexto(File('assets/blocos_terceiros/indice.json').readAsStringSync());

/// Índice dos testes de comportamento: vazio, todo bloco com a arte própria,
/// para que o resultado não dependa da arte de terceiros.
IndiceMiniaturas lerIndiceMiniaturas() => IndiceMiniaturas.vazio();

/// Índice das capturas: a arte real, a não ser com SEM_MINIATURAS=1.
IndiceMiniaturas lerIndiceDasCapturas() => comMiniaturas ? lerIndiceVersionado() : IndiceMiniaturas.vazio();
