// Os dez controles físicos da Anagram (3 footswitches, 6 pots e o pedal de
// expressão), como o preset os guarda em `bindings`:
//   "pot1": {"name": "Wet", "parameters": [{"block": 5, "row": 2,
//            "symbol": "Wet", "min": 0, "max": 10}], "properties": [], "value": 6.8}
// Leitura só de fachada sobre o JSON cru: o que o app não conhece
// (`properties`, chaves novas de firmware) continua no mapa e volta intacto.
// As escritas mexem num preset cru já copiado (ver [DocumentoPreset.comControles]).
import 'bloco_preset.dart';
import 'json_util.dart';

/// O alvo que liga e desliga o bloco inteiro (footswitch típico).
const simboloBypass = ':bypass';

enum TipoControle { footswitch, pot, expressao }

/// Um controle físico, pela chave que o preset usa.
enum IdControle {
  foot1('foot1', TipoControle.footswitch, 1),
  foot2('foot2', TipoControle.footswitch, 2),
  foot3('foot3', TipoControle.footswitch, 3),
  pot1('pot1', TipoControle.pot, 1),
  pot2('pot2', TipoControle.pot, 2),
  pot3('pot3', TipoControle.pot, 3),
  pot4('pot4', TipoControle.pot, 4),
  pot5('pot5', TipoControle.pot, 5),
  pot6('pot6', TipoControle.pot, 6),
  expressao('exp.pedal', TipoControle.expressao, 1);

  const IdControle(this.chave, this.tipo, this.numero);

  final String chave;
  final TipoControle tipo;
  final int numero;

  static IdControle? daChave(String chave) {
    for (final id in values) {
      if (id.chave == chave) return id;
    }
    return null;
  }

  static List<IdControle> doTipo(TipoControle tipo) => [for (final id in values) if (id.tipo == tipo) id];
}

/// Um parâmetro de um bloco que o controle move, de [minimo] a [maximo].
class AlvoControle {
  const AlvoControle(this.bruto);

  final Map<String, dynamic> bruto;

  PosicaoBloco get posicao =>
      PosicaoBloco(numeroOuNulo(bruto['row'])?.toInt() ?? 0, numeroOuNulo(bruto['block'])?.toInt() ?? 0);
  String get simbolo => textoOuNulo(bruto['symbol']) ?? '';
  bool get ehBypass => simbolo == simboloBypass;

  /// Nulos quando o preset não traz a faixa (presets de fábrica às vezes omitem).
  num? get minimo => numeroOuNulo(bruto['min']);
  num? get maximo => numeroOuNulo(bruto['max']);

  bool mesmoParametro(PosicaoBloco outra, String outroSimbolo) => posicao == outra && simbolo == outroSimbolo;
}

class ControlePedaleira {
  const ControlePedaleira(this.id, this.bruto);

  /// O maior nome visto nos presets reais (fábrica: "Mint Chocolate Chorus").
  /// Quanto o visor da pedaleira mostra é hipótese de bancada (DECISOES BD6).
  static const maiorNomeConhecido = 21;

  final IdControle id;
  final Map<String, dynamic> bruto;

  String get nome => textoOuNulo(bruto['name']) ?? '';
  num? get valor => numeroOuNulo(bruto['value']);

  List<AlvoControle> get alvos {
    final lista = bruto['parameters'];
    if (lista is! List<dynamic>) return const [];
    return [for (final alvo in lista.whereType<Map<String, dynamic>>()) AlvoControle(alvo)];
  }
}

/// Os controles que o preset usa; chave desconhecida fica de fora da leitura
/// (mas continua no arquivo).
Map<IdControle, ControlePedaleira> lerControles(Map<String, dynamic> preset) {
  final vinculos = mapaOuVazio(preset['bindings']);
  return {
    for (final id in IdControle.values)
      if (vinculos[id.chave] case final Map<String, dynamic> bruto) id: ControlePedaleira(id, bruto),
  };
}

/// O que se atribui: o parâmetro, a faixa e o valor que ele tem agora.
class NovoAlvo {
  const NovoAlvo({
    required this.posicao,
    required this.simbolo,
    required this.minimo,
    required this.maximo,
    required this.valorAtual,
    required this.nomePadrao,
  });

