// Os READMEs da raiz trazem os links diretos dos três zips da versão atual.
// Quem sobe a versão no pubspec e esquece os links manda o usuário baixar a
// versão velha (ou um arquivo que não existe): este teste fica vermelho até
// os dois READMEs apontarem para a tag nova.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _readmes = ['../README.md', '../README.pt-BR.md'];
const _sistemas = ['windows', 'macos', 'macos-intel'];

String _versaoDoPubspec() {
  final linha = File('pubspec.yaml')
      .readAsLinesSync()
      .firstWhere((linha) => linha.startsWith('version:'));
  return linha.split(':').last.trim().split('+').first;
}

void main() {
  final versao = _versaoDoPubspec();
  final base =
      'https://github.com/jordaobass/anagram_app/releases/download/v$versao';

  for (final readme in _readmes) {
    test('$readme aponta os três downloads para a versão $versao do pubspec',
        () {
      final texto = File(readme).readAsStringSync();
      final faltando = [
        for (final sistema in _sistemas)
          if (!texto.contains('$base/anagram-app-$sistema-$versao.zip'))
            'anagram-app-$sistema-$versao.zip',
      ];
      expect(faltando, isEmpty,
          reason: 'atualize a seção de download de $readme para v$versao');
    });
  }
}
