// Como os parâmetros de um bloco se arrumam no painel: o paramétrico em
// bandas (cada uma com sua chave e knobs de nome curto, como no plugin), o
// GEQ em faders, e o resto na ordem do catálogo, que é a do painel do pedal.
import 'definicao_bloco.dart';

/// Banda do equalizador paramétrico; o nome na tela vem do idioma.
enum BandaEq { geral, passaAltas, passaBaixas, shelfGraves, banda1, banda2, banda3, banda4, shelfAgudos }

/// Um parâmetro no painel com o rótulo que ele mostra ali dentro.
class ParametroNoPainel {
  const ParametroNoPainel(this.parametro, this.rotulo);
  final DefinicaoParametro parametro;
  final String rotulo;
}

class GrupoParametros {
  const GrupoParametros({this.banda, this.chave, required this.parametros});

  /// Nulo: grupo único, sem título (todo bloco que não é o paramétrico).
  final BandaEq? banda;

  /// O liga/desliga da banda, que vai no título em vez de virar um controle.
  final DefinicaoParametro? chave;
  final List<ParametroNoPainel> parametros;
}

/// Forma do controle contínuo: knob, ou fader vertical nas bandas do GEQ.
enum FormaControle { knob, fader }

typedef _Banda = (BandaEq, String?, Map<String, String>);

const _bandasParametrico = <_Banda>[
  (BandaEq.geral, null, {'gain': 'Gain'}),
  (BandaEq.passaAltas, 'HighPass', {'HPfreq': 'Frequency', 'HPQ': 'Resonance'}),
  (BandaEq.passaBaixas, 'LowPass', {'LPfreq': 'Frequency', 'LPQ': 'Resonance'}),
  (BandaEq.shelfGraves, 'LSsec', {'LSfreq': 'Frequency', 'LSwidth': 'Width', 'LSgain': 'Gain'}),
  (BandaEq.banda1, 'sec1', {'freq1': 'Frequency', 'width1': 'Width', 'gain1': 'Gain'}),
  (BandaEq.banda2, 'sec2', {'freq2': 'Frequency', 'width2': 'Width', 'gain2': 'Gain'}),
  (BandaEq.banda3, 'sec3', {'freq3': 'Frequency', 'width3': 'Width', 'gain3': 'Gain'}),
  (BandaEq.banda4, 'sec4', {'freq4': 'Frequency', 'width4': 'Width', 'gain4': 'Gain'}),
  (BandaEq.shelfAgudos, 'HSsec', {'HSfreq': 'Frequency', 'HSwidth': 'Width', 'HSgain': 'Gain'}),
];

const _prefixoParametrico = 'urn:darkglass:fil4';

/// GEQs da pedaleira: as bandas (e o nível) em dB viram faders.
const _equalizadoresGraficos = {'urn:darkglass:DarkglassGEQ', 'urn:darkglass:GenericGEQ'};

/// Banda de GEQ embutida noutro bloco (o EQ do TONE3000): "S100Hz", "S1600Hz".
final _simboloDeBanda = RegExp(r'^S\d+k?Hz$');

/// Grupos do painel, só com os [visiveis]. Parâmetro que o arranjo não
/// conhece (firmware novo) vai para o fim, para nunca sumir.
List<GrupoParametros> agruparParametros(DefinicaoBloco definicao, List<DefinicaoParametro> visiveis) {
  final soltos = [for (final p in visiveis) ParametroNoPainel(p, p.nome)];
  if (!definicao.uri.startsWith(_prefixoParametrico)) return [GrupoParametros(parametros: soltos)];
  final porSimbolo = {for (final p in visiveis) p.simbolo: p};
  final usados = <String>{};
  final grupos = <GrupoParametros>[];
  for (final (banda, chave, rotulos) in _bandasParametrico) {
    final parametros = [
      for (final MapEntry(key: simbolo, value: rotulo) in rotulos.entries)
        if (porSimbolo[simbolo] case final p?) ParametroNoPainel(p, rotulo),
    ];
    if (parametros.isEmpty) continue;
    usados
      ..addAll(rotulos.keys)
      ..add(chave ?? '');
    grupos.add(GrupoParametros(banda: banda, chave: porSimbolo[chave], parametros: parametros));
  }
  final resto = [for (final p in soltos) if (!usados.contains(p.parametro.simbolo)) p];
  if (resto.isNotEmpty) grupos.add(GrupoParametros(parametros: resto));
  return grupos;
}

FormaControle formaDoControle(DefinicaoBloco definicao, DefinicaoParametro parametro) {
  if (parametro.unidade != 'dB' || parametro.ehDiscreto) return FormaControle.knob;
  final grafico = _equalizadoresGraficos.contains(definicao.uri) || _simboloDeBanda.hasMatch(parametro.simbolo);
  return grafico ? FormaControle.fader : FormaControle.knob;
}
