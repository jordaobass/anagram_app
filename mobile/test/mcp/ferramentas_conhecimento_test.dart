// As ferramentas de conhecimento são o que a IA lê antes de mexer: acham o
// bloco pela uri com ou sem sufixo de canal e pelo nome, listam por família
// em páginas, explicam um tópico, devolvem uma receita cujos passos as outras
// ferramentas aceitam, e NUNCA estouram o limite de tamanho — para qualquer
// bloco, tópico, receita ou página. Nenhuma delas precisa de pedaleira.
import 'dart:convert';

import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/aplicacao/mcp/ferramentas_ajuste.dart';
import 'package:anagram_app/aplicacao/mcp/ferramentas_cadeia.dart';
import 'package:anagram_app/aplicacao/mcp/ferramentas_conhecimento.dart';
import 'package:anagram_app/aplicacao/mcp/sessao_mcp.dart';
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/nucleo/catalogo/familia_bloco.dart';
import 'package:anagram_app/nucleo/conhecimento/base_conhecimento.dart';
import 'package:anagram_app/nucleo/mcp/ferramenta_mcp.dart';
import 'package:anagram_app/nucleo/modelo/documento_preset.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';

final _sessaoProvider = Provider<SessaoMcp>(SessaoMcp.new);

/// App com catálogo e conhecimento carregados, sem pedaleira.
Future<ProviderContainer> _app() async {
  final container = ProviderContainer(overrides: [
    presetsDemonstracaoProvider.overrideWith((ref) async => lerPresetsDemonstracao()),
    catalogoProvider.overrideWith((ref) async => lerCatalogo()),
    indiceMiniaturasProvider.overrideWith((ref) async => lerIndiceMiniaturas()),
    explicacoesProvider.overrideWith((ref) async => lerExplicacoes()),
    conhecimentoProvider.overrideWith((ref) async => lerConhecimento()),
  ]);
  addTearDown(container.dispose);
  await container.read(catalogoProvider.future);
  await container.read(explicacoesProvider.future);
  await container.read(conhecimentoProvider.future);
  return container;
}

Future<Map<String, dynamic>> _dados(FerramentaMcp ferramenta, Map<String, dynamic> argumentos) async {
  final resultado = await ferramenta.executar(argumentos);
  expect(resultado.erro, isFalse, reason: resultado.texto);
  return jsonDecode(resultado.texto) as Map<String, dynamic>;
}

