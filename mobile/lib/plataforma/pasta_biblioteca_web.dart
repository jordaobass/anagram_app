// Na web não há pasta: os arquivos da biblioteca ficam juntos numa chave das
// preferências do navegador, como um mapa nome → texto (DECISOES BB4).
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../nucleo/modelo/json_util.dart';
import 'pasta_biblioteca.dart';

Future<PastaBiblioteca> ligarPastaBiblioteca() async => PastaBibliotecaNasPreferencias();

class PastaBibliotecaNasPreferencias implements PastaBiblioteca {
  static const _chave = 'biblioteca.arquivos';

  @override
  String get caminho => '';

  @override
  Future<void> preparar() async {}

  Future<Map<String, String>> _ler() async {
    final texto = (await SharedPreferences.getInstance()).getString(_chave);
    if (texto == null) return {};
    return {
      for (final MapEntry(:key, :value) in mapaOuVazio(jsonDecode(texto)).entries)
        if (value is String) key: value,
    };
  }

  Future<void> _gravar(Map<String, String> arquivos) async =>
      (await SharedPreferences.getInstance()).setString(_chave, jsonEncode(arquivos));

  @override
  Future<List<ArquivoDaPasta>> listar() async => [
    for (final MapEntry(key: nome, value: texto) in (await _ler()).entries) ArquivoDaPasta(nome, texto),
  ];

  @override
  Future<String> criar(String nomeSugerido, String texto) async {
    final arquivos = await _ler();
    final nome = nomeLivre(nomeSugerido, {for (final n in arquivos.keys) n.toLowerCase()});
    await _gravar({...arquivos, nome: texto});
    return nome;
  }

  @override
  Future<void> regravar(String nome, String texto) async => _gravar({...await _ler(), nome: texto});

  @override
  Future<void> apagar(String nome) async => _gravar({...await _ler()}..remove(nome));
}
