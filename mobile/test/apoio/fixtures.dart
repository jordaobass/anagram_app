// Arquivos de referência lidos direto do disco nos testes.
import 'dart:convert';
import 'dart:io';

import 'package:anagram_app/aplicacao/arte/indice_miniaturas.dart';
import 'package:anagram_app/nucleo/catalogo/catalogo_blocos.dart';

Map<String, dynamic> lerExemplo(String nome) =>
    jsonDecode(File('assets/referencia/exemplos/$nome.json').readAsStringSync())
        as Map<String, dynamic>;

CatalogoBlocos lerCatalogo() =>
    CatalogoBlocos.doTexto(File('assets/referencia/blocks-factory.json').readAsStringSync());

Map<int, Map<String, dynamic>> lerPresetsDemonstracao() {
  final bruto = jsonDecode(File('assets/demonstracao/presets.json').readAsStringSync())
      as Map<String, dynamic>;
  return {
    for (final e in bruto.entries) int.parse(e.key): e.value as Map<String, dynamic>,
    for (final n in const [1, 2, 13, 41]) n: lerExemplo('$n'),
  };
}

/// Capturas usam só a arte própria (as miniaturas de terceiros ficam fora do
/// git), a não ser com COM_MINIATURAS=1 e a pasta local preenchida.
bool get comMiniaturas =>
    Platform.environment['COM_MINIATURAS'] == '1' && File('assets/blocos_terceiros/indice.json').existsSync();

IndiceMiniaturas lerIndiceMiniaturas() => comMiniaturas
    ? IndiceMiniaturas.doTexto(File('assets/blocos_terceiros/indice.json').readAsStringSync())
    : IndiceMiniaturas.vazio();
