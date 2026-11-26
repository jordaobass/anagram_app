// A pasta da biblioteca em disco (DECISOES BB4): `biblioteca` dentro da pasta
// de suporte do app (path_provider; no macOS, dentro do sandbox, onde o app
// pode ler e gravar sem pedir). A ordem dos arquivos é a da última gravação:
// o app só grava um arquivo ao importar, então é a ordem em que entraram.
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../nucleo/registro.dart';
import 'pasta_biblioteca.dart';

Future<PastaBiblioteca> ligarPastaBiblioteca() async {
  try {
    final suporte = await getApplicationSupportDirectory();
    final pasta = Directory('${suporte.path}${Platform.pathSeparator}biblioteca');
    registro.i('biblioteca: pasta ${pasta.path}');
    return PastaBibliotecaEmDisco(pasta);
  } on Object catch (erro) {
    registro.e('biblioteca: o sistema não deu a pasta de suporte do app; biblioteca só em memória', error: erro);
    return PastaBibliotecaEmMemoria();
  }
}

class PastaBibliotecaEmDisco implements PastaBiblioteca {
  PastaBibliotecaEmDisco(this._pasta);

  final Directory _pasta;

  @override
  String get caminho => _pasta.path;

  @override
  Future<void> preparar() => _pasta.create(recursive: true);

  File _arquivo(String nome) => File('${_pasta.path}${Platform.pathSeparator}$nome.json');

  @override
  Future<List<ArquivoDaPasta>> listar() async {
    if (!await _pasta.exists()) return const [];
    final arquivos = [
      await for (final item in _pasta.list())
        if (item is File && item.path.toLowerCase().endsWith('.json')) item,
    ];
    final quando = {for (final a in arquivos) a.path: await a.lastModified()};
    arquivos.sort((a, b) {
      final porData = quando[a.path]!.compareTo(quando[b.path]!);
      return porData != 0 ? porData : a.path.compareTo(b.path);
    });
    final lidos = <ArquivoDaPasta>[];
    for (final arquivo in arquivos) {
      final nome = arquivo.uri.pathSegments.last;
      try {
        lidos.add(
          ArquivoDaPasta(
            Uri.decodeComponent(nome).replaceFirst(RegExp(r'\.json$', caseSensitive: false), ''),
            await arquivo.readAsString(),
          ),
        );
      } on FileSystemException catch (erro) {
        registro.w('biblioteca: ${arquivo.path} não foi lido', error: erro);
      } on FormatException catch (erro) {
        registro.w('biblioteca: ${arquivo.path} não é texto', error: erro);
      }
    }
    return lidos;
  }

  @override
  Future<String> criar(String nomeSugerido, String texto) async {
    await _pasta.create(recursive: true);
    final usados = {for (final a in await listar()) a.nome.toLowerCase()};
    final nome = nomeLivre(nomeSugerido, usados);
    await _arquivo(nome).writeAsString(texto, flush: true);
    return nome;
  }

  @override
  Future<void> regravar(String nome, String texto) => _arquivo(nome).writeAsString(texto, flush: true);

  @override
  Future<void> apagar(String nome) async {
    final arquivo = _arquivo(nome);
    if (await arquivo.exists()) await arquivo.delete();
  }
}
