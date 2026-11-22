// Ferramentas dos controles do preset (footswitches, pots e pedal de
// expressão): ler, atribuir e soltar. Usam as mesmas operações da seção
// "Controles da pedaleira" da tela (DECISOES BD1–BD7) e vão pelo mesmo envio
// ao vivo; só chegam ao slot com Salvar.
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/mcp/ferramenta_mcp.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../../nucleo/modelo/controles_pedaleira.dart';
import '../../nucleo/modelo/documento_preset.dart';
import '../../nucleo/modelo/edicao_controles.dart';
import 'descricao_preset.dart';
import 'ferramentas_ajuste.dart';
import 'sessao_mcp.dart';

/// Os footswitches só seguem os controles do preset no modo Stomp (FM5) e os
/// pots só agem na tela do preset em uma linha (BD10).
const _avisoModo = 'Footswitches obey these assignments only when the pedal is in Stomp mode (see '
    'get_global_settings / set_global_setting "mode"); pots act on their assignments on the pedal\'s one-line '
    'preset screen (with the preset expanded, the knobs edit the selected block).';

/// Nome do controle na ferramenta: a chave do preset, com "exp" para o pedal.
String nomeDoControle(IdControle id) => id == IdControle.expressao ? 'exp' : id.chave;

final _nomesDosControles = [for (final id in IdControle.values) nomeDoControle(id)];

/// O controle pedido em `control`, ou a recusa com os nomes válidos.
IdControle controlePedido(Map<String, dynamic> argumentos) {
  final pedido = argumentos.textoObrigatorio('control').toLowerCase();
  for (final id in IdControle.values) {
    if (nomeDoControle(id) == pedido || id.chave == pedido) return id;
  }
  throw RecusaFerramenta('Unknown control "$pedido". Valid: ${_nomesDosControles.join(', ')}.');
}

Map<String, dynamic> esquemaControle() => {
      'type': 'string',
      'enum': _nomesDosControles,
      'description': 'foot1-foot3 (footswitches), pot1-pot6 (knobs) or exp (expression pedal).',
    };

class LerControles extends FerramentaMcp {
  const LerControles(this.sessao);
  final SessaoMcp sessao;

  @override
  String get nome => 'get_controls';

  @override
  String get descricao => 'Read the preset\'s hardware controls: footswitches foot1-foot3, knobs pot1-pot6 and the '
      'expression pedal exp. For each: its short display name and what it moves (block row/column, parameter, '
      'min/max; "bypass" = turns the block on/off). Free controls have assigned=false. $_avisoModo';

  @override
  Map<String, dynamic> get esquema => esquemaObjeto(const {});

  @override
  Future<ResultadoFerramenta> executar(Map<String, dynamic> argumentos) async {
    final documento = sessao.presetAberto();
    final modo = await sessao.modoFootswitches();
    return ResultadoFerramenta.dados({
      'footswitch_mode': modo?.valor,
      'controls': [for (final id in IdControle.values) descreverControle(sessao, documento, id)],
    });
  }
}

/// O controle [id] como a IA lê: nome, tipo e alvos com bloco e faixa.
Map<String, dynamic> descreverControle(SessaoMcp sessao, DocumentoPreset documento, IdControle id) {
  final controle = documento.controles[id];
  return {
    'control': nomeDoControle(id),
    'type': id.tipo.name,
    'assigned': controle != null && controle.alvos.isNotEmpty,
    'name': ?controle?.nome,
    'targets': [
      for (final alvo in controle?.alvos ?? const <AlvoControle>[])
        {
          'row': alvo.posicao.linha,
          'column': alvo.posicao.casa,
          'block': _nomeDoBloco(sessao, documento.bloco(alvo.posicao)),
          'parameter': alvo.ehBypass ? 'bypass' : alvo.simbolo,
          'min': ?alvo.minimo,
          'max': ?alvo.maximo,
        },
    ],
  };
}

String _nomeDoBloco(SessaoMcp sessao, BlocoPreset? bloco) =>
    bloco == null ? '(empty position)' : DescricaoPreset.nomeDoBloco(sessao.definicao(bloco.uri));

class AtribuirControle extends FerramentaMcp {
  const AtribuirControle(this.sessao);
  final SessaoMcp sessao;

  @override
  String get nome => 'assign_control';

  @override
  String get descricao => 'Assign a hardware control in this preset; heard and shown immediately (not saved). '
      'A footswitch (foot1-foot3) turns the block at row/column on and off: give no parameter. A knob (pot1-pot6) '
      'or the expression pedal (exp) moves one parameter of that block (or "bypass"), over the parameter\'s whole '
      'range unless you give min/max (min > max inverts the control). A control can move several parameters: '
      'assigning another one adds it. A parameter moves only one control: assigning it here removes it from the '
      'control that had it. "name" is the short text on the pedal display (up to 24 characters; 21 or fewer '
      'show best). $_avisoModo';

  @override
  Map<String, dynamic> get esquema => esquemaObjeto({
        'control': esquemaControle(),
        ...SessaoMcp.esquemaPosicao(),
        'parameter': texto('Knob/pedal only: parameter symbol or name from get_current_preset, or "bypass".'),
        'min': {'type': 'number', 'description': 'Knob/pedal only: value at the minimum position.'},
        'max': {'type': 'number', 'description': 'Knob/pedal only: value at the maximum position.'},
        'name': texto('Optional short name shown on the pedal display.'),
      }, obrigatorias: const ['control', 'row', 'column']);

