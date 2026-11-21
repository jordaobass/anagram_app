// Como os blocos de 3 bandas da Darkglass (Ignissor, compressor; Entropia,
// drive) se arrumam no painel: uma faixa de frequência com as bandas e as
// alças dos cortes, e uma coluna por banda. Os cortes NÃO são acoplados: no
// Ignissor os dois crossovers são parâmetros independentes (faixas que se
// sobrepõem, 25 Hz–11 kHz e 36 Hz–16 kHz) e no Entropia cada banda tem os
// próprios filtros (o passa-altas do médio não acompanha o passa-baixas do
// grave). A pedaleira aceita qualquer combinação, então o app também.

/// As três bandas, na ordem da tela.
enum BandaMultibanda { graves, medios, agudos }

/// As cores das bandas seguem a tela de cada bloco na pedaleira: o Entropia
/// pinta graves verde-água, médios roxo e agudos laranja.
enum PaletaBandas { ignissor, entropia }

/// Como um parâmetro aparece na coluna da banda.
enum TipoControleBanda { seletor, fader, knob }

/// Um parâmetro na coluna, com o nome curto que ele mostra ali dentro.
class ControleBanda {
  const ControleBanda(this.simbolo, this.rotulo, this.tipo);
  final String simbolo;
  final String rotulo;
  final TipoControleBanda tipo;
}

class ArranjoBanda {
  const ArranjoBanda({
    required this.banda,
    required this.inferior,
    required this.superior,
    required this.mudo,
    required this.controles,
    this.chave,
    this.nivel,
    this.paleta = PaletaBandas.ignissor,
  });

  final BandaMultibanda banda;

  /// Símbolo do corte de baixo e de cima da banda; nulo é a borda do áudio
  /// (20 Hz embaixo, 20 kHz em cima), que nenhum parâmetro move.
  final String? inferior;
  final String? superior;
  final String mudo;

  /// Liga/desliga da compressão da banda (Ignissor), no título da coluna.
  final String? chave;
  final List<ControleBanda> controles;

  /// Nível da banda em dB: a altura da curva dela na faixa de frequência.
  final String? nivel;
  final PaletaBandas paleta;

  /// Símbolos da compressão da banda (Ignissor): o gráfico entrada × saída.
  String? get limiar => _doSufixo('_threshold');
  String? get razao => _doSufixo('_ratio');

  /// Quantidade de drive da banda (Entropia): a onda que satura.
  String? get drive => _doSufixo('_drive_amount');

  String? _doSufixo(String sufixo) => controles.where((c) => c.simbolo.endsWith(sufixo)).firstOrNull?.simbolo;
}

class ArranjoMultibanda {
  const ArranjoMultibanda({required this.bandas, this.globais = const [], this.temMisturaLimpa = false});

  final List<ArranjoBanda> bandas;

  /// Níveis de saída do bloco inteiro, fora das bandas.
  final List<ControleBanda> globais;

  /// O Ignissor mistura o sinal sem compressão em paralelo (Clean Level).
  final bool temMisturaLimpa;

  /// Todos os símbolos que o arranjo mostra (cortes, chaves, controles).
  Set<String> get simbolos => {
        for (final b in bandas) ...[
          ?b.inferior,
          ?b.superior,
          ?b.chave,
          b.mudo,
          for (final c in b.controles) c.simbolo,
        ],
        for (final g in globais) g.simbolo,
      };

  /// Os cortes que a faixa desenha como alça, cada um com as bandas que ele
  /// limita: no Ignissor o crossover é a borda de duas bandas; no Entropia, de uma.
  Map<String, List<BandaMultibanda>> get alcas {
    final alcas = <String, List<BandaMultibanda>>{};
    for (final b in bandas) {
      for (final simbolo in [b.inferior, b.superior]) {
        if (simbolo != null) (alcas[simbolo] ??= []).add(b.banda);
      }
    }
    return alcas;
  }
}

const _seletor = TipoControleBanda.seletor;
const _fader = TipoControleBanda.fader;
const _knob = TipoControleBanda.knob;