void main() {
  test('should_describe_a_block_by_uri_with_or_without_the_channel_suffix_and_by_name', () async {
    final container = await _app();
    final guia = LerGuiaDeBloco(container.read(_sessaoProvider));

    final porBase = await _dados(guia, {'type': 'urn:darkglass:fil4'});
    final porMono = await _dados(guia, {'type': 'urn:darkglass:fil4#mono'});
    final porEstereo = await _dados(guia, {'type': 'urn:darkglass:fil4#stereo'});
    final porNome = await _dados(guia, {'type': 'chorus'});
    final entropia = await _dados(guia, {'type': 'urn:darkglass:entropia'});

    expect(porBase['name'], startsWith('Parametric EQ'), reason: 'sem sufixo, o catálogo escolhe uma variante');
    expect(porMono['name'], 'Parametric EQ (mono)');
    expect(porEstereo['name'], 'Parametric EQ (stereo)');
    expect(porEstereo['role'], porMono['role'], reason: 'mono e estéreo dividem o guia');
    expect(porNome['type'], 'urn:darkglass:Chorus', reason: 'o nome acha o efeito; as variantes vêm listadas');
    expect(porNome['variants'], containsAll(['urn:darkglass:Chorus', 'urn:darkglass:ChorusStereo']));
    final chave = (entropia['key_parameters'] as List).cast<Map<String, dynamic>>();
    expect(chave.map((p) => p['symbol']), contains('mid_drive_typemode'));
    expect(chave.firstWhere((p) => p['symbol'] == 'mid_drive_typemode')['options'], contains('B3K Grunt'),
        reason: 'a faixa e as opções vêm do catálogo, não da curadoria');
    expect(chave.every((p) => (p['tip'] as String).isNotEmpty), isTrue, reason: 'todo parâmetro-chave tem dica');
    expect(entropia['pitfalls'], isNotEmpty);
  });

  test('should_refuse_an_unknown_block_and_list_the_options_when_a_name_is_ambiguous', () async {
    final container = await _app();
    final guia = LerGuiaDeBloco(container.read(_sessaoProvider));

    await expectLater(guia.executar({'type': 'banjo'}), throwsA(isA<RecusaFerramenta>()));
    await expectLater(
        guia.executar({'type': 'reverb'}),
        throwsA(isA<RecusaFerramenta>().having((r) => r.mensagem, 'mensagem', contains('urn:darkglass:HallReverb'))));
  });

  test('should_list_a_family_in_pages_and_the_families_when_nothing_is_asked', () async {
    final container = await _app();
    final guia = LerGuiaDeBloco(container.read(_sessaoProvider));

    final familias = await _dados(guia, const {});
    final pagina1 = await _dados(guia, {'family': 'utilitario', 'page': 1});
    final pagina2 = await _dados(guia, {'family': 'utilitario', 'page': 2});
    final drives = await _dados(guia, {'family': 'drive'});

    expect((familias['families'] as List).map((f) => (f as Map)['family']), contains('drive'));
    expect(pagina1['total_pages'], greaterThanOrEqualTo(2), reason: 'utilitários não cabem numa página');
    expect((pagina1['blocks'] as List).length, 15);
    expect(pagina2['page'], 2);
    expect((pagina2['blocks'] as List), isNotEmpty);
    expect(((drives['blocks'] as List).first as Map)['role'], isNotEmpty, reason: 'cada linha diz o papel');
  });

  test('should_explain_a_tone_building_topic_and_list_the_topics_without_one', () async {
    final container = await _app();
    final guia = LerGuiaDeTimbre(container.read(_sessaoProvider));

    final lista = await _dados(guia, const {});
    final gain = await _dados(guia, {'topic': 'gain_staging'});

    expect((lista['topics'] as List).map((t) => (t as Map)['topic']), TopicosTimbre.todos);
    expect(gain['points'], isNotEmpty);
    await expectLater(guia.executar({'topic': 'cooking'}), throwsA(isA<RecusaFerramenta>()));
  });

  test('should_return_a_recipe_whose_steps_the_chain_tools_accept_and_refuse_an_unknown_reference', () async {
    final container = await _app();
    final receita = LerReceitaDeTimbre(container.read(_sessaoProvider));

    final harris = await _dados(receita, {'query': 'steve harris tone'});
    final lista = await _dados(receita, const {});

    expect(harris['recipe'], 'steve_harris');
    expect(harris['ask_the_player'], isNotEmpty);
    for (final passo in (harris['chain'] as List).cast<Map<String, dynamic>>()) {
      expect(passo.keys, containsAll(['row', 'column', 'type', 'name']));
      expect(passo.containsKey('missing_from_catalog'), isFalse, reason: passo['type'].toString());
    }
    expect((lista['recipes'] as List).length, greaterThanOrEqualTo(15));
    await expectLater(
        receita.executar({'query': 'polka accordion'}),
        throwsA(isA<RecusaFerramenta>().having((r) => r.mensagem, 'mensagem', contains('funk_slap'))));
  });

  test('should_build_a_parallel_recipe_on_an_empty_preset_in_the_order_the_recipe_gives', () async {
    final container = await _app();
    await container.read(conexaoProvider.notifier).conectarDemonstracao();
    await container.read(editorProvider.notifier).carregarDocumento(DocumentoPreset.vazio('Receita'));
    final sessao = container.read(_sessaoProvider);
    final receita = await _dados(LerReceitaDeTimbre(sessao), {'query': 'modern metal'});

    for (final passo in (receita['chain'] as List).cast<Map<String, dynamic>>()) {
      final posicao = {'row': passo['row'], 'column': passo['column']};
      await _dados(AdicionarBloco(sessao), {...posicao, 'type': passo['type']});
      for (final ajuste in ((passo['settings'] as Map?) ?? const {}).entries) {
        await _dados(MudarParametro(sessao), {...posicao, 'parameter': ajuste.key, 'value': ajuste.value});
      }
    }

    final preset = container.read(editorProvider).atual!;
    // o último set_parameter deixa um envio ao vivo em voo: drená-lo antes de fechar o container
    await container.read(editorProvider.notifier).aplicarDocumento(preset);
    expect(preset.blocosDaLinha(2), isNotEmpty, reason: 'a linha paralela foi montada');
    expect(preset.blocosDaLinha(1).length + preset.blocosDaLinha(2).length, (receita['chain'] as List).length);
  });

  test('should_keep_every_answer_under_the_response_limit_for_every_block_topic_recipe_and_page', () async {
    final container = await _app();
    final sessao = container.read(_sessaoProvider);
    final guiaBloco = LerGuiaDeBloco(sessao);
    final guiaTimbre = LerGuiaDeTimbre(sessao);
    final receitas = LerReceitaDeTimbre(sessao);
    final estouros = <String>[];
    Future<void> medir(String rotulo, FerramentaMcp f, Map<String, dynamic> args) async {
      final resultado = await f.executar(args);
      if (resultado.texto.length > limiteCaracteresResposta) estouros.add('$rotulo: ${resultado.texto.length}');
    }

    for (final bloco in sessao.catalogo().todos) {
      await medir(bloco.uri, guiaBloco, {'type': bloco.uri});
    }
    for (final familia in FamiliaBloco.values) {
      await medir('family ${familia.name}', guiaBloco, {'family': familia.name});
    }
    for (final topico in TopicosTimbre.todos) {
      await medir('topic $topico', guiaTimbre, {'topic': topico});
    }
    await medir('topics', guiaTimbre, const {});
    await medir('recipes', receitas, const {});
    for (final receita in (await sessao.conhecimento()).receitas.receitas) {
      await medir('recipe ${receita.id}', receitas, {'query': receita.id.replaceAll('_', ' ')});
    }

    expect(estouros, isEmpty, reason: 'acima de $limiteCaracteresResposta caracteres:\n${estouros.join('\n')}');
  });
}
