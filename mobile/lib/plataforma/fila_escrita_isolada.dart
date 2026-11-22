// Escrita de relatórios USB num isolate próprio, para o `hid_write`
// (bloqueante, ~7–13 ms por relatório no Windows) não parar a interface.
// É o equivalente da fila serial do macOS (CanalHidAnagram.swift): um
// relatório por vez, na ordem de chegada, e cada Future só conclui depois que
// o relatório foi escrito. Encerrar deixa terminar o que já estava na fila e
// só então devolve: quem fecha o dispositivo espera por isso, senão uma
// escrita em curso usaria um handle já liberado.
import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

/// Escreve um relatório e devolve quantos bytes foram escritos (< 0 = falha).
/// Roda dentro do isolate de escrita.
typedef EscreverRelatorio = int Function(Uint8List relatorio);

class FilaEscritaIsolada {
  FilaEscritaIsolada._(this._pedidos, this._saiu);

  final SendPort _pedidos;
  final Completer<void> _saiu;
  final _pendentes = <int, Completer<int>>{};
  var _proximo = 0;
  var _encerrando = false;

  /// [criar] roda dentro do isolate novo e monta a escrita (carrega a
  /// biblioteca, guarda o dispositivo): só o que ele captura atravessa.
  static Future<FilaEscritaIsolada> iniciar(EscreverRelatorio Function() criar) async {
    final respostas = ReceivePort();
    final saiu = Completer<void>();
    final pronto = Completer<SendPort>();
    FilaEscritaIsolada? fila;
    respostas.listen((mensagem) {
      if (mensagem case final SendPort pedidos) return pronto.complete(pedidos);
      if (mensagem case (final int id, final int escritos)) return fila?._concluir(id, escritos);
      // saída do isolate (onExit): antes de ficar pronto, foi o `criar` que falhou
      if (!pronto.isCompleted) pronto.completeError(StateError('O isolate de escrita USB não começou.'));
      fila?._aoSair();
      respostas.close();
    });
    await Isolate.spawn(_escreverEmLaco, (respostas.sendPort, criar), onExit: respostas.sendPort, errorsAreFatal: true);
    return fila = FilaEscritaIsolada._(await pronto.future, saiu);
  }

  /// Entra na fila; conclui com o retorno da escrita, depois de escrito.
  Future<int> escrever(Uint8List relatorio) {
    if (_encerrando) throw StateError('A fila de escrita USB já foi encerrada.');
    final id = _proximo++;
    final concluida = _pendentes[id] = Completer<int>();
    _pedidos.send((id, relatorio));
    return concluida.future;
  }

  /// Termina as escritas que já estão na fila e encerra o isolate.
  Future<void> encerrar() {
    if (!_encerrando) {
      _encerrando = true;
      _pedidos.send(null);
    }
    return _saiu.future;
  }

  void _concluir(int id, int escritos) => _pendentes.remove(id)?.complete(escritos);

  /// O isolate saiu (encerrado ou por erro): o que sobrou não foi escrito.
  void _aoSair() {
    _encerrando = true;
    for (final pendente in _pendentes.values) {
      pendente.complete(-1);
    }
    _pendentes.clear();
    if (!_saiu.isCompleted) _saiu.complete();
  }
}

/// Laço do isolate de escrita: um pedido por vez, até chegar `null`.
void _escreverEmLaco((SendPort, EscreverRelatorio Function()) pedido) {
  final (respostas, criar) = pedido;
  final escrever = criar();
  final pedidos = ReceivePort();
  respostas.send(pedidos.sendPort);
  pedidos.listen((mensagem) {
    if (mensagem case (final int id, final Uint8List relatorio)) {
      respostas.send((id, escrever(relatorio)));
    } else {
      pedidos.close();
    }
  });
}
