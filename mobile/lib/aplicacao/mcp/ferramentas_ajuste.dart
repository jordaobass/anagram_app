// Ferramentas que ajustam o som sem mudar a cadeia: parâmetro, liga/desliga,
// cena e desfazer. Todas passam pelo editor e soam na hora.
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/mcp/ferramenta_mcp.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../../nucleo/modelo/cenas_do_bloco.dart';
import 'descricao_preset.dart';
import 'sessao_mcp.dart';

class MudarParametro extends FerramentaMcp {
  const MudarParametro(this.sessao);
  final SessaoMcp sessao;

  @override
  String get nome => 'set_parameter';

  @override
  String get descricao => 'Change one parameter of a block; it is heard immediately (not saved). The value is a '
      'number in the parameter unit, or an option label for option parameters, or true/false for toggles. '
      'Out-of-range values are clamped and the applied value is returned. Scenes: scope "scene" changes ONLY the '
      'active scene (the others keep what they had). "all_scenes" ERASES the per-scene values of this parameter: '
      'every scene ends up with the same value and the difference between them is lost. Without "scope" it '
      'follows the "Control" switch the player chose in the app, which may be set to all scenes. Always send '
      'scope "scene" explicitly; use "all_scenes" only when the player asks for the same value in every scene. '
      'The result says which scope was applied. Change 2-4 parameters, then ask the player how it sounds before '
      'going on; you cannot hear the result.';

  @override
  Map<String, dynamic> get esquema => esquemaObjeto({
        ...SessaoMcp.esquemaPosicao(),
        'parameter': texto('Parameter symbol (preferred) or name, from get_current_preset.'),
        'value': {
          'type': ['number', 'string', 'boolean'],
          'description': 'New value: number, option label, or true/false.',
        },
        'scope': {
          'type': 'string',
          'enum': [for (final e in _escopos.keys) e],
          'description': '"scene" (recommended) = only the active scene; "all_scenes" = the same value in every '
              'scene, ERASING the per-scene values of this parameter (only when the player asks). Omitted = the app '
              '"Control" switch, which may be set to all scenes.',
        },
      }, obrigatorias: const ['row', 'column', 'parameter', 'value']);

  @override
  Future<ResultadoFerramenta> executar(Map<String, dynamic> argumentos) async {
    final bloco = sessao.bloco(argumentos);
    final definicao = sessao.definicao(bloco.uri);
    final parametro = parametroDoBloco(definicao, bloco, argumentos.textoObrigatorio('parameter'));
    final aplicado = parametro.limitar(valorPedido(parametro, argumentos['value']));
    final escopo = escopoPedido(sessao, argumentos['scope']);
    // o mesmo caminho do knob (comParametro), esperando o envio ao vivo: quando
    // a resposta volta, o valor já está soando
    final editado = sessao.presetAberto().comParametro(bloco.posicao, parametro.simbolo, aplicado,
        nomeExibicao: parametro.nome, escopo: escopo, valorAntes: parametro.padrao);
    await sessao.mudar('${definicao.nome}: ${parametro.nome} = ${DescricaoPreset.exibir(parametro, aplicado)}',
        () => sessao.editor.aplicarDocumento(editado));
    return ResultadoFerramenta.dados({
      'block': DescricaoPreset.nomeDoBloco(definicao),
      'parameter': parametro.simbolo,
      'applied': aplicado,
      'display': DescricaoPreset.exibir(parametro, aplicado),
      'clamped': argumentos['value'] is num && argumentos['value'] != aplicado,
      'scope': nomeDoEscopo(escopo),
    });
  }

  /// Pelo símbolo ou pelo nome, sem caixa; bloco fora do catálogo aceita os
  /// símbolos que o preset guarda, sem faixa.
  static DefinicaoParametro parametroDoBloco(DefinicaoBloco definicao, BlocoPreset bloco, String pedido) {
    final alvo = pedido.toLowerCase();
    for (final p in DescricaoPreset.parametrosAjustaveis(definicao)) {
      if (p.simbolo.toLowerCase() == alvo || p.nome.toLowerCase() == alvo) return p;
    }
    if (definicao.parametros.isEmpty && bloco.simbolosGuardados.contains(pedido)) {
      final atual = bloco.valorBase(pedido) ?? 0;
      return DefinicaoParametro(simbolo: pedido, nome: pedido, minimo: -1e9, maximo: 1e9, padrao: atual);
    }
    final validos = DescricaoPreset.parametrosAjustaveis(definicao).map((p) => p.simbolo).join(', ');
    throw RecusaFerramenta('"${definicao.nome}" has no parameter "$pedido". Valid: $validos.');
  }
}

const _escopos = {'scene': EscopoCenas.soNaCena, 'all_scenes': EscopoCenas.todasAsCenas};

/// O `scope` pedido pela IA; sem ele, o da chave "Controlar" da tela.
EscopoCenas escopoPedido(SessaoMcp sessao, Object? pedido) {
  if (pedido == null) return sessao.escopoDaTela;
  return _escopos[pedido] ?? (throw const RecusaFerramenta('"scope" must be "scene" or "all_scenes" (or omitted).'));
}

String nomeDoEscopo(EscopoCenas escopo) => _escopos.entries.firstWhere((e) => e.value == escopo).key;

