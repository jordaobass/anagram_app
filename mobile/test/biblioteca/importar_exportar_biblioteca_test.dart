// Coleções da biblioteca de presets (DECISOES BB2, BB3): cada import vira uma
// coleção nova com o nome do arquivo, o export do Anagram App também é aceito,
// o resultado fica guardado, cada coleção importada se exporta ou se apaga, e
// a lista se filtra pela busca e se ordena pelo nome.
import 'dart:convert';
import 'dart:io';

import 'package:anagram_app/aplicacao/estado/biblioteca_presets.dart';
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/dados/arquivos_biblioteca.dart';
import 'package:anagram_app/dados/arquivos_preset.dart';
import 'package:anagram_app/dados/preferencias_biblioteca.dart';
import 'package:anagram_app/nucleo/modelo/biblioteca_bandas.dart';
import 'package:anagram_app/nucleo/modelo/controles_pedaleira.dart';
import 'package:anagram_app/plataforma/pasta_biblioteca.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';

class _ArquivosFalsos implements ArquivosBiblioteca {
  _ArquivosFalsos({this.escolhido});

  final ArquivoEscolhido? escolhido;
  String? nomeGravado;
  String? gravado;

  @override
  Future<ArquivoEscolhido?> lerEscolhido() async => escolhido;

  @override
  Future<DestinoExportacao> gravar(String nomeSugerido, String texto) async {
    nomeGravado = nomeSugerido;
    gravado = texto;
    return DestinoExportacao.arquivo;
  }
}

/// Um export do Anagram App como o que gerou a biblioteca: um preset no
/// template (com footswitches deduzidos) e um com bloco desconhecido.
const _export = '''
{"device": "Darkglass Anagram", "exported": "2026-12-01", "presets": [
  {"slot": "20A", "name": "MEU FUZZ", "blocks": [
    {"row": 1, "col": 1, "type": "urn:darkglass:FETComp", "name": "FET", "enabled": true, "params": {"Input": 6}},
    {"row": 1, "col": 3, "type": "urn:darkglass:PitchShifter", "enabled": false, "params": {}},
    {"row": 1, "col": 4, "type": "urn:darkglass:neural-plugins:pirate", "enabled": true, "params": {"dist": 7}},
    {"row": 1, "col": 5, "type": "urn:darkglass:Sublime", "enabled": false, "params": {}}
  ]},
  {"slot": "20B", "name": "ESTRANHO", "blocks": [
    {"row": 1, "col": 1, "type": "urn:ninguem:conhece", "enabled": true, "params": {}}
  ]}
]}''';

String _doBuild() => File(CaminhosAssets.bibliotecaBandas).readAsStringSync();

