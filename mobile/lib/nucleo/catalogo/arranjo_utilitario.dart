// Como a bateria (Auto Drummer, falkTX) e o metrônomo (Cognate Metro) se
// arrumam no painel: na ordem da tela da Anagram, um cartão por controle numa
// fileira, com o que é lista, rolo, knob e chave lá. Só entra o que o
// catálogo do firmware traz; parâmetro novo cai em "Outros" (DECISOES BT5).

/// As fileiras dos painéis: a página do visor e, no metrônomo, a página 2
/// (Treino) logo abaixo.
enum SecaoUtilitario { principal, treino }

/// Como um parâmetro aparece no cartão.
enum TipoControleUtil {
  /// A marcada entre as vizinhas, como a lista do visor; abre a lista toda.
  lista,

  /// A opção grande no meio, as vizinhas apagadas dos lados (o compasso).
  rolo,
  knob,

  /// O knob maior do cartão (o tempo).
  knobGrande,
  chave,

  /// Saída do plugin (Status, Accuracy): não chega pelo USB, só o nome.
  saida,
}

/// Quando o valor de outro parâmetro faz este controle não valer (o tempo
/// que segue o tempo global): o controle fica apagado, mas ajustável.
class Apagamento {
  const Apagamento(this.simbolo, this.apaga);
  final String simbolo;
  final bool Function(num valor) apaga;
}

class ControleUtil {
  const ControleUtil(this.simbolo, this.tipo, {this.unidade, this.apagamento, this.comToque = false, this.nome});

  /// A saída do plugin, que o catálogo não traz: o cartão leva o [nome] do visor.
  const ControleUtil.saida(this.simbolo, String this.nome)
      : tipo = TipoControleUtil.saida,
        unidade = null,
        apagamento = null,
        comToque = false;

  final String simbolo;
  final String? nome;
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

  /// Os parâmetros que o arranjo cobre (as saídas não são parâmetros).
  Set<String> get simbolos => {
        for (final s in secoes)
          for (final c in s.controles)
            if (c.tipo != TipoControleUtil.saida) c.simbolo,
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
  SecaoUtil(SecaoUtilitario.principal, [
    ControleUtil('style', _l),
    ControleUtil('level', _k),
    ControleUtil('action', TipoControleUtil.chave),
    ControleUtil.saida('status', 'Status'),
    ControleUtil('useHostTempo', TipoControleUtil.chave),
    ControleUtil('userTempo', TipoControleUtil.knobGrande,
        unidade: 'bpm', apagamento: Apagamento('useHostTempo', _ligado)),
  ]),
]);

const _metronomo = ArranjoUtilitario(
  semControle: {'tap'},
  secoes: [
    SecaoUtil(SecaoUtilitario.principal, [
      ControleUtil('tempo', TipoControleUtil.knobGrande,
          unidade: 'bpm', apagamento: Apagamento('mode', _foraDoTempoFixo), comToque: true),
      ControleUtil('mode', _l),
      ControleUtil('time_signature', TipoControleUtil.rolo),
      ControleUtil('sound', _l),
      ControleUtil('level', _k),
    ]),
    SecaoUtil(SecaoUtilitario.treino, [ControleUtil('gap_mode', _l), ControleUtil.saida('accuracy', 'Accuracy')]),
  ],
);

/// O arranjo do bloco, ou nulo quando ele usa outro painel.
ArranjoUtilitario? arranjoUtilitario(String uri) => switch (uri) {
      'https://falktx.com/plugins/auto-drummer' => _bateria,
      'https://cognate.audio/plugins/cognate-metro' => _metronomo,
      _ => null,
    };

/// As opções que a lista rolante mostra: a marcada entre as vizinhas, três
/// por vez (alvos de 48 dp numa fileira de altura só); nas pontas, as duas
/// do mesmo lado.
List<int> opcoesVisiveis(int total, int atual, {int maximo = 3}) {
  if (total <= maximo) return [for (var i = 0; i < total; i++) i];
  final inicio = (atual - maximo ~/ 2).clamp(0, total - maximo);
  return [for (var i = inicio; i < inicio + maximo; i++) i];
}
