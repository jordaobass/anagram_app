// Metadados de bloco lidos de blocks-factory.json (get_plugin_info do
// firmware v1.18.1.23): nome, categoria e faixas reais dos parâmetros.
import 'familia_bloco.dart';
import 'variantes_uri.dart';

class DefinicaoParametro {
  const DefinicaoParametro({
    required this.simbolo,
    required this.nome,
    required this.minimo,
    required this.maximo,
    required this.padrao,
    this.unidade,
    this.alternavel = false,
    this.inteiro = false,
    this.logaritmico = false,
    this.opcoes = const [],
    this.papel,
    this.pontos = const {},
  });

  factory DefinicaoParametro.doJson(Map<String, dynamic> json) => DefinicaoParametro(
        simbolo: json['symbol'] as String,
        nome: json['name'] as String? ?? json['symbol'] as String,
        minimo: (json['min'] as num?) ?? 0,
        maximo: (json['max'] as num?) ?? 1,
        padrao: (json['def'] as num?) ?? 0,
        unidade: json['unit'] as String?,
        alternavel: json['toggle'] == true,
        inteiro: json['integer'] == true,
        logaritmico: json['log'] == true,
        opcoes: [for (final o in (json['options'] as List<dynamic>? ?? const [])) '$o'],
        papel: json['role'] as String?,
        pontos: {
          for (final p in (json['points'] as List<dynamic>? ?? const []))
            (p as Map<String, dynamic>)['value'] as num: '${p['label']}',
        },
      );

  final String simbolo;
  final String nome;
  final num minimo;
  final num maximo;
  final num padrao;
  final String? unidade;
  final bool alternavel;
  final bool inteiro;
  final bool logaritmico;
  final List<String> opcoes;
  final String? papel;

  /// Valores com nome próprio no plugin, fora das opções ("Listening" no
  /// tempo 0 do metrônomo, "-Inf" no mínimo do Level): o visor da pedaleira
  /// mostra o nome, e o app também.
  final Map<num, String> pontos;

  /// O rótulo do valor que tem nome próprio, ou nulo.
  String? rotuloDoPonto(num valor) {
    for (final p in pontos.entries) {
      if ((p.key - valor).abs() < _toleranciaDoPonto) return p.value;
    }
    return null;
  }

  static const _toleranciaDoPonto = 1e-4;

  /// A mesma faixa com a unidade que o catálogo não traz (o "bpm" do tempo,
  /// que a pedaleira não informa) e, se pedido, só valores inteiros.
  DefinicaoParametro comUnidade(String unidade, {bool inteiro = false}) => DefinicaoParametro(
        simbolo: simbolo,
        nome: nome,
        minimo: minimo,
        maximo: maximo,
        padrao: padrao,
        unidade: unidade,
        alternavel: alternavel,
        inteiro: inteiro || this.inteiro,
        logaritmico: logaritmico,
        opcoes: opcoes,
        papel: papel,
        pontos: pontos,
      );

  bool get ehDiscreto => alternavel || inteiro || opcoes.isNotEmpty;

  /// Parâmetro liga/desliga: o aparelho guarda 0 ou 1, mas um valor no meio
  /// (preset editado à mão) conta como ligado da metade para cima.
  static bool estaLigado(num valor) => valor >= 0.5;

  /// Valor gravado de cada opção. O catálogo só dá min/max: quando os
  /// rótulos são números dentro da faixa ("2:1" … "100:1"), eles são o
  /// valor; senão as opções andam de 1 em 1 ou se espalham de min a max.
  List<num> get valoresOpcoes {
    if (opcoes.length < 2) return [minimo];
    final numeros = [for (final o in opcoes) num.tryParse(RegExp(r'^-?[\d.]+').stringMatch(o) ?? '')];
    final todos = numeros.whereType<num>().toList();
    if (todos.length == opcoes.length && todos.first == minimo && todos.last == maximo) return todos;
    if (maximo - minimo == opcoes.length - 1) return [for (var i = 0; i < opcoes.length; i++) minimo + i];
    return [for (var i = 0; i < opcoes.length; i++) minimo + (maximo - minimo) * i / (opcoes.length - 1)];
  }

  /// Índice da opção cujo valor é o mais próximo.
  int indiceOpcao(num valor) {
    final valores = valoresOpcoes;
    var melhor = 0;
    for (var i = 1; i < valores.length; i++) {
      if ((valores[i] - valor).abs() < (valores[melhor] - valor).abs()) melhor = i;
    }
    return melhor;
  }

  num valorDaOpcao(int indice) => valoresOpcoes[indice.clamp(0, valoresOpcoes.length - 1)];

  num limitar(num valor) {
    final limitado = valor.clamp(minimo, maximo);
    if (opcoes.isNotEmpty) return valorDaOpcao(indiceOpcao(limitado));
    return alternavel || inteiro ? limitado.round() : limitado;
  }
}

/// Vários blocos vêm em versão mono e estéreo com o mesmo nome no catálogo
/// da pedaleira; o canal é o que distingue os dois na tela.
enum CanalBloco { unico, mono, estereo }

class DefinicaoBloco {
  const DefinicaoBloco({
    required this.uri,
    required this.nome,
    required this.abreviacao,
    required this.categoria,
    required this.parametros,
    this.canal = CanalBloco.unico,
  });

  factory DefinicaoBloco.doJson(String uri, Map<String, dynamic> json) => DefinicaoBloco(
        uri: uri,
        nome: json['name'] as String? ?? uri,
        abreviacao: json['abbr'] as String? ?? '',
        categoria: json['category'] as String? ?? '',
        parametros: [
          for (final p in (json['params'] as List<dynamic>? ?? const []))
            DefinicaoParametro.doJson(p as Map<String, dynamic>),
        ],
      );

  /// Bloco que não está no catálogo (comprado no Marketplace, firmware novo):
  /// mostra o fim da uri e os parâmetros que o preset guardar.
  /// A mesma definição com o canal marcado (só o catálogo sabe se há gêmeo).
  DefinicaoBloco comCanal(CanalBloco canal) => DefinicaoBloco(
      uri: uri, nome: nome, abreviacao: abreviacao, categoria: categoria, parametros: parametros, canal: canal);

  factory DefinicaoBloco.desconhecido(String uri) {
    // o sufixo de canal não é nome: "…:Chorus#stereo" se chama Chorus
    final fim = semSufixoDeCanal(uri).split(RegExp('[:/]')).lastWhere((p) => p.isNotEmpty, orElse: () => uri);
    return DefinicaoBloco(uri: uri, nome: fim, abreviacao: '', categoria: '', parametros: const []);
  }

  final CanalBloco canal;
  final String uri;
  final String nome;
  final String abreviacao;
  final String categoria;
  final List<DefinicaoParametro> parametros;

  FamiliaBloco get familia => FamiliaBloco.de(uri: uri, nome: nome, categoria: categoria);

  DefinicaoParametro? parametro(String simbolo) {
    for (final p in parametros) {
      if (p.simbolo == simbolo) return p;
    }
    return null;
  }
}
