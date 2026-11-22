// Os ajustes GLOBAIS da Anagram (valem para todos os presets) que o app sabe
// LER por `export_settings`. Só leitura: a pedaleira aceita `edit_settings`
// nessas chaves, mas não muda o som (DECISOES AJ1). Um lugar só: quando
// descobrirmos a chave de um ajuste pendente (a pedaleira só exporta o que já
// foi mexido), basta preencher [DefinicaoAjuste.chave] aqui (DECISOES PD2).
import 'dart:math' as math;

import '../catalogo/definicao_bloco.dart';

enum GrupoAjuste { saidas, globalEq, entrada }

/// Banda do Global EQ (e do Parametric EQ, o mesmo DSP), para o desenho da
/// curva (DECISOES PD4). Os cortes só existem no bloco Parametric EQ.
enum TipoBandaEq { lowShelf, peak, highShelf, highPass, lowPass }

/// O que os knobs mexem no Global EQ, como o seletor da tela da Anagram.
enum ModoEq { gain, freq, width }

/// Uma das 6 bandas do Global EQ. As chaves `globaleq.<codigo>.<freq|gain|width>`
/// e os padrões de fábrica foram lidos da Anagram v1.19.2.24 (2026-11-21); as
/// faixas de frequência são as do Parametric EQ do catálogo, o mesmo DSP
/// (hipótese, DECISOES PD7).
class BandaEqGlobal {
  const BandaEqGlobal(this.codigo, this.tipo, this.freqMin, this.freqMax, this.freqPadrao, this.larguraPadrao);

  final String codigo;
  final TipoBandaEq tipo;
  final num freqMin;
  final num freqMax;
  final num freqPadrao;
  final num larguraPadrao;

  String id(ModoEq modo) => 'eq_${codigo}_${modo.name}';
  String chave(ModoEq modo) => 'globaleq.$codigo.${modo.name}';
}

/// Da esquerda para a direita, como na tela da pedaleira.
const bandasEqGlobal = <BandaEqGlobal>[
  BandaEqGlobal('ls', TipoBandaEq.lowShelf, 25, 300, 35, 0.33),
  BandaEqGlobal('1', TipoBandaEq.peak, 20, 320, 160, 0.5),
  BandaEqGlobal('2', TipoBandaEq.peak, 80, 1250, 397, 0.5),
  BandaEqGlobal('3', TipoBandaEq.peak, 320, 5000, 1250, 0.5),
  BandaEqGlobal('4', TipoBandaEq.peak, 1250, 20000, 2500, 0.5),
  BandaEqGlobal('hs', TipoBandaEq.highShelf, 1500, 16000, 9630, 0.33),
];

/// Ganho do Global EQ: a pedaleira aceitou e devolveu −18 dB (2026-11-21).
const ganhoMaximoEq = 18;

/// Largura: a pedaleira devolveu 4,0 nos shelves (2026-11-21), então a faixa
/// 0–1 do Parametric EQ não vale aqui; 0–4 é hipótese (DECISOES PD7).
const larguraMaximaEq = 4;

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
  /// ajuste que existe na pedaleira mas cuja chave ainda não conhecemos: não
  /// aparece na tela.
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

  /// A mesma definição com a faixa alargada para conter [valor]: se a
  /// pedaleira devolve algo fora da faixa suposta, a faixa estava errada, não
  /// o valor (DECISOES PD7).
  DefinicaoAjuste abrangendo(num? valor) {
    if (valor == null || (valor >= minimo && valor <= maximo)) return this;
    return DefinicaoAjuste(
        id: id,
        nome: nome,
        grupo: grupo,
        minimo: math.min(minimo, valor),
        maximo: math.max(maximo, valor),
        padrao: padrao,
        chave: chave,
        unidade: unidade,
        logaritmico: logaritmico,
        faixaConfirmada: faixaConfirmada);
  }

  /// O mesmo formato dos parâmetros de bloco: assim os knobs e faders do
  /// painel desenham o valor aqui sem cópia.
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

DefinicaoAjuste _eq(BandaEqGlobal banda, ModoEq modo) {
  final (minimo, maximo, padrao, unidade) = switch (modo) {
    ModoEq.gain => (-ganhoMaximoEq, ganhoMaximoEq, 0, 'dB'),
    ModoEq.freq => (banda.freqMin, banda.freqMax, banda.freqPadrao, 'Hz'),
    ModoEq.width => (0, larguraMaximaEq, banda.larguraPadrao, null),
  };
  return DefinicaoAjuste(
      id: banda.id(modo),
      nome: '${banda.codigo.toUpperCase()} ${modo.name}',
      chave: banda.chave(modo),
      grupo: GrupoAjuste.globalEq,
      minimo: minimo,
      maximo: maximo,
      padrao: padrao,
      unidade: unidade,
      logaritmico: modo == ModoEq.freq,
      faixaConfirmada: modo == ModoEq.gain);
}

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

/// Na ordem do mixer da pedaleira (manual): Out 3, Out 4, Out 1, Out 2, fone.
/// `mixer.speaker.vol` vem no export, mas o mixer do manual não tem saída de
/// alto-falante, então fica fora (DECISOES AJ4). Chave nula = pendente:
/// existe na pedaleira, falta ler a chave dela.
final mapaAjustes = <DefinicaoAjuste>[
  _saida('out3', 'Out 3 L', 'mixer.jack.left.vol'),
  _saida('out4', 'Out 4 R', 'mixer.jack.right.vol'),
  _saida('out1', 'Out 1 XLR', 'mixer.xlr.left.vol'),
  _saida('out2', 'Out 2 XLR', 'mixer.xlr.right.vol'),
  _saida('headphones', 'Headphones', 'mixer.headphones.vol'),
  _saida('master', 'Master', null),
  for (final banda in bandasEqGlobal)
    for (final modo in ModoEq.values) _eq(banda, modo),
  _instrumento(0, 'input-gain-preset0.db'),
  for (var slot = 1; slot < 6; slot++) _instrumento(slot, null),
];

/// Só os ajustes com chave conhecida: os únicos que a tela mostra.
Iterable<DefinicaoAjuste> ajustesConfirmados([GrupoAjuste? grupo]) =>
    mapaAjustes.where((a) => a.confirmado && (grupo == null || a.grupo == grupo));

/// O ajuste pelo id do app ou pela chave do protocolo (o MCP aceita os dois).
DefinicaoAjuste? ajustePorIdOuChave(String pedido) {
  for (final a in mapaAjustes) {
    if (a.id == pedido || (a.chave != null && a.chave == pedido)) return a;
  }
  return null;
}
