import 'dart:convert';

import 'package:anagram_app/aplicacao/arte/indice_miniaturas.dart';
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/nucleo/registro.dart';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';

/// Pacote de assets como o de um clone público: a pasta de terceiros vazia.
class _PacoteSemMiniaturas extends CachingAssetBundle {
  @override
  Future<ByteData> load(String chave) async =>
      throw FlutterError('Unable to load asset: "$chave".');
}

/// Índice que chegou malformado (arquivo editado à mão, ferramenta com defeito).
class _PacoteComIndiceMalformado extends CachingAssetBundle {
  @override
  Future<ByteData> load(String chave) async =>
      ByteData.sublistView(Uint8List.fromList(utf8.encode('{"blocos": {"x": {"arquivo": 7, "uris": "nao-e-lista"}}}')));
}

void main() {
  test('should_use_own_category_art_when_third_party_thumbnails_are_absent', () async {
    final container = ProviderContainer(overrides: [pacoteAssetsProvider.overrideWithValue(_PacoteSemMiniaturas())]);

    final indice = await container.read(indiceMiniaturasProvider.future);
    final compressor = lerCatalogo().definicao('urn:darkglass:CompLim');

    expect(indice.vazio, isTrue);
    expect(indice.arteDe(compressor), isA<ArteDaFamilia>());
  });

  test('should_log_the_cause_and_fall_back_to_own_art_when_the_thumbnail_index_is_malformed', () async {
    final linhas = <String>[];
    final ouvinte = _Ouvinte(linhas);
    saidasDoRegistro.acrescentar(ouvinte);
    addTearDown(() => saidasDoRegistro.remover(ouvinte));
    final container =
        ProviderContainer(overrides: [pacoteAssetsProvider.overrideWithValue(_PacoteComIndiceMalformado())]);

    final indice = await container.read(indiceMiniaturasProvider.future);

    expect(indice.vazio, isTrue, reason: 'um índice ruim não derruba a arte de todos os blocos');
    expect(linhas.join('\n'), contains('índice de miniaturas'), reason: 'o log diz o que falhou');
    expect(linhas.join('\n'), contains('is not a subtype'), reason: 'e por quê');
  });
}

class _Ouvinte extends LogOutput {
  _Ouvinte(this.linhas);
  final List<String> linhas;

  @override
  void output(OutputEvent event) => linhas.addAll(event.lines);
}
