// A pedaleira e o Darkglass Suite tratam a mesma uri com e sem o sufixo de
// canal ("#stereo", "#mono"). O bloco que chega com sufixo não pode perder a
// arte da pedaleira nem o nome por isso.
import 'package:anagram_app/aplicacao/arte/indice_miniaturas.dart';
import 'package:anagram_app/nucleo/catalogo/definicao_bloco.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';

const _indice = '''
{"credito": "Imagens: teste", "blocos": {
  "dg_chorus": {"nome": "", "origem": "pedaleira", "arquivo": "assets/blocos_terceiros/dg_Chorus.png",
    "uris": ["urn:darkglass:Chorus"]},
  "dg_t3k": {"nome": "", "origem": "pedaleira", "arquivo": "assets/blocos_terceiros/dg_T3K.png",
    "uris": ["urn:darkglass-anagram:cabinet-tone3000#stereo"]},
  "dg_mono": {"nome": "", "origem": "pedaleira", "arquivo": "assets/blocos_terceiros/dg_Mono.png",
    "uris": ["urn:teste:so-mono#mono"]}
}}''';

String? _arquivo(ArteBloco arte) => arte is ArteMiniatura ? arte.caminhoAsset : null;

void main() {
  final indice = IndiceMiniaturas.doTexto(_indice);

  test('should_find_the_pedal_art_when_the_block_uri_has_a_stereo_suffix_not_in_the_index', () {
    final bloco = DefinicaoBloco.desconhecido('urn:darkglass:Chorus#stereo');

    expect(_arquivo(indice.arteDe(bloco)), 'assets/blocos_terceiros/dg_Chorus.png');
  });

  test('should_find_the_pedal_art_when_only_the_stereo_variant_is_in_the_index', () {
    final bloco = DefinicaoBloco.desconhecido('urn:darkglass-anagram:cabinet-tone3000');

    expect(_arquivo(indice.arteDe(bloco)), 'assets/blocos_terceiros/dg_T3K.png');
  });

  test('should_find_the_art_when_only_the_mono_variant_is_in_the_index', () {
    final bloco = DefinicaoBloco.desconhecido('urn:teste:so-mono');

    expect(_arquivo(indice.arteDe(bloco)), 'assets/blocos_terceiros/dg_Mono.png');
  });

  test('should_name_the_block_from_the_catalog_when_the_uri_has_a_channel_suffix', () {
    final catalogo = lerCatalogo();

    expect(catalogo.definicao('urn:darkglass:Suppressor#stereo').nome, 'Suppressor');
    expect(catalogo.definicao('urn:darkglass:Suppressor#mono').nome, 'Suppressor');
  });

  test('should_say_whether_the_pedal_art_is_embedded_when_the_index_is_read', () {
    expect(indice.temArteDaPedaleira, isTrue);
    expect(IndiceMiniaturas.vazio().temArteDaPedaleira, isFalse);
    const soDeTerceiros = '{"blocos": {"b3k": {"nome": "B3K", "arquivo": "a.png", "uris": ["urn:darkglass:B3K"]}}}';
    expect(IndiceMiniaturas.doTexto(soDeTerceiros).temArteDaPedaleira, isFalse);
  });
}
