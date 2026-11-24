// Templates de bloco conferidos contra o catálogo do firmware: nenhum aponta
// parâmetro que não existe, sai da faixa ou grava opção inválida. Os oficiais
// do Ignissor e do Entropia trazem os valores LIDOS da pedaleira (fw 1.19.2,
// 2026-11-24: o dono aplicou cada um num bloco e salvou; as leituras estão em
// test/fixtures/templates_lidos), na ordem da tela; os do Axioma ainda não
// têm valores e não se aplicam.
import 'dart:convert';
import 'dart:io';

import 'package:anagram_app/nucleo/catalogo/explicacoes_parametros.dart' show TextoExplicacao;
import 'package:anagram_app/nucleo/catalogo/templates_bloco.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';

/// Template oficial → (preset lido, coluna do bloco), na ordem da pedaleira.
const _lidos = {
  'urn:darkglass:ignissor': {
    'dg-neutral-ground': ('13B', 1), 'dg-studio-glue': ('13B', 2), 'dg-slap-n-pop': ('13B', 3),
    'dg-demudifier': ('13B', 4), 'dg-cordial': ('13B', 5), 'dg-pick-metal': ('13B', 6),
  },
  'urn:darkglass:entropia': {
    'dg-glass-drive': ('13C', 1), 'dg-hard-rock-bite': ('13C', 2), 'dg-tubey-tone': ('13C', 3),
    'dg-nasty-attack': ('13C', 4), 'dg-panic': ('13C', 5), 'dg-alpha-and-omega': ('13C', 6),
    'dg-electric-drive': ('13C', 7), 'dg-synth-like-drive': ('13C', 8), 'dg-carnivore': ('13C', 10),
    'dg-vintage-growl': ('13C', 11), 'dg-ultimate-fuzz': ('14A', 1), 'dg-modern-metal': ('14A', 2),
    'dg-rocky-road': ('14A', 3), 'dg-slightly-hairy': ('14A', 4), 'dg-sand-people': ('14A', 6),
    'dg-vintage-dirt': ('14A', 7), 'dg-modern-peaches': ('14A', 8),
  },
};

/// Os valores do bloco na coluna [coluna] do preset lido da pedaleira.
Map<String, num> _lidoDaPedaleira(String slot, int coluna) {
  final lido = jsonDecode(File('test/fixtures/templates_lidos/tpl-$slot.json').readAsStringSync()) as Map<String, dynamic>;
  final blocos = (lido['preset']['rows']['1'] as List).cast<Map<String, dynamic>>();
  final bloco = blocos.firstWhere((b) => b['column'] == coluna);
  return {for (final p in (bloco['parameters'] as List).cast<Map<String, dynamic>>()) p['symbol'] as String: p['value'] as num};
}

List<TemplateBloco> _oficiais(TemplatesBlocos templates, String uri) =>
    templates.de(uri).where((t) => t.origem == OrigemTemplate.darkglass).toList();

void main() {
  final catalogo = lerCatalogo();
  final templates = lerTemplates();

  test('should_carry_the_values_read_from_the_pedal_for_every_official_ignissor_and_entropia_template_in_screen_order', () {
    for (final MapEntry(key: uri, value: lidos) in _lidos.entries) {
      final oficiais = _oficiais(templates, uri);
      final simbolos = catalogo.definicao(uri).parametros.map((p) => p.simbolo).toSet();

      expect(oficiais.map((t) => t.id), lidos.keys, reason: '$uri: todos, na ordem da tela da pedaleira');
      for (final t in oficiais) {
        final (slot, coluna) = lidos[t.id]!;
        expect(t.valores, _lidoDaPedaleira(slot, coluna), reason: '${t.id} = bloco $coluna do $slot');
        expect(t.valores!.keys.toSet(), simbolos, reason: '${t.id} define todos os parâmetros do bloco');
      }
    }
  });

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

  test('should_name_and_describe_the_official_templates_also_in_french', () {
    final faltando = [
      for (final uri in templates.uris)
        for (final t in _oficiais(templates, uri))
          for (final texto in [t.nome, t.descricao])
            if ((texto.porIdioma['fr'] ?? '').isEmpty) t.id,
    ];

    expect(faltando, isEmpty);
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

  test('should_list_the_twelve_axioma_templates_in_screen_order_and_keep_them_unavailable', () {
    final oficiais = _oficiais(templates, 'urn:darkglass:axioma_synth');

    expect(oficiais.map((t) => t.nome.em('en')), [
      'Filthy Funk', "80's Pop", 'Percussive Sub', 'Fuzzy Filter', 'Solid Gold', '808 Sub Bass', //
      'Mougish', 'Silky Bass', 'Acid Reptile', 'Synthwave', 'Big Swell', 'Burning Bass',
    ]);
    expect(oficiais.where((t) => t.disponivel), isEmpty, reason: 'valores do Axioma ainda não lidos da pedaleira');
    expect(templates.de('urn:darkglass:ignissor').last.origem, OrigemTemplate.app, reason: 'os do app vêm depois');
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
