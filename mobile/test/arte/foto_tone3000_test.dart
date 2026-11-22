// O bloco TONE3000 mostra a foto do tom carregado, como o Darkglass Suite: o
// tom de fábrica pela foto que a ferramenta trouxe (casada pelo número do tom,
// a pasta do arquivo); o tom da pessoa, no computador, pela foto que o Suite
// baixou na pasta dele; sem foto, a arte do bloco.
import 'dart:io';

import 'package:anagram_app/aplicacao/arte/indice_miniaturas.dart';
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/apresentacao/componentes/arte_bloco.dart';
import 'package:anagram_app/l10n/app_localizations.dart';
import 'package:anagram_app/nucleo/catalogo/definicao_bloco.dart';
import 'package:anagram_app/plataforma/fotos_suite.dart';
import 'package:anagram_app/plataforma/fotos_suite_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';

const _nam = 'urn:darkglass:neural:tone3000';
const _ir = 'urn:darkglass-anagram:cabinet-tone3000#stereo';

const _indice = '''
{"credito": "Imagens: teste", "blocos": {
  "dg_nam": {"nome": "", "origem": "pedaleira", "arquivo": "assets/blocos_terceiros/dg_T3K.png",
    "uris": ["$_nam", "$_ir"]}},
 "tone3000": {"tons": {
    "1612": {"titulo": "Mesa OS 4x12 IR", "gear": "cab", "foto": "assets/blocos_terceiros/t3k_1612.jpg"},
    "777": {"titulo": "Sem foto", "gear": "pedal"}},
  "porGear": {"pedal": "assets/blocos_terceiros/t3k_gear_pedal.png"}}}''';

class _SuiteFalso implements FotosDoSuite {
  _SuiteFalso(this.caminho);
  final String caminho;
  final pedidos = <(int, bool)>[];

  @override
  String? fotoDoTom(int id, {required bool ehIr}) {
    pedidos.add((id, ehIr));
    return id == 4242 ? caminho : null;
  }
}

void main() {
  final indice = IndiceMiniaturas.doTexto(_indice);
  ArteBloco arte(String uri, String valor, {FotosDoSuite? suite}) =>
      indice.arteDe(DefinicaoBloco.desconhecido(uri), arquivoIr: valor, fotosDoSuite: suite);
  String? asset(ArteBloco a) => a is ArteMiniatura ? a.caminhoAsset : null;

  test('should_show_the_factory_tone_photo_matched_by_the_tone_number_in_the_path', () {
    expect(asset(arte(_nam, '/factory-data/neural-models-t3k/1612/1612-Mesa.nam')), 'assets/blocos_terceiros/t3k_1612.jpg');
    expect(asset(arte(_nam, '/factory-data/neural-models-t3k/777/x.nam')), 'assets/blocos_terceiros/t3k_gear_pedal.png',
        reason: 'sem foto, o ícone do tipo de equipamento');
  });

  test('should_read_the_user_tone_photo_from_the_suite_folder_or_keep_the_block_art', () {
    final suite = _SuiteFalso('/suite/t3k/irs-t3k/4242/tone.jpg');

    final daPessoa = arte(_ir, '/data/user-files/irs-t3k/4242/Meu Cab.wav', suite: suite);
    expect(daPessoa, isA<ArteFotoExterna>().having((a) => a.caminho, 'caminho', '/suite/t3k/irs-t3k/4242/tone.jpg'));
    expect(suite.pedidos, [(4242, true)]);
    expect(asset(arte(_nam, '/data/user-files/neural-models-t3k/5555/Outro.nam', suite: suite)),
        'assets/blocos_terceiros/dg_T3K.png');
    expect(asset(arte(_nam, '/data/user-files/neural-models-t3k/4242/Meu.nam')), 'assets/blocos_terceiros/dg_T3K.png',
        reason: 'sem o Suite instalado');
  });

  test('should_find_the_suite_data_folder_on_each_desktop_system', () {
    String? pasta(String sistema, Map<String, String> ambiente) => pastaDoSuite(sistema, ambiente)?.path;
    final s = Platform.pathSeparator;

    expect(pasta('windows', {'APPDATA': r'C:\Users\a\AppData\Roaming'}), 'C:\\Users\\a\\AppData\\Roaming${s}Darkglass Suite');
    expect(pasta('macos', {'HOME': '/Users/a'}), '/Users/a${s}Library${s}Application Support${s}Darkglass Suite');
    expect(pasta('linux', {'HOME': '/home/a', 'XDG_CONFIG_HOME': ' '}), '/home/a$s.config${s}Darkglass Suite');
    expect(pasta('android', {'HOME': '/data'}), isNull);
  });

  testWidgets('should_paint_the_photo_the_suite_downloaded_for_the_user_tone', (tester) async {
    final pasta = Directory.systemTemp.createTempSync('suite');
    addTearDown(() => pasta.deleteSync(recursive: true));
    final foto = File('${pasta.path}/t3k/neural-models-t3k/4242/tone.jpg')..createSync(recursive: true);
    final suite = FotosNaPasta(pasta.path);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        indiceMiniaturasProvider.overrideWith((ref) async => indice),
        fotosDoSuiteProvider.overrideWithValue(suite),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ArteBlocoWidget(
            definicao: lerCatalogo().definicao(_nam),
            tamanho: 64,
            arquivoIr: '/data/user-files/neural-models-t3k/4242/Meu.nam'),
      ),
    ));
    await tester.pump();

    final imagem = tester.widget<Image>(find.byType(Image));
    expect((imagem.image as FileImage).file.path, foto.path);
  });

  test('should_have_a_photo_on_disk_for_every_factory_tone_in_the_real_index', () {
    final real = lerIndiceVersionado();
    final fotos = [
      for (final id in [1612, 26483, 26828, 27465, 28202, 31010, 36273, 43868, 44680, 45809, 49310, 50546, 53231, 57611, 61091])
        real.tons.deFabrica(id)?.foto,
    ];

    expect(fotos, everyElement(isNotNull));
    expect(fotos.where((f) => !File(f!).existsSync()), isEmpty);
  });
}
