// O arquivo de explicações confere com o catálogo da pedaleira: três idiomas
// em todo texto, nenhuma chave órfã e nenhum parâmetro Darkglass sem balão.
import 'package:anagram_app/apresentacao/componentes/painel_parametros.dart';
import 'package:anagram_app/nucleo/catalogo/definicao_bloco.dart';
import 'package:anagram_app/nucleo/catalogo/explicacoes_parametros.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';

Iterable<TextoExplicacao> _todosOsTextos(ExplicacoesParametros e) => [
      for (final regra in e.tipos) regra.texto,
      for (final porSimbolo in e.porBloco.values) ...porSimbolo.values,
    ];

void main() {
  final explicacoes = lerExplicacoes();
  final catalogo = lerCatalogo();

  test('should_have_portuguese_english_and_spanish_in_every_text', () {
    for (final texto in _todosOsTextos(explicacoes)) {
      for (final idioma in TextoExplicacao.idiomas) {
        expect(texto.porIdioma[idioma]?.trim(), isNotEmpty, reason: '$idioma ausente em ${texto.porIdioma}');
      }
    }
  });

  test('should_only_point_to_blocks_and_parameters_that_exist_in_the_catalog', () {
    for (final MapEntry(key: uri, value: porSimbolo) in explicacoes.porBloco.entries) {
      final definicao = catalogo.todos.where((d) => d.uri == uri).firstOrNull;
      expect(definicao, isNotNull, reason: 'bloco inexistente: $uri');
      final simbolos = definicao!.parametros.map((p) => p.simbolo).toSet();
      for (final simbolo in porSimbolo.keys) {
        expect(simbolos, contains(simbolo), reason: 'parâmetro inexistente: $uri $simbolo');
      }
    }
  });

  test('should_explain_every_visible_parameter_of_every_darkglass_block', () {
    final semExplicacao = <String>[
      for (final definicao in catalogo.todos.where((d) => d.uri.contains('darkglass')))
        for (final p in parametrosVisiveis(definicao, BlocoPreset(const PosicaoBloco(1, 1), {'uri': definicao.uri})))
          if (explicacoes.de(definicao.uri, p) == null) '${definicao.uri} ${p.simbolo} (${p.nome})',
    ];

    expect(semExplicacao, isEmpty);
  });

  test('should_prefer_the_pedal_text_over_the_type_text_when_the_pedal_has_one', () {
    final threshold = catalogo.definicao('urn:darkglass:Suppressor').parametros.firstWhere((p) => p.simbolo == 'Threshold');
    final generico = explicacoes.tipoDe(threshold)!.texto.em('pt');

    expect(explicacoes.de('urn:darkglass:Suppressor', threshold)!.em('pt'), isNot(generico));
    expect(explicacoes.de('urn:darkglass:BUSComp', threshold)!.em('pt'), generico);
  });

  test('should_have_no_explanation_when_neither_the_pedal_nor_a_type_matches', () {
    const qualquer = DefinicaoParametro(simbolo: 'xyz', nome: 'Xyz', minimo: 0, maximo: 1, padrao: 0);

    expect(explicacoes.de('urn:darkglass:B3K', qualquer), isNull);
  });
}