ProviderContainer _container({
  PastaBibliotecaEmMemoria? pasta,
  PreferenciasBibliotecaEmMemoria? preferencias,
  ArquivosBiblioteca? arquivos,
}) {
  final container = ProviderContainer(
    overrides: [
      catalogoProvider.overrideWith((ref) async => lerCatalogo()),
      indiceMiniaturasProvider.overrideWith((ref) async => lerIndiceMiniaturas()),
      textoBibliotecaBandasProvider.overrideWith((ref) async => _doBuild()),
      pastaBibliotecaProvider.overrideWithValue(pasta ?? PastaBibliotecaEmMemoria()),
      preferenciasBibliotecaProvider.overrideWithValue(preferencias ?? PreferenciasBibliotecaEmMemoria()),
      if (arquivos != null) arquivosBibliotecaProvider.overrideWithValue(arquivos),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('arquivo', () {
    test('should_read_an_anagram_app_export_as_one_collection_named_after_the_file', () {
      final fonte = FonteBiblioteca.doTexto(_export, nomeDoArquivo: 'meus presets');

      final colecao = fonte.colecoes.single;
      expect(colecao.nome, 'meus presets');
      expect(colecao.bandas.single.nome, isEmpty, reason: 'o export não tem banda');
      expect(colecao.bandas.single.presets.map((p) => p['name']), ['MEU FUZZ', 'ESTRANHO']);
      expect(
        colecao.bandas.single.presets.first.containsKey('slot'),
        isFalse,
        reason: 'o slot de origem não vem junto',
      );
    });

    test('should_name_the_collection_after_the_export_date_when_the_file_name_is_unknown', () {
      expect(FonteBiblioteca.doTexto(_export).colecoes.single.nome, 'Import 2026-12-01');
    });

    test('should_infer_the_template_footswitches_when_an_export_preset_has_none', () {
      final biblioteca = BibliotecaBandas.daFonte(FonteBiblioteca.doTexto(_export), lerCatalogo());

      final fuzz = biblioteca.presets.single.documento;
      expect(fuzz.controles.keys, containsAll([IdControle.foot1, IdControle.foot2, IdControle.foot3]));
    });

    test('should_refuse_a_file_without_library_presets', () {
      expect(() => FonteBiblioteca.doTexto('{"type": "preset", "version": 1, "preset": {}}'), throwsFormatException);
      expect(() => FonteBiblioteca.doTexto('nem json'), throwsFormatException);
    });

    test('should_read_back_every_collection_when_an_exported_library_is_imported', () {
      final original = FonteBiblioteca.doTexto(
        _doBuild(),
        nomeDoArquivo: 'A',
      ).comImportada(FonteBiblioteca.doTexto(_export, nomeDoArquivo: 'B'));

      final relida = FonteBiblioteca.doTexto(original.paraTexto());

      expect(relida.colecoes.map((c) => c.nome), ['A', 'B']);
      expect(relida.paraTexto(), original.paraTexto());
    });

    test('should_add_a_new_collection_with_a_numbered_name_when_the_name_is_taken', () {
      final uma = FonteBiblioteca.doTexto(_export, nomeDoArquivo: 'X');

      final tres = uma.comImportada(uma).comImportada(uma);

      expect(tres.colecoes.map((c) => c.nome), ['X', 'X (2)', 'X (3)']);
    });
  });

  group('busca e ordem', () {
    BibliotecaBandas doBuild() => BibliotecaBandas.doTexto(_doBuild(), lerCatalogo());

    test('should_keep_every_preset_of_a_band_when_the_search_matches_the_band_name', () {
      final achados = doBuild().filtrada(busca: 'queens');

      expect(achados.presets.map((p) => p.nome), ['QOTSA FUZZ', 'QOTSA DIST']);
    });

    test('should_keep_only_matching_presets_ignoring_case_when_the_search_matches_preset_names', () {
      final achados = doBuild().filtrada(busca: 'dist');

      expect(achados.presets.map((p) => p.nome), ['QOTSA DIST', 'SOAD DIST', 'LB DIST SAM RIVERS']);
    });

    test('should_sort_bands_and_presets_by_name_when_asked', () {
      final az = doBuild().filtrada(ordem: OrdemBiblioteca.nomeAZ).colecoes.single;
      final za = doBuild().filtrada(ordem: OrdemBiblioteca.nomeZA).colecoes.single;

      expect(az.bandas.map((b) => b.nome).first, 'Limp Bizkit');
      expect(az.bandas.first.presets.map((p) => p.nome), ['LB CLEAN SAM RIVERS', 'LB DIST SAM RIVERS']);
      expect(za.bandas.map((b) => b.nome).first, 'Tool');
    });
  });

  group('controlador', () {
    test('should_write_one_file_per_imported_collection_named_after_the_file', () async {
      final pasta = PastaBibliotecaEmMemoria();
      final container = _container(
        pasta: pasta,
        arquivos: _ArquivosFalsos(escolhido: const ArquivoEscolhido('anagram_presets', _export)),
      );

      final resultado = await container.read(fonteBibliotecaProvider.notifier).importar();

      expect(resultado, isA<BibliotecaImportada>());
      expect((resultado as BibliotecaImportada).colecoes, ['anagram_presets']);
      expect(resultado.adicionados, 1);
      expect(resultado.ignorados, 1);
      final biblioteca = await container.read(bibliotecaBandasProvider.future);
      expect(biblioteca.colecoes.map((c) => c.nome), [nomeColecaoEmbutida, 'anagram_presets']);
      expect(biblioteca.colecoes.first.embutida, isTrue);
      expect(pasta.arquivos.keys, ['anagram_presets'], reason: 'a do build não vai para a pasta');
      expect(FonteBiblioteca.doTexto(pasta.arquivos['anagram_presets']!).colecoes.single.nome, 'anagram_presets');
    });

    test('should_refuse_the_import_and_write_nothing_when_no_preset_in_the_file_builds', () async {
      final pasta = PastaBibliotecaEmMemoria();
      final container = _container(pasta: pasta);
      const soEstranho =
          '{"presets": [{"name": "X", "blocks": [{"row": 1, "col": 1, "type": "urn:nada", "params": {}}]}]}';

      final resultado = await container.read(fonteBibliotecaProvider.notifier).importarTexto(soEstranho);

      expect(resultado, isA<ImportacaoBibliotecaRecusada>());
      expect((await container.read(bibliotecaBandasProvider.future)).quantidadePresets, 9);
      expect(pasta.arquivos, isEmpty);
    });

    test('should_list_every_file_in_the_folder_after_the_built_in_collection_including_raw_exports', () async {
      final pasta = PastaBibliotecaEmMemoria({
        'Guardada': FonteBiblioteca.doTexto(_export, nomeDoArquivo: 'Guardada').paraTexto(),
        'posto a mao': _export,
        'lixo': 'nem json',
      });
      final container = _container(pasta: pasta);

      final biblioteca = await container.read(bibliotecaBandasProvider.future);

      expect(biblioteca.colecoes.map((c) => c.nome), [nomeColecaoEmbutida, 'Guardada', 'posto a mao']);
    });

    test('should_read_files_added_to_the_folder_when_the_library_is_read_again', () async {
      final pasta = PastaBibliotecaEmMemoria();
      final container = _container(pasta: pasta);
      await container.read(bibliotecaBandasProvider.future);

      pasta.arquivos['novo'] = _export;
      container.invalidate(fonteBibliotecaProvider);

      final biblioteca = await container.read(bibliotecaBandasProvider.future);
      expect(biblioteca.colecoes.map((c) => c.nome), [nomeColecaoEmbutida, 'novo']);
    });

    test('should_move_the_collections_kept_in_app_preferences_into_the_folder_once', () async {
      final pasta = PastaBibliotecaEmMemoria();
      final preferencias = PreferenciasBibliotecaEmMemoria(
        colecoes: FonteBiblioteca.doTexto(_export, nomeDoArquivo: 'Antes').paraTexto(),
      );
      final container = _container(pasta: pasta, preferencias: preferencias);

      final biblioteca = await container.read(bibliotecaBandasProvider.future);

      expect(biblioteca.colecoes.map((c) => c.nome), [nomeColecaoEmbutida, 'Antes']);
      expect(pasta.arquivos.keys, ['Antes']);
      expect(preferencias.colecoes, isNull, reason: 'levada uma vez só');
    });

    test('should_turn_the_old_merged_library_into_one_import_file_without_the_built_in_bands', () async {
      // a guardada antes das coleções: as bandas do build e as importadas juntas
      final json = jsonDecode(_doBuild()) as Map<String, dynamic>;
      (json['bandas'] as List).add({
        'nome': 'Korn',
        'presets': [
          {
            'name': 'KORN',
            'blocks': [
              {'row': 1, 'col': 1, 'type': 'urn:darkglass:FETComp', 'enabled': true, 'params': <String, dynamic>{}},
            ],
          },
        ],
      });
      final pasta = PastaBibliotecaEmMemoria();
      final preferencias = PreferenciasBibliotecaEmMemoria(antiga: jsonEncode(json));
      final container = _container(pasta: pasta, preferencias: preferencias);

      final biblioteca = await container.read(bibliotecaBandasProvider.future);

      expect(biblioteca.colecoes.map((c) => c.nome), [nomeColecaoEmbutida, 'Import']);
      expect(biblioteca.colecoes.last.bandas.map((b) => b.nome), ['Korn']);
      expect(preferencias.antiga, isNull);
      expect(pasta.arquivos.keys, ['Import']);
    });

    test('should_delete_the_file_of_an_imported_collection_but_never_the_built_in_one', () async {
      final pasta = PastaBibliotecaEmMemoria();
      final container = _container(pasta: pasta);
      final controlador = container.read(fonteBibliotecaProvider.notifier);
      await controlador.importarTexto(_export, nomeDoArquivo: 'X');

      expect(await controlador.removerColecao(nomeColecaoEmbutida), isFalse);
      expect(await controlador.removerColecao('X'), isTrue);

      final biblioteca = await container.read(bibliotecaBandasProvider.future);
      expect(biblioteca.colecoes.map((c) => c.nome), [nomeColecaoEmbutida]);
      expect(pasta.arquivos, isEmpty);
    });

    test('should_rewrite_a_file_without_the_deleted_collection_when_the_file_holds_several', () async {
      final duas = FonteBiblioteca.doTexto(
        _export,
        nomeDoArquivo: 'A',
      ).comImportada(FonteBiblioteca.doTexto(_export, nomeDoArquivo: 'B'));
      final pasta = PastaBibliotecaEmMemoria({'biblioteca-presets': duas.paraTexto()});
      final container = _container(pasta: pasta);
      await container.read(bibliotecaBandasProvider.future);

      await container.read(fonteBibliotecaProvider.notifier).removerColecao('A');

      final restante = FonteBiblioteca.doTexto(pasta.arquivos['biblioteca-presets']!);
      expect(restante.colecoes.map((c) => c.nome), ['B']);
    });

    test('should_write_one_collection_or_the_whole_library_in_the_importable_format_when_exporting', () async {
      final arquivos = _ArquivosFalsos();
      final container = _container(arquivos: arquivos);
      final controlador = container.read(fonteBibliotecaProvider.notifier);
      await controlador.importarTexto(_export, nomeDoArquivo: 'X');

      expect(await controlador.exportar(colecao: 'X'), DestinoExportacao.arquivo);
      expect(arquivos.nomeGravado, 'X');
      expect(FonteBiblioteca.doTexto(arquivos.gravado!).colecoes.map((c) => c.nome), ['X']);

      await controlador.exportar();
      expect(FonteBiblioteca.doTexto(arquivos.gravado!).colecoes.map((c) => c.nome), [nomeColecaoEmbutida, 'X']);
    });
  });

  test('should_pick_a_free_safe_file_name_when_the_name_is_taken_or_unsafe', () {
    expect(nomeLivre('Muse', {'muse'}), 'Muse (2)');
    expect(nomeLivre('a/b:c', {}), 'abc');
    expect(nomeLivre('..', {}), 'colecao');
  });
}