  final PosicaoBloco posicao;
  final String simbolo;
  final num minimo;
  final num maximo;
  final num valorAtual;

  /// Nome do controle quando ele ainda não existe.
  final String nomePadrao;

  /// As chaves em ordem alfabética, como a pedaleira grava.
  Map<String, dynamic> paraJson() =>
      {'block': posicao.casa, 'max': maximo, 'min': minimo, 'row': posicao.linha, 'symbol': simbolo};
}

Map<String, dynamic> _vinculos(Map<String, dynamic> preset) {
  final atual = preset['bindings'];
  if (atual is Map<String, dynamic>) return atual;
  return preset['bindings'] = <String, dynamic>{};
}

List<dynamic>? _alvosBrutos(Map<String, dynamic> preset, IdControle id) {
  final lista = mapaOuVazio(_vinculos(preset)[id.chave])['parameters'];
  return lista is List<dynamic> ? lista : null;
}

/// Um parâmetro move um controle só: atribuí-lo a [id] o tira de onde
/// estava (o controle que fica sem alvo sai, como em [soltarVinculos]).
void atribuirAlvo(Map<String, dynamic> preset, IdControle id, NovoAlvo alvo) {
  for (final outro in IdControle.values) {
    if (outro != id) _tirarParametro(preset, outro, alvo.posicao, alvo.simbolo);
  }
  final controle = _controleOuNovo(preset, id, alvo.nomePadrao);
  final alvos = controle['parameters'] as List<dynamic>;
  final existente =
      alvos.indexWhere((a) => a is Map<String, dynamic> && AlvoControle(a).mesmoParametro(alvo.posicao, alvo.simbolo));
  if (existente >= 0) {
    (alvos[existente] as Map<String, dynamic>)
      ..['min'] = alvo.minimo
      ..['max'] = alvo.maximo;
  } else {
    alvos.add(alvo.paraJson());
  }
  controle['value'] = alvo.valorAtual;
}

/// O controle [id] com uma lista de alvos; criado como nos presets reais
/// (`properties` vazia) quando o preset ainda não o tem.
Map<String, dynamic> _controleOuNovo(Map<String, dynamic> preset, IdControle id, String nome) {
  final vinculos = _vinculos(preset);
  final atual = vinculos[id.chave];
  final controle = atual is Map<String, dynamic>
      ? atual
      : vinculos[id.chave] = <String, dynamic>{'name': nome, 'parameters': <dynamic>[], 'properties': <dynamic>[]};
  if (controle['parameters'] is! List<dynamic>) controle['parameters'] = <dynamic>[];
  return controle;
}

void _tirarParametro(Map<String, dynamic> preset, IdControle id, PosicaoBloco posicao, String simbolo) {
  final alvos = _alvosBrutos(preset, id);
  if (alvos == null) return;
  alvos.removeWhere((a) => a is Map<String, dynamic> && AlvoControle(a).mesmoParametro(posicao, simbolo));
  if (alvos.isEmpty) _vinculos(preset).remove(id.chave);
}

/// Tira o alvo [indice]; o controle que fica sem nenhum sai do preset.
void removerAlvo(Map<String, dynamic> preset, IdControle id, int indice) {
  final alvos = _alvosBrutos(preset, id);
  if (alvos == null || indice < 0 || indice >= alvos.length) return;
  alvos.removeAt(indice);
  if (alvos.isEmpty) _vinculos(preset).remove(id.chave);
}

void removerControle(Map<String, dynamic> preset, IdControle id) => _vinculos(preset).remove(id.chave);

void renomearControle(Map<String, dynamic> preset, IdControle id, String nome) {
  final controle = _vinculos(preset)[id.chave];
  if (controle is Map<String, dynamic>) controle['name'] = nome;
}

void mudarFaixaDoAlvo(Map<String, dynamic> preset, IdControle id, int indice, num minimo, num maximo) {
  final alvos = _alvosBrutos(preset, id);
  if (alvos == null || indice < 0 || indice >= alvos.length) return;
  final alvo = alvos[indice];
  if (alvo is Map<String, dynamic>) {
    alvo
      ..['min'] = minimo
      ..['max'] = maximo;
  }
}
