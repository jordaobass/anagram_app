// Arquivos abertos com o app (DECISOES BB5). No Windows e no Linux, o "Abrir
// com" do sistema abre o app com o caminho do arquivo nos argumentos. No
// macOS o sistema entrega pelo AppDelegate, com o app já aberto ou abrindo
// por causa do arquivo: o canal guarda os que chegam antes de o Dart dizer
// "pronto". Só os caminhos: ler e importar é de quem ouve.
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../nucleo/registro.dart';

class ArquivosAbertos {
  const ArquivosAbertos({this.argumentos = const [], this.canal});

  /// Ninguém abre arquivo com o app (web, celular, testes).
  const ArquivosAbertos.nenhum() : argumentos = const [], canal = null;

  /// Do `main` no computador: argumentos e, no macOS, o canal do AppDelegate.
  factory ArquivosAbertos.daPlataforma(List<String> argumentos) => ArquivosAbertos(
    argumentos: argumentos,
    canal: !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS
        ? const MethodChannel('anagram/arquivos_abertos')
        : null,
  );

  final List<String> argumentos;
  final MethodChannel? canal;

  /// Cada lote de caminhos, na ordem em que chegaram. Os da linha de comando
  /// vêm primeiro (são os da abertura). Argumento que não é arquivo `.json`
  /// (uma opção do sistema, um caminho qualquer) fica de fora.
  Stream<List<String>> ouvir() {
    final saida = StreamController<List<String>>();
    final iniciais = argumentos.where(ehColecao).toList();
    if (iniciais.isNotEmpty) saida.add(iniciais);
    final canal = this.canal;
    if (canal != null) {
      canal.setMethodCallHandler((chamada) async {
        if (chamada.method == 'abrir') _entregar(saida, chamada.arguments);
      });
      unawaited(_pedirPendentes(canal, saida));
    }
    saida.onCancel = () => canal?.setMethodCallHandler(null);
    return saida.stream;
  }

  static Future<void> _pedirPendentes(MethodChannel canal, StreamController<List<String>> saida) async {
    try {
      _entregar(saida, await canal.invokeMethod<List<Object?>>('pronto'));
    } on Exception catch (erro) {
      // runner sem o canal (build antigo): só o arrastar funciona
      registro.w('arquivos abertos: o canal do sistema não respondeu', error: erro);
    }
  }

  static void _entregar(StreamController<List<String>> saida, Object? caminhos) {
    final lista = [
      for (final c in caminhos is List ? caminhos : const [])
        if (c is String && ehColecao(c)) c,
    ];
    if (lista.isNotEmpty && !saida.isClosed) saida.add(lista);
  }

  /// Arquivo que pode ser uma coleção da biblioteca (pela extensão).
  static bool ehColecao(String caminho) => caminho.toLowerCase().endsWith('.json');
}