/// O valor pedido no tipo do parâmetro: número, rótulo de opção ou liga/desliga.
num valorPedido(DefinicaoParametro parametro, Object? valor) {
  if (valor is bool) return valor ? parametro.maximo : parametro.minimo;
  if (valor is num) return valor;
  if (valor is String) {
    final texto = valor.trim().toLowerCase();
    final indice = parametro.opcoes.indexWhere((o) => o.toLowerCase() == texto);
    if (indice >= 0) return parametro.valorDaOpcao(indice);
    if (parametro.alternavel && const {'on', 'true'}.contains(texto)) return parametro.maximo;
    if (parametro.alternavel && const {'off', 'false'}.contains(texto)) return parametro.minimo;
    if (num.tryParse(texto) case final numero?) return numero;
  }
  final opcoes = parametro.opcoes.isEmpty ? '' : ' Options: ${parametro.opcoes.join(', ')}.';
  throw RecusaFerramenta('Invalid value "$valor" for ${parametro.nome}.$opcoes');
}

class LigarDesligarBloco extends FerramentaMcp {
  const LigarDesligarBloco(this.sessao);
  final SessaoMcp sessao;

  @override
  String get nome => 'set_block_enabled';

  @override
  String get descricao => 'Turn a block on or off (bypass); heard immediately. Scenes work like set_parameter: '
      'scope "scene" = only the active scene; "all_scenes" = every scene, ERASING the per-scene on/off of this '
      'block; without "scope", the app "Control" switch, which may be set to all scenes. Always send scope '
      '"scene" explicitly; use "all_scenes" only when the player asks for it in every scene.';

  @override
  Map<String, dynamic> get esquema => esquemaObjeto({
        ...SessaoMcp.esquemaPosicao(),
        'enabled': {'type': 'boolean', 'description': 'true = on, false = bypassed.'},
        'scope': {
          'type': 'string',
          'enum': [for (final e in _escopos.keys) e],
          'description': '"scene" (recommended) = only the active scene; "all_scenes" = every scene, ERASING the '
              'per-scene on/off (only when the player asks). Omitted = the app "Control" switch.',
        },
      }, obrigatorias: const ['row', 'column', 'enabled']);

  @override
  Future<ResultadoFerramenta> executar(Map<String, dynamic> argumentos) async {
    final bloco = sessao.bloco(argumentos);
    final ligar = argumentos['enabled'];
    if (ligar is! bool) throw const RecusaFerramenta('"enabled" must be true or false.');
    final escopo = escopoPedido(sessao, argumentos['scope']);
    final nome = sessao.definicao(bloco.uri).nome;
    final documento = sessao.presetAberto();
    final cena = documento.cenaAtiva;
    // nada a mudar: já está assim na cena (e, em todas, nenhuma cena difere)
    final jaEsta = bloco.habilitadoNaCena(cena) == ligar &&
        (escopo == EscopoCenas.soNaCena || !bloco.bypassSoNaCena(cena));
    if (jaEsta) return ResultadoFerramenta.dados({'block': nome, 'enabled': ligar, 'scope': nomeDoEscopo(escopo)});
    final editado = documento.comBlocoHabilitado(bloco.posicao, ligar, escopo: escopo);
    await sessao.mudar('$nome: ${ligar ? 'on' : 'off'}', () => sessao.editor.aplicarDocumento(editado));
    return ResultadoFerramenta.dados({'block': nome, 'enabled': ligar, 'scope': nomeDoEscopo(escopo)});
  }
}

class EscolherCena extends FerramentaMcp {
  const EscolherCena(this.sessao);
  final SessaoMcp sessao;

  @override
  String get nome => 'select_scene';

  @override
  String get descricao => 'Switch the active scene. A preset has 3 scenes or more (firmware 1.16+ allows many): '
      'the valid numbers are the "scenes" listed by get_current_preset. Parameter changes made afterwards apply to '
      'that scene.';

  @override
  Map<String, dynamic> get esquema => esquemaObjeto(
      {'scene': inteiro('Scene number, 1 to the number of scenes of the open preset.', minimo: 1, maximo: cenasMaximas)},
      obrigatorias: const ['scene']);

  @override
  Future<ResultadoFerramenta> executar(Map<String, dynamic> argumentos) async {
    final cena = argumentos.inteiroObrigatorio('scene');
    final quantidade = sessao.presetAberto().quantidadeCenas;
    if (cena < 1 || cena > quantidade) throw RecusaFerramenta('"scene" must be 1 to $quantidade (this preset has $quantidade scenes).');
    await sessao.mudar('scene $cena', () => sessao.editor.escolherCena(cena));
    return ResultadoFerramenta.dados({'active_scene': cena});
  }
}

class Desfazer extends FerramentaMcp {
  const Desfazer(this.sessao);
  final SessaoMcp sessao;

  @override
  String get nome => 'undo';

  @override
  String get descricao => 'Undo the last change made through these tools (one step per call).';

  @override
  Map<String, dynamic> get esquema => esquemaObjeto(const {});

  @override
  Future<ResultadoFerramenta> executar(Map<String, dynamic> argumentos) async =>
      ResultadoFerramenta.dados({'undone': true, 'remaining_undo_steps': await sessao.desfazer()});
}
