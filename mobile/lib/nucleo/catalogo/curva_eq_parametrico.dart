// O bloco Parametric EQ (fil4) é o mesmo equalizador do Global EQ: low shelf,
// 4 peaks e high shelf, com os mesmos padrões (397 Hz na banda 2). Aqui os
// grupos do painel ([agruparParametros]) viram as bandas da curva do Global
// EQ, para a tela do bloco ser a mesma da pedaleira; o bloco ainda tem a
// chave de cada seção, os cortes passa-altas/passa-baixas e o ganho geral.
import '../ajustes/curva_global_eq.dart';
import '../ajustes/mapa_ajustes.dart';
import 'arranjo_parametros.dart';
import 'definicao_bloco.dart';

const _prefixoParametrico = 'urn:darkglass:fil4';

bool ehEqParametrico(String uri) => uri.startsWith(_prefixoParametrico);

/// O tipo de filtro de cada banda; nulo para o grupo do ganho geral.
TipoBandaEq? tipoDaBanda(BandaEq? banda) => switch (banda) {
      BandaEq.shelfGraves => TipoBandaEq.lowShelf,
      BandaEq.banda1 || BandaEq.banda2 || BandaEq.banda3 || BandaEq.banda4 => TipoBandaEq.peak,
      BandaEq.shelfAgudos => TipoBandaEq.highShelf,
      BandaEq.passaAltas => TipoBandaEq.highPass,
      BandaEq.passaBaixas => TipoBandaEq.lowPass,
      _ => null,
    };

/// As 6 bandas do seletor de modo (shelves e peaks), na ordem da pedaleira.
bool ehBandaDoSeletor(GrupoParametros grupo) {
  final tipo = tipoDaBanda(grupo.banda);
  return tipo != null && tipo != TipoBandaEq.highPass && tipo != TipoBandaEq.lowPass;
}

/// O parâmetro que o [modo] mexe na banda: no corte, "largura" é a ressonância.
ParametroNoPainel? parametroDoModo(GrupoParametros grupo, ModoEq modo) {
  final rotulo = switch (modo) {
    ModoEq.gain => 'Gain',
    ModoEq.freq => 'Frequency',
    ModoEq.width => tipoDaBanda(grupo.banda) == TipoBandaEq.highPass ||
            tipoDaBanda(grupo.banda) == TipoBandaEq.lowPass
        ? 'Resonance'
        : 'Width',
  };
  for (final p in grupo.parametros) {
    if (p.rotulo == rotulo) return p;
  }
  return null;
}

/// Uma banda da curva com o grupo de onde veio (para o arraste saber o que mudar).
typedef BandaDaCurva = (GrupoParametros, BandaGlobalEq);

/// As bandas que a curva desenha, com o valor de cada parâmetro dado por
/// [valor] (o da cena ativa). Banda com a chave desligada não mexe no som.
List<BandaDaCurva> bandasDaCurva(List<GrupoParametros> grupos, num Function(DefinicaoParametro) valor) => [
      for (final grupo in grupos)
        if (tipoDaBanda(grupo.banda) case final tipo?)
          (
            grupo,
            BandaGlobalEq(
              tipo,
              _numero(grupo, ModoEq.freq, valor, 1000),
              _numero(grupo, ModoEq.gain, valor, 0),
              _numero(grupo, ModoEq.width, valor, 0.5),
              grupo.chave == null || DefinicaoParametro.estaLigado(valor(grupo.chave!)),
            ),
          ),
    ];

double _numero(GrupoParametros grupo, ModoEq modo, num Function(DefinicaoParametro) valor, double semParametro) {
  final p = parametroDoModo(grupo, modo);
  return p == null ? semParametro : valor(p.parametro).toDouble();
}

/// O "gain" geral do bloco, que sobe ou desce a curva inteira.
double ganhoGeralDoBloco(List<GrupoParametros> grupos, num Function(DefinicaoParametro) valor) {
  for (final grupo in grupos) {
    if (grupo.banda == BandaEq.geral && grupo.parametros.isNotEmpty) {
      return valor(grupo.parametros.first.parametro).toDouble();
    }
  }
  return 0;
}
