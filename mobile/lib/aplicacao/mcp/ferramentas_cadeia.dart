// Ferramentas que mudam a cadeia: pôr, mover e tirar bloco, e escolher o
// gabinete. As regras são as da tela: um Split e um Merge, na linha 1, o
// Merge depois do Split; a linha 2 só recebe sinal com Split.
import '../../nucleo/catalogo/biblioteca_blocos.dart';
import '../../nucleo/catalogo/catalogo_gabinetes.dart';
import '../../nucleo/catalogo/linha_paralela.dart';
import '../../nucleo/mcp/ferramenta_mcp.dart';
import 'descricao_preset.dart';
import 'sessao_mcp.dart';

class AdicionarBloco extends FerramentaMcp {
  const AdicionarBloco(this.sessao);
  final SessaoMcp sessao;

  @override
  String get nome => 'add_block';

  @override
  String get descricao => 'Put a new block (with default settings) in an EMPTY position. Get "type" from '
      'list_block_types. A Split on row 1 sends the signal also to row 2 (from its column 1); a Merge after '
      'it on row 1 joins row 2 (from its column 12) back. One Split and one Merge per preset.';

  @override
  Map<String, dynamic> get esquema => esquemaObjeto(
      {...SessaoMcp.esquemaPosicao(), 'type': texto('Block type from list_block_types.')},
      obrigatorias: const ['row', 'column', 'type']);

  @override
  Future<ResultadoFerramenta> executar(Map<String, dynamic> argumentos) async {
    final posicao = SessaoMcp.posicaoDe(argumentos);
    final documento = sessao.presetAberto();
    final tipo = argumentos.textoObrigatorio('type');
    final definicao = blocosDaBiblioteca(sessao.catalogo()).expand((g) => g.blocos).where((b) => b.uri == tipo).firstOrNull;
    if (definicao == null) throw RecusaFerramenta('Unknown block type "$tipo". Use list_block_types.');
    if (documento.bloco(posicao) != null) {
      throw const RecusaFerramenta('That position is taken. Use remove_block first, or pick an empty column.');
    }
    if (posicao.linha == 2 && !temLinhaParalela(documento)) {
      throw const RecusaFerramenta('Row 2 gets no signal in this preset (no Split on row 1). Add a Split first.');
    }
    if (recusaAoAdicionar(documento, posicao, tipo) case final recusa?) throw RecusaFerramenta(_motivo(recusa));
    await sessao.mudar('+ ${definicao.nome}', () => sessao.editor.adicionarBloco(posicao, definicao));
    final novo = sessao.estado.atual!.bloco(posicao)!;
    return ResultadoFerramenta.dados(DescricaoPreset(sessao.definicao, sessao.gabinetes()).bloco(novo, sessao.estado.atual!.cenaAtiva));
  }
}

String _motivo(RecusaAdicionar recusa) => switch (recusa) {
      RecusaAdicionar.splitRepetido => 'This preset already has a Split (one per preset).',
      RecusaAdicionar.mergeRepetido => 'This preset already has a Merge (one per preset).',
      RecusaAdicionar.mergeSemSplit => 'Add a Split on row 1 before the Merge.',
      RecusaAdicionar.foraDaLinha1 => 'Split and Merge go on row 1.',
      RecusaAdicionar.mergeAntesDoSplit || RecusaAdicionar.splitDepoisDoMerge =>
        'The Split must come before the Merge on row 1.',
    };

class MoverBloco extends FerramentaMcp {
  const MoverBloco(this.sessao);
  final SessaoMcp sessao;

  @override
  String get nome => 'move_block';

  @override
  String get descricao => 'Move a block to another position; if the target is taken, the two blocks swap. '
      'Split and Merge stay on row 1, with the Split before the Merge.';

  @override
  Map<String, dynamic> get esquema => esquemaObjeto(
      {...SessaoMcp.esquemaPosicao(prefixo: 'from_'), ...SessaoMcp.esquemaPosicao(prefixo: 'to_')},
      obrigatorias: const ['from_row', 'from_column', 'to_row', 'to_column']);

