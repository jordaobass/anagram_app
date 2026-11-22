// Os tons do TONE3000 que estão na pedaleira: os de fábrica (lista fixa do
// firmware) e os que a pessoa mandou. Serve para achar o tom carregado num
// bloco pelo caminho em `properties["1"].value` e para oferecer os outros.
import '../catalogo/modelo_carregado.dart';
import '../modelo/json_util.dart';
import 'tom_tone3000.dart';

/// O que o bloco carrega, achado na lista; [modelo] nulo = o tom está na
/// pedaleira, mas o arquivo não é um dos modelos que ela listou.
class TomNoBloco {
  const TomNoBloco(this.tom, this.modelo);

  final TomTone3000 tom;
  final ModeloDoTom? modelo;
}

class TonsDaPedaleira {
  const TonsDaPedaleira({this.fabrica = const [], this.doUsuario = const []})
      : disponivel = true,
        falhou = false;

  /// Firmware sem `t3k` ou editor sem conexão; [falhou] = a pedaleira não
  /// respondeu a tempo, e vale tentar de novo.
  const TonsDaPedaleira.indisponivel({this.falhou = false})
      : fabrica = const [],
        doUsuario = const [],
        disponivel = false;

  final List<TomTone3000> fabrica;
  final List<TomTone3000> doUsuario;
  final bool disponivel;
  final bool falhou;

  List<TomTone3000> get todos => [...fabrica, ...doUsuario];

  /// Os tons que cabem no bloco: NAM no neural, IR no gabinete.
  List<TomTone3000> doFormato(FormatoTom formato) => [for (final t in todos) if (t.formato == formato) t];

  /// O tom do arquivo [valor] no bloco [uri]; nulo se não está na pedaleira.
  TomNoBloco? doBloco(String uri, String? valor) {
    final carregado = modeloCarregadoDe(uri, valor);
    final id = carregado?.idTone3000;
    if (carregado == null || id == null) return null;
    final lista = carregado.doUsuario ? doUsuario : fabrica;
    for (final tom in lista) {
      if (tom.id == id) return TomNoBloco(tom, tom.modeloDoArquivo(carregado.nomeDoArquivo));
    }
    return null;
  }
}

/// `data.tones` de `get_t3k_factory_tones`.
List<TomTone3000> tonsDeFabricaDaResposta(Map<String, dynamic> resposta) {
  final tons = mapaOuVazio(resposta['data'])['tones'];
  return [if (tons is List) ...tons.map(TomTone3000.doJson).nonNulls];
}

/// Uma página de `get_t3k_tones_metadata`: `data.t3k_data[].data` é o tom e
/// `data.info.all_items_length`, quantos há ao todo.
class PaginaDeTons {
  const PaginaDeTons(this.tons, this.total);

  factory PaginaDeTons.daResposta(Map<String, dynamic> resposta) {
    final dados = mapaOuVazio(resposta['data']);
    final itens = dados['t3k_data'];
    final tons = [
      if (itens is List)
        for (final item in itens) ?TomTone3000.doJson(mapaOuVazio(item)['data'], doUsuario: true),
    ];
    final total = numeroOuNulo(mapaOuVazio(dados['info'])['all_items_length'])?.toInt();
    return PaginaDeTons(tons, total ?? tons.length);
  }

  final List<TomTone3000> tons;
  final int total;
}
