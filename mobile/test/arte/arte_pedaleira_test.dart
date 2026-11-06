import 'package:anagram_app/aplicacao/arte/indice_miniaturas.dart';
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/apresentacao/componentes/arte_bloco.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';

/// Índice com a ficha de terceiros DEPOIS da arte da pedaleira e casando a
/// mesma uri: a ordem do arquivo não pode decidir quem vence.
const _indice = '''
{"credito": "Imagens: teste", "blocos": {
  "dg_urn_darkglass_B3K": {"nome": "Microtubes B3K", "origem": "pedaleira",
    "arquivo": "assets/blocos_terceiros/dg_B3K.png", "arquivoDesligado": "assets/blocos_terceiros/dg_B3K-Off.png",
    "uris": ["urn:darkglass:B3K"]},
  "b3k": {"nome": "B3K", "arquivo": "assets/blocos_terceiros/b3k.png", "uris": ["urn:darkglass:B3K"]},
  "dg_urn_darkglass_crier": {"nome": "", "origem": "pedaleira",
    "arquivo": "assets/blocos_terceiros/dg_Crier.png", "arquivoDesligado": "assets/blocos_terceiros/dg_Crier-Off.png",
    "uris": ["urn:darkglass:crier"]}
}}''';

void main() {
  final b3k = lerCatalogo().definicao('urn:darkglass:B3K');

  test('should_prefer_the_pedal_own_art_over_third_party_thumbnail_for_the_same_uri', () {
    final arte = IndiceMiniaturas.doTexto(_indice).arteDe(b3k) as ArteMiniatura;

    expect(arte.caminhoAsset, 'assets/blocos_terceiros/dg_B3K.png');
    expect(arte.caminhoDesligado, 'assets/blocos_terceiros/dg_B3K-Off.png');
  });

  testWidgets('should_show_the_pedal_bypass_image_when_the_block_is_off', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [indiceMiniaturasProvider.overrideWith((ref) async => IndiceMiniaturas.doTexto(_indice))],
      child: MaterialApp(home: ArteBlocoWidget(definicao: b3k, tamanho: 64, ligado: false)),
    ));
    await tester.pump();

    final imagem = tester.widget<Image>(find.byType(Image));
    expect((imagem.image as AssetImage).assetName, 'assets/blocos_terceiros/dg_B3K-Off.png');
    expect(find.byType(ColorFiltered), findsNothing);
  });
}