  @override
  Future<ResultadoFerramenta> executar(Map<String, dynamic> argumentos) async {
    final id = controlePedido(argumentos);
    final bloco = sessao.bloco(argumentos);
    final definicao = sessao.definicao(bloco.uri);
    var documento = id.tipo == TipoControle.footswitch
        ? _noFootswitch(id, bloco, definicao, argumentos)
        : _noPot(id, bloco, definicao, argumentos);
    final nome = argumentos.textoOpcional('name');
    if (nome != null) documento = documento.comNomeDoControle(id, nomeValido(nome));
    await sessao.mudar('${nomeDoControle(id).toUpperCase()} → ${definicao.nome}',
        () => sessao.editor.aplicarDocumento(documento));
    return ResultadoFerramenta.dados(descreverControle(sessao, sessao.presetAberto(), id));
  }

  /// Footswitch só liga e desliga o bloco (DECISOES BD7).
  DocumentoPreset _noFootswitch(IdControle id, BlocoPreset bloco, DefinicaoBloco definicao, Map<String, dynamic> argumentos) {
    final parametro = argumentos.textoOpcional('parameter');
    if (parametro != null && parametro.toLowerCase() != 'bypass' && parametro != simboloBypass) {
      throw const RecusaFerramenta('A footswitch only turns a block on/off; call it without "parameter". '
          'To move a parameter, use a knob (pot1-pot6) or the expression pedal (exp).');
    }
    return sessao.presetAberto().comFootswitchNoBloco(id, bloco.posicao, definicao.nome);
  }

  DocumentoPreset _noPot(IdControle id, BlocoPreset bloco, DefinicaoBloco definicao, Map<String, dynamic> argumentos) {
    final pedido = argumentos.textoOpcional('parameter') ??
        (throw const RecusaFerramenta('A knob or the expression pedal needs "parameter" (symbol, name or "bypass").'));
    final parametro = const {'bypass', simboloBypass}.contains(pedido.toLowerCase())
        ? parametroBypass
        : MudarParametro.parametroDoBloco(definicao, bloco, pedido);
    final documento = sessao.presetAberto().comParametroNoControle(id, bloco.posicao, parametro);
    if (argumentos['min'] == null && argumentos['max'] == null) return documento;
    final minimo = _numero(argumentos['min'], 'min') ?? parametro.minimo;
    final maximo = _numero(argumentos['max'], 'max') ?? parametro.maximo;
    if (motivoFaixaInvalida(parametro, minimo, maximo) != null) {
      throw RecusaFerramenta('Invalid range $minimo..$maximo for ${parametro.nome}: min and max must differ and '
          'stay within ${parametro.minimo}..${parametro.maximo}.');
    }
    final indice = documento.controles[id]!.alvos.indexWhere((a) => a.mesmoParametro(bloco.posicao, parametro.simbolo));
    return documento.comFaixaNoAlvo(id, indice, minimo, maximo);
  }

  static num? _numero(Object? valor, String chave) {
    if (valor == null || valor is num) return valor as num?;
    throw RecusaFerramenta('"$chave" must be a number.');
  }
}

class SoltarControle extends FerramentaMcp {
  const SoltarControle(this.sessao);
  final SessaoMcp sessao;

  @override
  String get nome => 'release_control';

  @override
  String get descricao => 'Free a hardware control of this preset (not saved). Without target_index the whole '
      'control is released; with it, only that target (0-based, in the order get_controls lists them). A control '
      'left with no target is released.';

  @override
  Map<String, dynamic> get esquema => esquemaObjeto({
        'control': esquemaControle(),
        'target_index': inteiro('Optional: only this target (0-based).', minimo: 0),
      }, obrigatorias: const ['control']);

  @override
  Future<ResultadoFerramenta> executar(Map<String, dynamic> argumentos) async {
    final id = controlePedido(argumentos);
    final documento = sessao.presetAberto();
    final alvos = documento.controles[id]?.alvos ?? const <AlvoControle>[];
    if (alvos.isEmpty) throw RecusaFerramenta('${nomeDoControle(id)} is already free.');
    final indice = argumentos['target_index'] == null ? null : argumentos.inteiroObrigatorio('target_index');
    if (indice != null && (indice < 0 || indice >= alvos.length)) {
      throw RecusaFerramenta('target_index must be 0-${alvos.length - 1} for ${nomeDoControle(id)}.');
    }
    final solto = indice == null ? documento.semControle(id) : documento.semAlvoNoControle(id, indice);
    await sessao.mudar('${nomeDoControle(id).toUpperCase()} released', () => sessao.editor.aplicarDocumento(solto));
    return ResultadoFerramenta.dados(descreverControle(sessao, sessao.presetAberto(), id));
  }
}

/// O nome aparado, ou a recusa com o motivo (o mesmo do diálogo da tela).
String nomeValido(String nome) {
  final limpo = nome.trim();
  if (limpo.length > tamanhoMaximoNome) {
    throw const RecusaFerramenta('Names can have at most $tamanhoMaximoNome characters.');
  }
  return switch (motivoNomeInvalido(limpo)) {
    null => limpo,
    NomeVazio() => throw const RecusaFerramenta('The name cannot be empty.'),
    NomeComMarcador(:final marcador) =>
      throw RecusaFerramenta('The name cannot contain "$marcador": the pedal reads it as a message marker.'),
  };
}
