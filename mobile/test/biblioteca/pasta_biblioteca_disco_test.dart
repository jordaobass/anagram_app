// A pasta da biblioteca em disco (DECISOES BB4): um arquivo .json por
// coleção, listados na ordem em que entraram; outros arquivos ficam de fora.
import 'dart:io';

import 'package:anagram_app/plataforma/pasta_biblioteca_io.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory raiz;
  late PastaBibliotecaEmDisco pasta;

  setUp(() {
    raiz = Directory.systemTemp.createTempSync('biblioteca_');
    pasta = PastaBibliotecaEmDisco(Directory('${raiz.path}/biblioteca'));
  });
  tearDown(() => raiz.deleteSync(recursive: true));

  test('should_list_nothing_before_the_folder_exists', () async {
    expect(await pasta.listar(), isEmpty);
  });

  test('should_create_files_with_free_names_and_list_them_in_the_order_they_came_in', () async {
    final primeiro = await pasta.criar('Muse', '{"a": 1}');
    // a ordem vem da data do arquivo: o segundo tem de ser mais novo
    File('${pasta.caminho}/$primeiro.json').setLastModifiedSync(DateTime(2020));
    final segundo = await pasta.criar('Muse', '{"b": 2}');
    File('${pasta.caminho}/ignorado.txt').writeAsStringSync('x');

    final lidos = await pasta.listar();

    expect([primeiro, segundo], ['Muse', 'Muse (2)']);
    expect(lidos.map((a) => a.nome), ['Muse', 'Muse (2)']);
    expect(lidos.last.texto, '{"b": 2}');
  });

  test('should_rewrite_and_delete_a_file_by_name', () async {
    final nome = await pasta.criar('X', 'antes');

    await pasta.regravar(nome, 'depois');
    expect((await pasta.listar()).single.texto, 'depois');

    await pasta.apagar(nome);
    expect(await pasta.listar(), isEmpty);
    await pasta.apagar(nome);
  });
}