ArranjoBanda _bandaIgnissor(BandaMultibanda banda, String prefixo, String? inferior, String? superior) => ArranjoBanda(
      banda: banda,
      inferior: inferior,
      superior: superior,
      chave: '${prefixo}_comp_enabled',
      mudo: '${prefixo}_mute',
      nivel: '${prefixo}_level',
      controles: [
        ControleBanda('${prefixo}_ratio', 'Ratio', _seletor),
        ControleBanda('${prefixo}_threshold', 'Threshold', _fader),
        ControleBanda('${prefixo}_level', 'Level', _fader),
        ControleBanda('${prefixo}_attack', 'Attack', _knob),
        ControleBanda('${prefixo}_release', 'Release', _knob),
      ],
    );

final _ignissor = ArranjoMultibanda(
  bandas: [
    _bandaIgnissor(BandaMultibanda.graves, 'lo', null, 'lomid_xo_freq'),
    _bandaIgnissor(BandaMultibanda.medios, 'mid', 'lomid_xo_freq', 'midhi_xo_freq'),
    _bandaIgnissor(BandaMultibanda.agudos, 'hi', 'midhi_xo_freq', null),
  ],
  globais: const [
    ControleBanda('comp_level', 'Comp Level', _knob),
    ControleBanda('clean_level', 'Clean Level', _knob),
  ],
  temMisturaLimpa: true,
);

ArranjoBanda _bandaDriveEntropia(BandaMultibanda banda, String prefixo, String rotuloDrive) => ArranjoBanda(
      banda: banda,
      inferior: '${prefixo}_hp_freq',
      superior: '${prefixo}_lp_freq',
      mudo: '${prefixo}_mute',
      nivel: '${prefixo}_level',
      paleta: PaletaBandas.entropia,
      controles: [
        ControleBanda('${prefixo}_drive_typemode', 'Type', _seletor),
        ControleBanda('${prefixo}_level', 'Level', _fader),
        ControleBanda('${prefixo}_drive_amount', rotuloDrive, _knob),
      ],
    );

final _entropia = ArranjoMultibanda(bandas: [
  const ArranjoBanda(
    banda: BandaMultibanda.graves,
    inferior: null,
    superior: 'lo_lp_freq',
    mudo: 'lo_mute',
    nivel: 'lo_level',
    paleta: PaletaBandas.entropia,
    controles: [
      ControleBanda('lo_comp_type', 'Comp Type', _seletor),
      ControleBanda('lo_comp_mode', 'ATT / REL', _seletor),
      ControleBanda('lo_comp_ratio', 'Ratio', _seletor),
      ControleBanda('lo_level', 'Level', _fader),
      ControleBanda('lo_comp_amount', 'Comp', _knob),
    ],
  ),
  _bandaDriveEntropia(BandaMultibanda.medios, 'mid', 'Drive'),
  _bandaDriveEntropia(BandaMultibanda.agudos, 'hi', 'Drive'),
]);

/// Arranjo do bloco, ou nulo para o que não é de 3 bandas.
ArranjoMultibanda? arranjoMultibanda(String uri) => switch (uri.split('#').first) {
      'urn:darkglass:ignissor' => _ignissor,
      'urn:darkglass:entropia' => _entropia,
      _ => null,
    };

/// Opções longas (os 37 tipos de drive do Entropia) em grupos pela família:
/// "B3K Grunt" fica em "B3K", "B3K Turbo Grunt" em "B3K Turbo". A ordem das
/// opções e dos grupos é a do catálogo; o índice é o da opção na lista.
Map<String, List<(int, String)>> agruparOpcoes(List<String> opcoes) {
  final grupos = <String, List<(int, String)>>{};
  for (var i = 0; i < opcoes.length; i++) {
    (grupos[_grupoDaOpcao(opcoes[i])] ??= []).add((i, opcoes[i]));
  }
  return grupos;
}

String _grupoDaOpcao(String opcao) {
  final palavras = opcao.split(' ');
  final turbo = palavras.indexOf('Turbo');
  return turbo > 0 ? palavras.take(turbo + 1).join(' ') : palavras.first;
}
