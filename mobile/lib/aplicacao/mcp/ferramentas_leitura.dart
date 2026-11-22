// Ferramentas que só leem: o preset aberto e o catálogo de blocos.
import '../../nucleo/catalogo/biblioteca_blocos.dart';
import '../../nucleo/catalogo/familia_bloco.dart';
import '../../nucleo/mcp/ferramenta_mcp.dart';
import 'descricao_preset.dart';
import 'sessao_mcp.dart';

class LerPresetAtual extends FerramentaMcp {
  const LerPresetAtual(this.sessao);
  final SessaoMcp sessao;

  @override
  String get nome => 'get_current_preset';

  @override
  String get descricao => 'Read the preset open in the app: its blocks in signal order (row/column), whether '
      'each is on, every adjustable parameter with current value, range, unit and options, the scenes '
      'and the active one. Call this first, before changing anything, and again after the player edits. '
      'To understand a block you see here, call get_block_guide with its "type".';

  @override
  Map<String, dynamic> get esquema => esquemaObjeto(const {});

  @override
  Future<ResultadoFerramenta> executar(Map<String, dynamic> argumentos) async {
    final documento = sessao.presetAberto();
    final descricao = DescricaoPreset(sessao.definicao, sessao.gabinetes());
    return ResultadoFerramenta.dados(descricao.preset(sessao.estado, documento));
  }
}

class ListarTiposDeBloco extends FerramentaMcp {
  const ListarTiposDeBloco(this.sessao);
  final SessaoMcp sessao;

  @override
  String get nome => 'list_block_types';

  @override
  String get descricao => 'List the effect, amp and cabinet blocks that can be added to the chain. Filter by '
      'family and/or text. Use the returned "type" in add_block and in get_block_guide (which says what the '
      'block does and how to set it). Set include_parameters to see each block\'s parameters and ranges.';

  @override
  Map<String, dynamic> get esquema => esquemaObjeto({
        'family': {
          'type': 'string',
          'enum': [for (final f in FamiliaBloco.values) f.name],
          'description': 'Only blocks of this family.',
        },
        'search': texto('Case-insensitive text in the block name or abbreviation.'),
        'include_parameters': {'type': 'boolean', 'description': 'Also return each parameter (default false).'},
      });

  @override
  Future<ResultadoFerramenta> executar(Map<String, dynamic> argumentos) async {
    final familia = FamiliaBloco.values.where((f) => f.name == argumentos['family']).firstOrNull;
    final grupos = blocosDaBiblioteca(sessao.catalogo(), busca: argumentos.textoOpcional('search') ?? '', familia: familia);
    final comParametros = argumentos['include_parameters'] == true;
    return ResultadoFerramenta.dados([
      for (final grupo in grupos)
        for (final b in grupo.blocos)
          {
            'type': b.uri,
            'name': DescricaoPreset.nomeDoBloco(b),
            'family': grupo.familia.name,
            if (comParametros)
              'parameters': [
                for (final p in DescricaoPreset.parametrosAjustaveis(b)) DescricaoPreset.parametro(p, p.padrao),
              ],
          },
    ]);
  }
}
