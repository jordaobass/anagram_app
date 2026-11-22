// Ferramentas que só ensinam: o guia de cada bloco, o guia de construção de
// timbre por tópico e as receitas por estilo ou referência. Nenhuma mexe no
// preset nem exige pedaleira conectada: a IA pode estudar antes de agir.
// O conhecimento também sai como recurso e prompt para os clientes que os
// leem (DECISOES IC3), mas a ferramenta é o caminho que todo cliente tem.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../nucleo/catalogo/biblioteca_blocos.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/catalogo/familia_bloco.dart';
import '../../nucleo/conhecimento/base_conhecimento.dart';
import '../../nucleo/mcp/ferramenta_mcp.dart';
import '../../nucleo/mcp/prompt_timbre.dart';
import '../../nucleo/mcp/recursos_mcp.dart';
import '../provedores.dart';
import 'descricao_guia_bloco.dart';
import 'descricao_preset.dart';
import 'sessao_mcp.dart';

/// Teto de uma resposta destas ferramentas, em caracteres (~1.800 tokens):
/// o que um modelo local lê sem estourar a janela. O teste confere cada
/// bloco, tópico, receita e página contra ele.
const limiteCaracteresResposta = 7000;

/// Blocos por página na lista por família.
const _blocosPorPagina = 15;

class LerGuiaDeBloco extends FerramentaMcp {
  const LerGuiaDeBloco(this.sessao);
  final SessaoMcp sessao;

  @override
  String get nome => 'get_block_guide';

  @override
  String get descricao => 'What a block does to a bass tone and how to set it: role, what it models, the key '
      'parameters with ranges and tips, a starting point with its source, pitfalls and blocks it pairs with. '
      'Give "type" (a block uri from get_current_preset or list_block_types; "#mono"/"#stereo" optional, a '
      'block name also works) for one block, or "family" for a paged list of blocks with one-line roles. '
      'Read it before changing a block you do not know.';

  @override
  Map<String, dynamic> get esquema => esquemaObjeto({
        'type': texto('Block uri or name, for the full guide of one block.'),
        'family': {
          'type': 'string',
          'enum': [for (final f in FamiliaBloco.values) f.name],
          'description': 'List the blocks of this family instead (15 per page).',
        },
        'page': inteiro('Page of the family list, from 1.', minimo: 1),
      });

  @override
  Future<ResultadoFerramenta> executar(Map<String, dynamic> argumentos) async {
    final descricao = DescricaoGuiaBloco(await sessao.explicacoes());
    final guia = (await sessao.conhecimento()).guiaBlocos;
    if (argumentos.textoOpcional('type') case final tipo?) {
      final definicao = _definicao(tipo);
      return ResultadoFerramenta.dados(descricao.bloco(definicao, guia.de(definicao.uri)));
    }
    final familia = FamiliaBloco.values.where((f) => f.name == argumentos['family']).firstOrNull;
    if (familia == null) return ResultadoFerramenta.dados(_familias());
    return ResultadoFerramenta.dados(_pagina(familia, argumentos['page'] is num ? argumentos.inteiroObrigatorio('page') : 1, descricao, guia));
  }

  /// A uri exata (com ou sem sufixo de canal) ou um nome; nome ambíguo
  /// devolve as opções, salvo quando são as variantes mono/estéreo do mesmo bloco.
  DefinicaoBloco _definicao(String pedido) {
    final catalogo = sessao.catalogo();
    final exata = catalogo.definicao(pedido);
    if (exata.parametros.isNotEmpty) return exata;
    final candidatos = blocosDaBiblioteca(catalogo, busca: pedido).expand((g) => g.blocos).toList();
    if (candidatos.isEmpty) throw RecusaFerramenta('Unknown block "$pedido". Use list_block_types to find the type.');
    final mesmoEfeito = candidatos.every((c) => c.nome == candidatos.first.nome);
    if (candidatos.length == 1 || mesmoEfeito) return candidatos.first;
    final opcoes = candidatos.map((c) => '${c.uri} (${DescricaoPreset.nomeDoBloco(c)})').join('; ');
    throw RecusaFerramenta('"$pedido" matches several blocks: $opcoes. Call again with the uri.');
  }

