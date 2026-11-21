// Templates de bloco conferidos contra o catálogo do firmware: nenhum aponta
// parâmetro que não existe, sai da faixa ou grava opção inválida; os da
// Darkglass que já têm valores são os padrões do catálogo, e os ainda sem
// valores lidos da pedaleira não se aplicam.
import 'package:anagram_app/nucleo/catalogo/explicacoes_parametros.dart' show TextoExplicacao;
import 'package:anagram_app/nucleo/catalogo/templates_bloco.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';

void main() {
  final catalogo = lerCatalogo();
  final templates = lerTemplates();

  test('should_keep_every_template_value_inside_the_catalog_range_and_options', () {
    final problemas = <String>[
      for (final uri in templates.uris)
        for (final t in templates.de(uri))
          for (final MapEntry(key: simbolo, value: valor) in (t.valores ?? const <String, num>{}).entries)
            if (catalogo.definicao(uri).parametro(simbolo) case final p)
              if (p == null)
                '$uri ${t.id}: $simbolo não existe'
              else if (valor < p.minimo || valor > p.maximo)
                '$uri ${t.id}: $simbolo=$valor fora de ${p.minimo}..${p.maximo}'
              else if (p.opcoes.isNotEmpty && p.valorDaOpcao(p.indiceOpcao(valor)) != valor)
                '$uri ${t.id}: $simbolo=$valor não é opção',
    ];

    expect(problemas, isEmpty);
  });

  test('should_name_and_describe_every_template_in_the_three_languages', () {
    final faltando = [
      for (final uri in templates.uris)
        for (final t in templates.de(uri))
          for (final texto in [t.nome, t.descricao])
            if (!TextoExplicacao.idiomas.every((i) => (texto.porIdioma[i] ?? '').isNotEmpty)) t.id,
    ];

    expect(faltando, isEmpty);
  });

  test('should_match_the_catalog_defaults_in_the_darkglass_default_templates', () {
    for (final (uri, id) in [('urn:darkglass:ignissor', 'dg-neutral-ground'), ('urn:darkglass:entropia', 'dg-glass-drive')]) {
      final definicao = catalogo.definicao(uri);
      final padrao = templates.de(uri).firstWhere((t) => t.id == id);

      expect(padrao.origem, OrigemTemplate.darkglass);
      expect(padrao.aplicadoEm((s) => definicao.parametro(s)?.padrao), isTrue, reason: id);
    }
  });

  test('should_list_darkglass_templates_first_and_keep_the_ones_without_values_unavailable', () {
    final lista = templates.de('urn:darkglass:entropia');

    expect(lista.first.origem, OrigemTemplate.darkglass);
    expect(lista.last.origem, OrigemTemplate.app);
    final semValores = lista.where((t) => !t.disponivel).map((t) => t.nome.em('en'));
    expect(semValores, containsAll(['Hard Rock Bite', 'Modern Peaches']));
    expect(semValores.any((n) => n == 'Glass Drive'), isFalse);
    expect(templates.de('urn:darkglass:ignissor#stereo'), isNotEmpty, reason: 'a variante usa os do bloco');
  });

  test('should_stop_reporting_a_template_as_applied_when_one_value_differs', () {
    final grave = templates.de('urn:darkglass:ignissor').firstWhere((t) => t.id == 'app-grave-travado');
    final valores = Map<String, num>.of(grave.valores!);

    expect(grave.aplicadoEm((s) => valores[s]), isTrue);
    valores['lo_threshold'] = -35;
    expect(grave.aplicadoEm((s) => valores[s]), isFalse);
  });
}
