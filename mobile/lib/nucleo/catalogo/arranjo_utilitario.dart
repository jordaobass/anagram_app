// Como a bateria (Auto Drummer, falkTX) e o metrônomo (Cognate Metro) se
// arrumam no painel: na ordem e no agrupamento da tela original de cada
// plugin, com o que é lista, botão, knob e chave lá. Só entra o que o
// catálogo do firmware traz; parâmetro novo cai em "Outros" (DECISOES BT1).

/// Os cartões dos dois painéis.
enum SecaoUtilitario { bateria, acao, metronomo, treino }

/// Como um parâmetro aparece no cartão.
enum TipoControleUtil {
  /// Lista que abre com as opções (muitas opções, ou as do original).
  lista,

  /// Uma fileira de botões, a opção marcada na cor da família.
  botoes,
  knob,

  /// O knob maior do cartão (o tempo).
  knobGrande,
  chave,
}

/// Quando o valor de outro parâmetro faz este controle não valer (o tempo
/// que segue o tempo global): o controle fica apagado, mas ajustável.
class Apagamento {
  const Apagamento(this.simbolo, this.apaga);
  final String simbolo;
  final bool Function(num valor) apaga;
}

class ControleUtil {
  const ControleUtil(this.simbolo, this.tipo, {this.unidade, this.apagamento, this.comToque = false});
  final String simbolo;
  final TipoControleUtil tipo;

  /// Unidade que o catálogo não traz (bpm); o valor passa a ser inteiro.
  final String? unidade;
  final Apagamento? apagamento;

  /// O "Bater" do app embaixo do knob (tap tempo calculado no app).
  final bool comToque;
}

class SecaoUtil {
  const SecaoUtil(this.secao, this.controles);
  final SecaoUtilitario secao;
  final List<ControleUtil> controles;
}

class ArranjoUtilitario {
  const ArranjoUtilitario({required this.secoes, this.semControle = const {}});
  final List<SecaoUtil> secoes;

  /// Parâmetros do catálogo que a tela original não mostra: nem aqui nem em "Outros".
  final Set<String> semControle;

  Set<String> get simbolos => {
        for (final s in secoes)
          for (final c in s.controles) c.simbolo,
        ...semControle,
      };

  ControleUtil? controle(String simbolo) {
    for (final s in secoes) {
      for (final c in s.controles) {
        if (c.simbolo == simbolo) return c;
      }
    }
    return null;
  }
}

bool _ligado(num valor) => valor >= 0.5;

/// O Cognate Metro só usa o knob no modo 0 (Fixed Tempo).
bool _foraDoTempoFixo(num valor) => valor.round() != 0;

const _l = TipoControleUtil.lista;
const _k = TipoControleUtil.knob;

const _bateria = ArranjoUtilitario(secoes: [
  SecaoUtil(SecaoUtilitario.bateria, [
    ControleUtil('style', _l),
    ControleUtil('level', _k),
    ControleUtil('userTempo', TipoControleUtil.knobGrande,
        unidade: 'bpm', apagamento: Apagamento('useHostTempo', _ligado)),
    ControleUtil('useHostTempo', TipoControleUtil.chave),
  ]),
  SecaoUtil(SecaoUtilitario.acao, [ControleUtil('action', TipoControleUtil.chave)]),
]);

const _metronomo = ArranjoUtilitario(
  semControle: {'tap'},
  secoes: [
    SecaoUtil(SecaoUtilitario.metronomo, [
      ControleUtil('tempo', TipoControleUtil.knobGrande,
          unidade: 'bpm', apagamento: Apagamento('mode', _foraDoTempoFixo), comToque: true),
      ControleUtil('mode', _l),
      ControleUtil('time_signature', TipoControleUtil.botoes),
      ControleUtil('sound', _l),
      ControleUtil('level', _k),
    ]),
    SecaoUtil(SecaoUtilitario.treino, [ControleUtil('gap_mode', _l)]),
  ],
);

/// O arranjo do bloco, ou nulo quando ele usa outro painel.
ArranjoUtilitario? arranjoUtilitario(String uri) => switch (uri) {
      'https://falktx.com/plugins/auto-drummer' => _bateria,
      'https://cognate.audio/plugins/cognate-metro' => _metronomo,
      _ => null,
    };

/// Os tempos do compasso pelo rótulo da opção ("6/8" = 6 tempos), com o 1
/// acentuado; rótulo que não é compasso volta nulo.
List<bool>? temposDoCompasso(String rotulo) {
  final tempos = int.tryParse(RegExp(r'^(\d+)/\d+$').firstMatch(rotulo.trim())?.group(1) ?? '');
  if (tempos == null || tempos < 1) return null;
  return [for (var i = 0; i < tempos; i++) i == 0];
}
