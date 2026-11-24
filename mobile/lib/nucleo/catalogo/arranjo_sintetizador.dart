// Como o Axioma Mono Synth se arruma no painel, igual a um sintetizador:
// entrada, osciladores, filtro, envelope, arpejador e saída, cada um num
// cartão. Os rótulos curtos são os do painel de synth (Vol, Wave, Cutoff…),
// a mesma língua dos nomes do catálogo. Só entra o que o catálogo do
// firmware traz: nenhum parâmetro inventado, nenhum escondido.

/// As seções da tela, na ordem de leitura de um synth.
enum SecaoSintetizador { entrada, osciladores, filtro, envelope, arpejador, saida }

/// Como um parâmetro aparece dentro da seção.
enum TipoControleSynth { seletor, fader, knob }

class ControleSynth {
  const ControleSynth(this.simbolo, this.rotulo, this.tipo);
  final String simbolo;
  final String rotulo;
  final TipoControleSynth tipo;
}

/// Um oscilador: a forma de onda (que o painel desenha) e os controles dele.
class OsciladorSynth {
  const OsciladorSynth({required this.titulo, required this.rotuloModulo, required this.onda, required this.controles});
  final String titulo;

  /// O título do módulo como a tela da pedaleira escreve ("Osc 1 Vol").
  final String rotuloModulo;

  /// Símbolo do seletor de forma de onda; nulo no sub-oscilador, que não tem.
  final String? onda;
  final List<ControleSynth> controles;
}

class ArranjoSecao {
  const ArranjoSecao({required this.secao, this.chave, this.controles = const [], this.osciladores = const []});
  final SecaoSintetizador secao;

  /// Liga/desliga da seção no título (o arpejador); com ela desligada os
  /// controles ficam apagados, mas ajustáveis.
  final String? chave;
  final List<ControleSynth> controles;
  final List<OsciladorSynth> osciladores;

  Iterable<String> get simbolos sync* {
    if (chave != null) yield chave!;
    for (final c in controles) {
      yield c.simbolo;
    }
    for (final o in osciladores) {
      if (o.onda != null) yield o.onda!;
      for (final c in o.controles) {
        yield c.simbolo;
      }
    }
  }
}

class ArranjoSintetizador {
  const ArranjoSintetizador({
    required this.secoes,
    required this.corte,
    required this.ressonancia,
    required this.ataque,
    required this.decaimento,
    required this.liberacao,
  });

  final List<ArranjoSecao> secoes;

  /// Símbolos que os desenhos do filtro e do envelope leem.
  final String corte;
  final String ressonancia;
  final String ataque;
  final String decaimento;
  final String liberacao;

  Set<String> get simbolos => {for (final s in secoes) ...s.simbolos};
}

const _k = TipoControleSynth.knob;
const _f = TipoControleSynth.fader;
const _s = TipoControleSynth.seletor;

const _axioma = ArranjoSintetizador(
  corte: 'cutoff',
  ressonancia: 'reso',
  ataque: 'attack',
  decaimento: 'decay',
  liberacao: 'release',
  secoes: [
    ArranjoSecao(secao: SecaoSintetizador.entrada, controles: [
      ControleSynth('instrument', 'Instrument', _s),
      ControleSynth('sensitivity', 'Sensitivity', _k),
    ]),
    ArranjoSecao(secao: SecaoSintetizador.osciladores, osciladores: [
      OsciladorSynth(titulo: 'Osc 1', rotuloModulo: 'Osc 1 Vol', onda: 'osc1_wave', controles: [ControleSynth('osc1_vol', 'Vol', _f)]),
      OsciladorSynth(titulo: 'Osc 2', rotuloModulo: 'Osc 2 Vol', onda: 'osc2_wave', controles: [
        ControleSynth('osc2_vol', 'Vol', _f),
        ControleSynth('osc2_semitone', 'Semitone', _k),
        ControleSynth('osc2_cents', 'Fine', _k),
      ]),
      OsciladorSynth(titulo: 'Sub', rotuloModulo: 'Sub Osc Vol', onda: null, controles: [ControleSynth('sub_vol', 'Vol', _f)]),
    ]),
    ArranjoSecao(secao: SecaoSintetizador.filtro, controles: [
      ControleSynth('cutoff', 'Cutoff', _k),
      ControleSynth('reso', 'Resonance', _k),
      ControleSynth('env', 'Envelope', _k),
    ]),
    ArranjoSecao(secao: SecaoSintetizador.envelope, controles: [
      ControleSynth('attack', 'Attack', _k),
      ControleSynth('decay', 'Decay', _k),
      ControleSynth('release', 'Release', _k),
    ]),
    ArranjoSecao(secao: SecaoSintetizador.arpejador, chave: 'arp_enable', controles: [
      ControleSynth('TempoBPM', 'Tempo BPM', _k),
      ControleSynth('arp_key', 'Key', _s),
      ControleSynth('arp_scale', 'Scale', _s),
      ControleSynth('arp_pattern', 'Pattern', _s),
      ControleSynth('arp_octaves', 'Octaves', _k),
    ]),
    ArranjoSecao(secao: SecaoSintetizador.saida, controles: [
      ControleSynth('blend', 'Dry/Wet', _k),
      ControleSynth('level', 'Level', _f),
    ]),
  ],
);

/// O arranjo do bloco, ou nulo quando ele usa o painel comum.
ArranjoSintetizador? arranjoSintetizador(String uri) => switch (uri) {
      'urn:darkglass:axioma_synth' => _axioma,
      _ => null,
    };