  Map<String, dynamic> _familias() {
    final grupos = blocosDaBiblioteca(sessao.catalogo());
    return {
      'families': [for (final g in grupos) {'family': g.familia.name, 'blocks': g.blocos.length}],
      'hint': 'Call again with "family" for the blocks of one family, or "type" for one block.',
    };
  }

  Map<String, dynamic> _pagina(FamiliaBloco familia, int pagina, DescricaoGuiaBloco descricao, GuiaBlocos guia) {
    final blocos = blocosDaBiblioteca(sessao.catalogo(), familia: familia).expand((g) => g.blocos).toList();
    final paginas = blocos.isEmpty ? 1 : (blocos.length / _blocosPorPagina).ceil();
    final atual = pagina.clamp(1, paginas);
    final inicio = (atual - 1) * _blocosPorPagina;
    return {
      'family': familia.name,
      'page': atual,
      'total_pages': paginas,
      'blocks': [
        for (final b in blocos.skip(inicio).take(_blocosPorPagina)) descricao.resumo(b, guia.de(b.uri)),
      ],
      'hint': 'Call with "type" for the full guide of one block.',
    };
  }
}

class LerGuiaDeTimbre extends FerramentaMcp {
  const LerGuiaDeTimbre(this.sessao);
  final SessaoMcp sessao;

  @override
  String get nome => 'get_tone_building_guide';

  @override
  String get descricao => 'How to build a bass tone on this pedal, by topic: workflow with the player, '
      'chain_order, gain_staging (avoid clipping, which knob is gain vs level), parallel (Split/Merge, '
      'crossover), eq (frequencies on a bass), compression, drive, cabinets, scenes, time_and_modulation. '
      'Without "topic" it lists the topics with a one-line summary.';

  @override
  Map<String, dynamic> get esquema => esquemaObjeto({
        'topic': {'type': 'string', 'enum': TopicosTimbre.todos, 'description': 'The topic to read.'},
      });

  @override
  Future<ResultadoFerramenta> executar(Map<String, dynamic> argumentos) async {
    final guia = (await sessao.conhecimento()).guiaTimbre;
    if (guia.topicos.isEmpty) throw const RecusaFerramenta('The tone guide is not available in this build.');
    final pedido = argumentos.textoOpcional('topic');
    if (pedido == null) {
      return ResultadoFerramenta.dados({
        'topics': [for (final t in guia.topicos) {'topic': t.id, 'title': t.titulo, 'summary': t.resumo}],
      });
    }
    final topico = guia.topico(pedido) ??
        (throw RecusaFerramenta('Unknown topic "$pedido". Topics: ${TopicosTimbre.todos.join(', ')}.'));
    return ResultadoFerramenta.dados({'topic': topico.id, 'title': topico.titulo, 'summary': topico.resumo, 'points': topico.pontos});
  }
}

class LerReceitaDeTimbre extends FerramentaMcp {
  const LerReceitaDeTimbre(this.sessao);
  final SessaoMcp sessao;

  @override
  String get nome => 'get_tone_recipe';

  @override
  String get descricao => 'A starting chain for a style (rock, metal, punk, funk/slap, jazz, motown, reggae, '
      'synth bass, fuzz, pop, ambient) or a player reference (e.g. "Steve Harris", "Flea"): the idea of the '
      'sound, the blocks with row, column and settings ready for add_block and set_parameter, what to ask '
      'the player, scene ideas and how much to trust it. Without "query" it lists the recipes.';

  @override
  Map<String, dynamic> get esquema => esquemaObjeto({
        'query': texto('Style, genre, band or player, in a few words.'),
      });

