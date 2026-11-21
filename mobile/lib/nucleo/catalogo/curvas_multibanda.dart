// Geometria dos desenhos do multibanda, sem tela: a resposta de cada banda
// na faixa de frequência, a curva estática do compressor (entrada × saída) e
// a senoide que satura com o drive. São ilustrações para ler o ajuste de
// relance — a forma exata dos filtros e da saturação da pedaleira não é
// publicada, então a resposta usa um filtro de 2ª ordem (12 dB/oitava) nos
// cortes e a saturação, uma tangente hiperbólica.
import 'dart:math';

/// Posição de uma frequência na faixa, de 0 (20 Hz) a 1 (20 kHz).
double fracaoDaFrequencia(num hz) => (log(hz.clamp(minimoFaixa, maximoFaixa) / minimoFaixa) / log(maximoFaixa / minimoFaixa));

num frequenciaDaFracao(double fracao) => minimoFaixa * pow(maximoFaixa / minimoFaixa, fracao.clamp(0.0, 1.0));

const minimoFaixa = 20.0;
const maximoFaixa = 20000.0;

/// Ganho da banda em dB na frequência [hz]: passa-altas em [inferior] e
/// passa-baixas em [superior] (nulo = sem corte desse lado), somados ao
/// [nivelDb] da banda. No corte a banda está 3 dB abaixo do nível.
double respostaDaBandaDb(double hz, {double? inferior, double? superior, double nivelDb = 0}) {
  var potencia = 1.0;
  if (inferior != null) potencia *= 1 / (1 + pow(inferior / hz, 4));
  if (superior != null) potencia *= 1 / (1 + pow(hz / superior, 4));
  return 10 * log(potencia) / ln10 + nivelDb;
}

/// A resposta da banda amostrada ao longo da faixa: (posição 0..1, dB).
List<(double, double)> curvaDaBanda({double? inferior, double? superior, double nivelDb = 0, int pontos = 96}) => [
      for (var i = 0; i <= pontos; i++)
        (
          i / pontos,
          respostaDaBandaDb(frequenciaDaFracao(i / pontos).toDouble(),
              inferior: inferior, superior: superior, nivelDb: nivelDb),
        ),
    ];

/// Saída do compressor em dB para a entrada [entradaDb]: 1:1 até o
/// [limiarDb] e inclinação 1/[razao] depois. Desligado, é sempre 1:1.
double saidaDoCompressorDb(double entradaDb, {required double limiarDb, required double razao, bool ligado = true}) {
  if (!ligado || razao <= 1 || entradaDb <= limiarDb) return entradaDb;
  return limiarDb + (entradaDb - limiarDb) / razao;
}

/// A curva do compressor de [minimoDb] a 0 dB: o canto fica exatamente no
/// limiar, para o desenho não arredondar o joelho.
List<(double, double)> curvaDoCompressor(
    {required double limiarDb, required double razao, bool ligado = true, double minimoDb = -60}) {
  final entradas = {minimoDb, limiarDb.clamp(minimoDb, 0.0), 0.0}.toList()..sort();
  return [
    for (final e in entradas) (e, saidaDoCompressorDb(e, limiarDb: limiarDb, razao: razao, ligado: ligado)),
  ];
}

/// Um ciclo de senoide passando pela saturação: [drive] de 0 a 10; 0 quase
/// limpa, 10 quase quadrada. Pontos (fase 0..1, amplitude −1..1).
List<(double, double)> ondaSaturada(double drive, {int pontos = 64}) {
  final ganho = 0.6 + drive.clamp(0, 10) * 0.35;
  final normal = _tanh(ganho);
  return [
    for (var i = 0; i <= pontos; i++) (i / pontos, _tanh(ganho * sin(2 * pi * i / pontos)) / normal),
  ];
}

double _tanh(double x) {
  final e = exp(2 * x);
  return (e - 1) / (e + 1);
}