  @override
  Future<ResultadoFerramenta> executar(Map<String, dynamic> argumentos) async {
    final origem = sessao.bloco(argumentos, linha: 'from_row', casa: 'from_column');
    final destino = SessaoMcp.posicaoDe(argumentos, linha: 'to_row', casa: 'to_column');
    if (!podeMover(sessao.presetAberto(), origem.posicao, destino)) {
      throw const RecusaFerramenta('This move is not allowed (same place, Split/Merge off row 1, or Split after Merge).');
    }
    final nome = sessao.definicao(origem.uri).nome;
    await sessao.mudar('$nome → ${destino.linha}.${destino.casa}', () => sessao.editor.moverBloco(origem.posicao, destino));
    return ResultadoFerramenta.dados({'moved': nome, 'row': destino.linha, 'column': destino.casa});
  }
}

class RemoverBloco extends FerramentaMcp {
  const RemoverBloco(this.sessao);
  final SessaoMcp sessao;

  @override
  String get nome => 'remove_block';

  @override
  String get descricao => 'Remove a block from the chain. Removing the Split also removes the Merge; it is '
      'refused while row 2 has blocks (remove those first).';

  @override
  Map<String, dynamic> get esquema => esquemaObjeto(SessaoMcp.esquemaPosicao(), obrigatorias: const ['row', 'column']);

  @override
  Future<ResultadoFerramenta> executar(Map<String, dynamic> argumentos) async {
    final bloco = sessao.bloco(argumentos);
    if (bloco.uri == uriSplit && sessao.presetAberto().blocosDaLinha(2).isNotEmpty) {
      throw const RecusaFerramenta('Row 2 still has blocks; remove them first, or let the player remove the Split '
          'in the app (it asks before taking row 2 along).');
    }
    final nome = sessao.definicao(bloco.uri).nome;
    await sessao.mudar('− $nome', () => sessao.editor.removerBloco(bloco.posicao));
    return ResultadoFerramenta.dados({'removed': nome});
  }
}

class EscolherGabinete extends FerramentaMcp {
  const EscolherGabinete(this.sessao);
  final SessaoMcp sessao;

  @override
  String get nome => 'choose_cabinet';

  @override
  String get descricao => 'Pick the cabinet model, microphone and mic position of a cabinet block. A wrong '
      'name returns the valid choices. Microphone and position are optional (kept when the model has them).';

  @override
  Map<String, dynamic> get esquema => esquemaObjeto({
        ...SessaoMcp.esquemaPosicao(),
        'model': texto('Cabinet model, as in available_models.'),
        'microphone': texto('Microphone name (optional).'),
        'position': texto('Mic position (optional).'),
      }, obrigatorias: const ['row', 'column', 'model']);

  @override
  Future<ResultadoFerramenta> executar(Map<String, dynamic> argumentos) async {
    final bloco = sessao.bloco(argumentos);
    final tipo = TipoGabinete.daUri(bloco.uri);
    final catalogo = sessao.gabinetes();
    if (tipo == null || !catalogo.temEscolhas(tipo)) throw const RecusaFerramenta('That block is not a cabinet.');
    final modelo = _escolhido(argumentos.textoObrigatorio('model'), catalogo.modelos(tipo), 'model');
    final atual = catalogo.doArquivo(tipo, bloco.arquivoDeIr);
    final microfone = _opcional(argumentos.textoOpcional('microphone'), catalogo.microfones(tipo, modelo), 'microphone') ?? atual?.microfone;
    final pedidaPosicao = argumentos.textoOpcional('position');
    final opcao = catalogo.escolher(tipo, modelo, microfone: microfone, posicao: pedidaPosicao ?? atual?.posicao)!;
    _opcional(pedidaPosicao, catalogo.posicoes(tipo, modelo, opcao.microfone), 'position');
    await sessao.mudar('${opcao.modelo} · ${opcao.microfone}', () => sessao.editor.escolherIrDoGabinete(bloco.posicao, opcao.caminho));
    return ResultadoFerramenta.dados({'model': opcao.modelo, 'microphone': opcao.microfone, 'position': opcao.posicao});
  }

  /// O nome válido que bate com o pedido sem caixa, ou a recusa com a lista.
  static String _escolhido(String pedido, List<String> validos, String campo) =>
      validos.where((v) => v.toLowerCase() == pedido.toLowerCase()).firstOrNull ??
      (throw RecusaFerramenta('Unknown $campo "$pedido". Valid: ${validos.join(', ')}.'));

  static String? _opcional(String? pedido, List<String> validos, String campo) =>
      pedido == null || validos.isEmpty ? null : _escolhido(pedido, validos, campo);
}
