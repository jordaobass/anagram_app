// Os ajustes GLOBAIS da Anagram (valem para todos os presets) que o app sabe
// ler e gravar por `export_settings` / `edit_settings`. Um lugar só: quando
// descobrirmos a chave de um ajuste pendente (a pedaleira só exporta o que já
// foi mexido), basta preencher [DefinicaoAjuste.chave] aqui (DECISOES PD2).
import '../catalogo/definicao_bloco.dart';

enum GrupoAjuste { saidas, globalEq, entrada }

/// Banda do Global EQ, para o desenho da curva (DECISOES PD4).
enum TipoBandaEq { lowShelf, highShelf }

class DefinicaoAjuste {
  const DefinicaoAjuste({
    required this.id,
    required this.nome,
    required this.grupo,
    required this.minimo,
    required this.maximo,
    required this.padrao,
    this.chave,
    this.unidade,
    this.logaritmico = false,
    this.faixaConfirmada = false,
  });

  /// Identificador estável do app (também o nome usado pelo MCP).
  final String id;

  /// Chave do protocolo, plana e com pontos (`mixer.headphones.vol`). Nula =
  /// ajuste que existe na pedaleira mas cuja chave ainda não conhecemos:
  /// nunca é enviado.
  final String? chave;
  final String nome;
  final GrupoAjuste grupo;
  final num minimo;
  final num maximo;
  final num padrao;
  final String? unidade;
  final bool logaritmico;

  /// A faixa veio do catálogo ou do manual; falso = hipótese (DECISOES PD3).
  final bool faixaConfirmada;

  bool get confirmado => chave != null;

  num limitar(num valor) => valor.clamp(minimo, maximo);

  /// O mesmo formato dos parâmetros de bloco: assim os knobs e faders do
  /// painel servem aqui sem cópia (arrastar, digitar, segurar volta ao padrão).
  DefinicaoParametro get parametro => DefinicaoParametro(
        simbolo: id,
        nome: nome,
        minimo: minimo,
        maximo: maximo,
        padrao: padrao,
        unidade: unidade,
        logaritmico: logaritmico,
      );
}

DefinicaoAjuste _saida(String id, String nome, String? chave) => DefinicaoAjuste(
    id: id,
    nome: nome,
    chave: chave,
    grupo: GrupoAjuste.saidas,
    minimo: -30,
    maximo: 6,
    padrao: 0,
    unidade: 'dB',
    faixaConfirmada: true);

DefinicaoAjuste _eq(String id, String nome, String? chave, num minimo, num maximo, num padrao, String unidade,
        {bool log = false}) =>
    DefinicaoAjuste(
        id: id,
        nome: nome,
        chave: chave,
        grupo: GrupoAjuste.globalEq,
        minimo: minimo,
        maximo: maximo,
        padrao: padrao,
        unidade: unidade,
        logaritmico: log);

DefinicaoAjuste _instrumento(int slot, String? chave) => DefinicaoAjuste(
    id: 'input_gain_${slot + 1}',
    nome: 'Input Gain ${slot + 1}',
    chave: chave,
    grupo: GrupoAjuste.entrada,
    minimo: -12,
    maximo: 12,
    padrao: 0,
    unidade: 'dB',
    faixaConfirmada: true);

/// Na ordem do mixer da pedaleira (manual): Out 3, Out 4, Out 1, Out 2, fone;
/// o alto-falante vem depois porque o mixer da tela não o mostra. Chave nula
/// = pendente: existe na pedaleira, falta ler a chave dela.
final mapaAjustes = <DefinicaoAjuste>[
  _saida('out3', 'Out 3 L', 'mixer.jack.left.vol'),
  _saida('out4', 'Out 4 R', 'mixer.jack.right.vol'),
  _saida('out1', 'Out 1 XLR', 'mixer.xlr.left.vol'),
  _saida('out2', 'Out 2 XLR', 'mixer.xlr.right.vol'),
  _saida('headphones', 'Headphones', 'mixer.headphones.vol'),
  _saida('speaker', 'Speaker', 'mixer.speaker.vol'),
  _saida('master', 'Master', null),
  _eq('eq_low_freq', 'Low Shelf Freq', 'globaleq.ls.freq', 20, 500, 100, 'Hz', log: true),
  _eq('eq_low_gain', 'Low Shelf Gain', 'globaleq.ls.gain', -12, 12, 0, 'dB'),
  _eq('eq_high_freq', 'High Shelf Freq', 'globaleq.hs.freq', 1000, 20000, 10000, 'Hz', log: true),
  _eq('eq_high_gain', 'High Shelf Gain', 'globaleq.hs.gain', -12, 12, 0, 'dB'),
  for (var banda = 2; banda <= 5; banda++) ...[
    _eq('eq_band${banda}_freq', 'Band $banda Freq', null, 20, 20000, 1000, 'Hz', log: true),
    _eq('eq_band${banda}_gain', 'Band $banda Gain', null, -12, 12, 0, 'dB'),
  ],
  _instrumento(0, 'input-gain-preset0.db'),
  for (var slot = 1; slot < 6; slot++) _instrumento(slot, null),
];

/// Só os ajustes com chave conhecida: os únicos que a tela mostra e que saem
/// para a pedaleira.
Iterable<DefinicaoAjuste> ajustesConfirmados([GrupoAjuste? grupo]) =>
    mapaAjustes.where((a) => a.confirmado && (grupo == null || a.grupo == grupo));

/// O ajuste pelo id do app ou pela chave do protocolo (o MCP aceita os dois).
DefinicaoAjuste? ajustePorIdOuChave(String pedido) {
  for (final a in mapaAjustes) {
    if (a.id == pedido || (a.chave != null && a.chave == pedido)) return a;
  }
  return null;
}

/// As bandas do Global EQ que o app desenha: tipo, id da frequência e do ganho.
const bandasGlobalEq = <(TipoBandaEq, String, String)>[
  (TipoBandaEq.lowShelf, 'eq_low_freq', 'eq_low_gain'),
  (TipoBandaEq.highShelf, 'eq_high_freq', 'eq_high_gain'),
];
