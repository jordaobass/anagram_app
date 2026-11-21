// O gabinete muda de foto conforme o arquivo de IR escolhido no bloco, como no
// Darkglass Suite: "212 103 on axis_01-MP" é o Darkglass Neo 2x12. Sem IR, a
// foto genérica do bloco; desligado, a versão "Bypass" do mesmo gabinete.
import 'dart:convert';

import 'package:anagram_app/aplicacao/arte/indice_miniaturas.dart';
import 'package:anagram_app/nucleo/catalogo/definicao_bloco.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:anagram_app/nucleo/modelo/documento_preset.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';

const _uri = 'urn:darkglass-anagram:cabinet-bass';
const _ir = '/factory-data/cabinets/212 103 on axis_01-MP.dat';

final _indice = IndiceMiniaturas.doTexto(jsonEncode({
  'credito': 'Darkglass',
  'blocos': {
    'dg_bass': {
      'nome': 'Bass Cabinet',
      'arquivo': 'assets/blocos_terceiros/dg_cabinet-bass.png',
      'arquivoDesligado': 'assets/blocos_terceiros/dg_cabinet-bass-Off.png',
      'uris': [_uri],
      'origem': 'pedaleira',
    },
  },
  'gabinetes': {
    'porArquivo': {
      '212 103 on axis_01-MP': [
        'assets/blocos_terceiros/dg_cab_DG212N.webp',
        'assets/blocos_terceiros/dg_cab_Bypass-DG212N.webp',
      ],
    },
  },
}));

const _definicao =
    DefinicaoBloco(uri: _uri, nome: 'Bass Cabinet', abreviacao: 'CAB', categoria: 'Amp & Cabs', parametros: []);

void main() {
  test('should_show_the_chosen_cabinet_photo_when_the_block_has_an_impulse_file', () {
    final arte = _indice.arteDe(_definicao, arquivoIr: _ir) as ArteMiniatura;

    expect(arte.caminhoAsset, 'assets/blocos_terceiros/dg_cab_DG212N.webp');
    expect(arte.caminhoDesligado, 'assets/blocos_terceiros/dg_cab_Bypass-DG212N.webp');
  });

  test('should_show_the_generic_cabinet_when_the_block_has_no_impulse_or_an_unknown_one', () {
    expect((_indice.arteDe(_definicao) as ArteMiniatura).caminhoAsset, 'assets/blocos_terceiros/dg_cabinet-bass.png');
    expect((_indice.arteDe(_definicao, arquivoIr: '/data/user-files/cabinets/meu.wav') as ArteMiniatura).caminhoAsset,
        'assets/blocos_terceiros/dg_cabinet-bass.png');
  });

  test('should_read_the_impulse_file_that_the_pedal_saved_in_the_cabinet_block', () {
    final preset = DocumentoPreset.doJson(lerExemplo('2'));
    final gabinete = [
      for (final linha in [1, 2]) ...preset.blocosDaLinha(linha),
    ].firstWhere((b) => b.uri == _uri);

    expect(gabinete.arquivoDeIr, _ir);
  });

  test('should_have_no_impulse_file_when_the_block_has_no_properties', () {
    expect(const BlocoPreset(PosicaoBloco(1, 1), {'uri': _uri, 'properties': <String, dynamic>{}}).arquivoDeIr, isNull);
  });
}