  @override
  Future<ResultadoFerramenta> executar(Map<String, dynamic> argumentos) async {
    final receitas = (await sessao.conhecimento()).receitas;
    if (receitas.receitas.isEmpty) throw const RecusaFerramenta('Tone recipes are not available in this build.');
    final pedido = argumentos.textoOpcional('query');
    if (pedido == null) return ResultadoFerramenta.dados({'recipes': _lista(receitas.receitas)});
    final achadas = receitas.buscar(pedido);
    if (achadas.isEmpty) {
      throw RecusaFerramenta('No recipe matches "$pedido". Pick the closest from: '
          '${receitas.receitas.map((r) => '${r.id} (${r.nome})').join('; ')}; or build from get_tone_building_guide.');
    }
    return ResultadoFerramenta.dados(_receita(achadas.first, achadas.skip(1).take(3)));
  }

  static List<Map<String, dynamic>> _lista(List<ReceitaTimbre> receitas) =>
      [for (final r in receitas) {'id': r.id, 'name': r.nome, 'kind': r.tipo, 'aliases': r.apelidos.take(3).toList()}];

  Map<String, dynamic> _receita(ReceitaTimbre receita, Iterable<ReceitaTimbre> outras) => {
        'recipe': receita.id,
        'name': receita.nome,
        'kind': receita.tipo,
        'idea': receita.ideia,
        'confidence': receita.confianca,
        'chain': [for (final p in receita.cadeia) _passo(p)],
        'ask_the_player': receita.perguntar,
        if (receita.cenas.isNotEmpty) 'scene_ideas': receita.cenas,
        if (receita.observacoes.isNotEmpty) 'notes': receita.observacoes,
        'how_to_apply': 'Add the blocks in this order with add_block (Split before Merge, row 2 after both), then '
            'set_parameter for each setting, a few at a time, asking the player to play between steps. Keep or '
            'drop the cabinet depending on what the pedal feeds.',
        if (outras.isNotEmpty) 'other_matches': [for (final r in outras) r.id],
      };

  Map<String, dynamic> _passo(PassoReceita passo) {
    final definicao = sessao.catalogo().definicao(passo.uri);
    return {
      'row': passo.linha,
      'column': passo.casa,
      'type': passo.uri,
      'name': DescricaoPreset.nomeDoBloco(definicao),
      if (definicao.parametros.isEmpty) 'missing_from_catalog': true,
      if (passo.ajustes.isNotEmpty) 'settings': passo.ajustes,
      'note': ?passo.nota,
    };
  }
}

/// Os três arquivos de conhecimento como recursos MCP, lidos do pacote de assets.
List<RecursoMcp> recursosDoConhecimento(Ref ref) {
  Future<String> Function() leitor(String caminho) => () => ref.read(pacoteAssetsProvider).loadString(caminho);
  return [
    RecursoMcp(
        uri: 'anagram://knowledge/blocks',
        nome: 'Block guide',
        descricao: 'Role, key parameters, starting points and pitfalls of every factory block.',
        ler: leitor(CaminhosAssets.conhecimentoBlocos)),
    RecursoMcp(
        uri: 'anagram://knowledge/tone-building',
        nome: 'Tone building guide',
        descricao: 'Chain order, gain staging, parallel line, EQ, compression, drive, cabinets, scenes.',
        ler: leitor(CaminhosAssets.conhecimentoTimbre)),
    RecursoMcp(
        uri: 'anagram://knowledge/recipes',
        nome: 'Tone recipes',
        descricao: 'Starting chains by style and by player reference.',
        ler: leitor(CaminhosAssets.conhecimentoReceitas)),
  ];
}

/// O prompt de sessão para o cliente que lê prompts.
const promptsDoTimbre = [
  PromptMcp(
    nome: 'tone_session',
    descricao: 'How to run a tone-building session with the player through this server.',
    texto: promptSessaoTimbre,
  ),
];
