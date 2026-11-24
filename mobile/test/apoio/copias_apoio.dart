// Backups nos testes: uma pasta temporária de verdade (apagada no fim) e a
// pedaleira de demonstração com o backup ligado.
import 'dart:io';

import 'package:anagram_app/aplicacao/copias/copia_automatica.dart';
import 'package:anagram_app/aplicacao/estado/controlador_biblioteca.dart';
import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/plataforma/copias_de_seguranca.dart';
import 'package:anagram_app/plataforma/copias_de_seguranca_io.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_de_teste.dart';
import 'fixtures.dart';

/// Pasta temporária própria do teste; some no fim dele.
Directory pastaTemporaria() {
  final pasta = Directory.systemTemp.createTempSync('anagram-backups-');
  addTearDown(() {
    if (pasta.existsSync()) pasta.deleteSync(recursive: true);
  });
  return pasta;
}

/// Relógio fixo dos testes: os nomes dos arquivos não dependem da hora em que rodam.
DateTime agoraFixo() => DateTime(2026, 11, 22, 14, 30, 5);

/// A pasta `backups` dentro da temporária, com o relógio fixo.
PastaDeCopiasEmDisco pastaDeBackups({DateTime Function() agora = agoraFixo, int dias = 30, int maximo = 500}) =>
    PastaDeCopiasEmDisco(Directory('${pastaTemporaria().path}${Platform.pathSeparator}backups'),
        agora: agora, dias: dias, maximo: maximo);

/// Uma pasta cujo caminho é um arquivo comum: criar qualquer coisa dentro dela falha.
PastaDeCopiasEmDisco pastaQueRecusa() {
  final ocupado = File('${pastaTemporaria().path}${Platform.pathSeparator}backups')..writeAsStringSync('não é pasta');
  return PastaDeCopiasEmDisco(Directory(ocupado.path), agora: agoraFixo);
}

/// O app (sem widgets) conectado à demonstração, com [pasta] como pasta de backups.
Future<(ProviderContainer, TransporteDemonstracao)> conectarComBackups(PastaDeCopias pasta,
    {bool automatico = true}) async {
  final container = ProviderContainer(overrides: [
    presetsDemonstracaoProvider.overrideWith((ref) async => lerPresetsDemonstracao()),
    pastaDeCopiasProvider.overrideWithValue(pasta),
    preferenciasCopiasProvider.overrideWithValue(PreferenciasCopiasEmMemoria(automatico)),
    copiaAutomaticaSalvaProvider.overrideWithValue(automatico),
  ]);
  addTearDown(container.dispose);
  container.read(bibliotecaProvider);
  await container.read(conexaoProvider.notifier).conectarDemonstracao();
  await _esperarLista(container);
  final transporte = container.read(conexaoProvider.notifier).transporte! as TransporteDemonstracao;
  return (container, transporte);
}

/// A lista (e as áreas) chegam depois de conectar, como a pessoa vê ao abrir.
Future<void> _esperarLista(ProviderContainer container) async {
  for (var i = 0; i < 500; i++) {
    final estado = container.read(bibliotecaProvider);
    if (!estado.carregando && estado.ocupados.isNotEmpty) return;
    await Future<void>.delayed(const Duration(milliseconds: 2));
  }
}

/// Os JSON da pasta (recursivo), sem os temporários.
List<File> arquivosDeBackup(PastaDeCopiasEmDisco pasta) => !pasta.raiz.existsSync()
    ? const []
    : pasta.raiz.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.json')).toList();
