// Blocos que a pedaleira conectada tem e o catálogo de fábrica não (comprados
// no Marketplace, firmware mais novo; DECISOES P4). Ao conectar, a lista do
// que está instalado (`read_all_plugins`); ao abrir um preset, o que ele usa
// fora do catálogo. Cada uri é pedida uma vez por conexão (`get_plugin_info`,
// um pedido por vez na fila do protocolo); desconectar descarta tudo, porque
// outra pedaleira pode ter outros blocos.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../nucleo/catalogo/catalogo_blocos.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/catalogo/plugins_da_pedaleira.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../../nucleo/modelo/documento_preset.dart';
import '../../nucleo/registro.dart';
import '../../nucleo/resultado.dart';
import '../provedores.dart';
import 'controlador_conexao.dart';
import 'controlador_editor.dart';
import 'estado_conexao.dart';

final blocosDaPedaleiraProvider =
    NotifierProvider<BlocosDaPedaleira, Map<String, DefinicaoBloco>>(BlocosDaPedaleira.new);

class BlocosDaPedaleira extends Notifier<Map<String, DefinicaoBloco>> {
  final _pedidas = <String>{};

  /// Os pedidos em curso, um depois do outro. O MCP espera por eles antes de
  /// listar ou descrever blocos, para a IA não ver o bloco como desconhecido
  /// só porque a resposta da pedaleira ainda não chegou.
  Future<void> _trabalho = Future.value();
  Future<void> get emAndamento => _trabalho;

  /// Muda a cada conexão: resposta da conexão anterior não entra na nova.
  int _conexao = 0;

  @override
  Map<String, DefinicaoBloco> build() {
    final firmware = ref.watch(conexaoProvider.select((estado) => estado is Conectada ? estado.firmware : null));
    _pedidas.clear();
    final conexao = ++_conexao;
    if (firmware != null && firmwareComPlugins(firmware)) {
      _enfileirar(() => _lerInstalados(conexao));
      ref.listen(editorProvider.select((estado) => estado.atual),
          (_, documento) => _enfileirar(() => _pedirDoPreset(documento, conexao)),
          fireImmediately: true);
    }
    return const {};
  }

  void _enfileirar(Future<void> Function() tarefa) {
    final proximo = _trabalho.then((_) => tarefa());
    _trabalho = proximo.catchError((Object erro, StackTrace pilha) =>
        registro.w('blocos da pedaleira: leitura falhou', error: erro, stackTrace: pilha));
    unawaited(_trabalho);
  }

  Future<void> _lerInstalados(int conexao) async {
    final repositorio = ref.read(conexaoProvider.notifier).repositorio;
    if (repositorio == null) return;
    if (await repositorio.listarPlugins() case Sucesso(:final valor)) {
      await _pedirForaDoCatalogo(urisDosPlugins(valor), conexao);
    }
  }

  Future<void> _pedirDoPreset(DocumentoPreset? documento, int conexao) async {
    if (documento == null) return;
    final uris = {
      for (final linha in const [1, 2]) ...documento.blocosDaLinha(linha).map((BlocoPreset b) => b.uri),
    }..remove('');
    await _pedirForaDoCatalogo(uris, conexao);
  }

  Future<void> _pedirForaDoCatalogo(Iterable<String> uris, int conexao) async {
    final CatalogoBlocos fabrica = await ref.read(catalogoProvider.future);
    for (final uri in uris) {
      if (conexao != _conexao || fabrica.conhece(uri) || !_pedidas.add(uri)) continue;
      await _pedir(uri, fabrica, conexao);
    }
  }

  Future<void> _pedir(String uri, CatalogoBlocos fabrica, int conexao) async {
    final repositorio = ref.read(conexaoProvider.notifier).repositorio;
    if (repositorio == null) return;
    final resposta = await repositorio.infoDoPlugin(uri);
    if (conexao != _conexao) return;
    if (resposta case Sucesso(:final valor)) {
      final definicao = definicaoDoPluginInfo(uri, valor, fabrica.nomeDaCategoria);
      if (definicao != null) state = {...state, uri: definicao};
    }
  }
}
