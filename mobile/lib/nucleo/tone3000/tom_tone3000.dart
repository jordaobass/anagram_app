// Um tom do TONE3000 guardado na pedaleira, como `get_t3k_factory_tones` e
// `get_t3k_tones_metadata` o devolvem (fw 1.19.2.24, DECISOES T3K1): título,
// formato (NAM ou IR), tipo de equipamento e os modelos (`a2_models`). A
// resposta é entrada externa: campo com tipo inesperado vale como ausente.
import '../catalogo/variantes_uri.dart';
import '../modelo/json_util.dart';

/// NAM vai no bloco neural, IR no gabinete TONE3000. A pasta é a que a
/// pedaleira e o Darkglass Suite usam para cada formato.
enum FormatoTom {
  nam('neural-models-t3k', 'nam'),
  ir('irs-t3k', 'wav');

  const FormatoTom(this.pasta, this.extensaoPadrao);

  final String pasta;
  final String extensaoPadrao;

  static FormatoTom? doTexto(Object? texto) => switch (texto) {
        'nam' => FormatoTom.nam,
        'ir' => FormatoTom.ir,
        _ => null,
      };

  /// O formato que o bloco carrega; nulo fora dos dois blocos TONE3000.
  static FormatoTom? doBloco(String uri) => switch (semSufixoDeCanal(uri)) {
        'urn:darkglass:neural:tone3000' => FormatoTom.nam,
        'urn:darkglass-anagram:cabinet-tone3000' => FormatoTom.ir,
        _ => null,
      };
}

/// Um arquivo do tom (o tom do Ampeg SVT tem 8, um por ajuste/microfone).
class ModeloDoTom {
  const ModeloDoTom({required this.id, required this.nome, this.extensao});

  final int id;
  final String nome;

  /// A do `model_url` ("nam", "wav"); nula quando o endereço não a traz.
  final String? extensao;

  static ModeloDoTom? doJson(Object? bruto) {
    final json = mapaOuVazio(bruto);
    final id = numeroOuNulo(json['id'])?.toInt();
    if (id == null) return null;
    return ModeloDoTom(id: id, nome: textoOuNulo(json['name'])?.trim() ?? '$id', extensao: _extensao(json['model_url']));
  }

  static String? _extensao(Object? endereco) {
    final caminho = Uri.tryParse(textoOuNulo(endereco) ?? '')?.path ?? '';
    final ponto = caminho.lastIndexOf('.');
    return ponto < 0 || ponto < caminho.lastIndexOf('/') ? null : caminho.substring(ponto + 1).toLowerCase();
  }
}

class TomTone3000 {
  const TomTone3000({
    required this.id,
    required this.titulo,
    required this.formato,
    required this.modelos,
    this.gear,
    this.autor,
    this.licenca,
    this.doUsuario = false,
  });

  final int id;
  final String titulo;
  final FormatoTom formato;
  final List<ModeloDoTom> modelos;

  /// amp, amp-cab, cab, pedal, outboard, experimental…
  final String? gear;

  /// O `username` de quem publicou o tom no TONE3000.
  final String? autor;
  final String? licenca;

  /// Tom que a pessoa mandou para a pedaleira (fora da lista de fábrica).
  final bool doUsuario;

  /// Nulo quando falta id, título ou formato: sem eles não há o que mostrar.
  static TomTone3000? doJson(Object? bruto, {bool doUsuario = false}) {
    final json = mapaOuVazio(bruto);
    final id = numeroOuNulo(json['id'])?.toInt();
    final titulo = textoOuNulo(json['title'])?.trim();
    final formato = FormatoTom.doTexto(json['format']);
    if (id == null || titulo == null || titulo.isEmpty || formato == null) return null;
    final modelos = json['a2_models'];
    return TomTone3000(
      id: id,
      titulo: titulo,
      formato: formato,
      modelos: [if (modelos is List) ...modelos.map(ModeloDoTom.doJson).nonNulls],
      gear: textoOuNulo(json['gear']),
      autor: textoOuNulo(mapaOuVazio(json['user'])['username']),
      licenca: textoOuNulo(json['license']),
      doUsuario: doUsuario,
    );
  }

  /// O caminho que o bloco grava em `properties["1"].value` para [modelo].
  /// Fábrica: `/factory-data/<pasta>/<tom>/<modelo>.<ext>` — PROVADO para NAM
  /// (preset real com `/factory-data/neural-models-t3k/28202/379991.nam`);
  /// para IR é hipótese por analogia (DECISOES T3K3). Tom da pessoa: nulo,
  /// porque a pedaleira não diz o nome do arquivo dentro da pasta (T3K4).
  String? caminhoDo(ModeloDoTom modelo) {
    if (doUsuario) return null;
    return '/factory-data/${formato.pasta}/$id/${modelo.id}.${modelo.extensao ?? formato.extensaoPadrao}';
  }

  /// Um caminho com a pasta do tom (de fábrica ou da pessoa), para achar a
  /// foto dele como se estivesse carregado num bloco; não é para gravar.
  String get caminhoDeReferencia =>
      '${doUsuario ? '/data/user-files' : '/factory-data'}/${formato.pasta}/$id/${modelos.firstOrNull?.id ?? id}';

  ModeloDoTom? modeloDoArquivo(String nomeDoArquivo) {
    final id = int.tryParse(nomeDoArquivo);
    for (final modelo in modelos) {
      if (modelo.id == id || modelo.nome == nomeDoArquivo) return modelo;
    }
    return null;
  }
}
