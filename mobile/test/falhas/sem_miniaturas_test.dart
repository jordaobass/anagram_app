import 'package:anagram_app/aplicacao/arte/indice_miniaturas.dart';
import 'package:anagram_app/aplicacao/provedores.dart';
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

void main() {
  test('should_use_own_category_art_when_third_party_thumbnails_are_absent', () async {
    final container = ProviderContainer(overrides: [pacoteAssetsProvider.overrideWithValue(_PacoteSemMiniaturas())]);

    final indice = await container.read(indiceMiniaturasProvider.future);
    final compressor = lerCatalogo().definicao('urn:darkglass:CompLim');

    expect(indice.vazio, isTrue);
    expect(indice.arteDe(compressor), isA<ArteDaFamilia>());
  });
}
