// Cliente do protocolo: uma ação por vez, com prazo, medição de latência e
// remontagem da resposta. Fala com qualquer [TransporteAnagram].
import 'dart:async';
import 'dart:typed_data';

import '../registro.dart';
import 'erros_anagram.dart';
import 'quadros_hid.dart';
import 'respostas_anagram.dart';
import 'transporte_anagram.dart';

/// Ida e volta de uma ação, para o log e para a tela.
class MedicaoChamada {
  const MedicaoChamada(this.acao, this.duracao, this.relatoriosEnviados, [this.pausa = Duration.zero]);
  final String acao;
  final Duration pausa;
  final Duration duracao;
  final int relatoriosEnviados;
}

class ClienteAnagram {
  ClienteAnagram(
    this._transporte, {
    this.prazoPadrao = const Duration(seconds: 20),
    Duration Function()? pausaEntreRelatorios,
    Stopwatch Function()? cronometro,
  })  : _pausaEscolhida = pausaEntreRelatorios,
        _cronometro = cronometro ?? Stopwatch.new;

  final TransporteAnagram _transporte;
  final Duration prazoPadrao;
  /// Lida a cada chamada: dá para comparar 0/2/10 ms sem reconectar.
  final Duration Function()? _pausaEscolhida;

  Duration _pausa() => _pausaEscolhida?.call() ?? _transporte.pausaSugerida;
  final Stopwatch Function() _cronometro;
  final _codificador = const CodificadorQuadros();
  final _medicoes = StreamController<MedicaoChamada>.broadcast();
  Future<void> _fila = Future.value();

  /// Leituras que estouraram o prazo e ainda podem responder (RN10).
  final _atrasadas = RespostasAtrasadas();

  TransporteAnagram get transporte => _transporte;
  Stream<MedicaoChamada> get medicoes => _medicoes.stream;

  /// Envia uma ação e devolve o `payload` da resposta. As chamadas entram
  /// numa fila: o aparelho só entende uma conversa por vez.
  Future<Map<String, dynamic>> chamar(
    String acao, [
    Map<String, dynamic> carga = const {},
    Duration? prazo,
  ]) {
    final resultado = _fila.then((_) => _executar(acao, carga, prazo ?? prazoPadrao));
    _fila = resultado.then((_) {}, onError: (_) {});
    return resultado;
  }

  Future<Map<String, dynamic>> _executar(
    String acao,
    Map<String, dynamic> carga,
    Duration prazo,
  ) async {
    if (!_transporte.aberto) {
      throw const ErroDesconectado('A pedaleira não está conectada.');
    }
    final relogio = _cronometro()..start();
    final pedido = MensagemAnagram(acao, carga);
    final relatorios = _codificar(pedido);
    final pausa = _pausa();
    final espera = _aguardarResposta(pedido, prazo);
    await _enviar(acao, relatorios, pausa, prazo, espera);
    final quadro = await _respostaAnotandoAtraso(acao, espera.resposta);
    relogio.stop();
    _registrarMedicao(MedicaoChamada(acao, relogio.elapsed, relatorios.length, pausa));
    return _extrairCarga(acao, quadro);
  }

  /// Se o prazo estourar, a resposta ainda pode chegar no meio da próxima conversa.
  Future<Map<String, dynamic>> _respostaAnotandoAtraso(String acao, Future<Map<String, dynamic>> resposta) async {
    try {
      return await resposta;
    } on ErroSemResposta {
      _atrasadas.anotar(acao);
      rethrow;
    }
  }

  List<Uint8List> _codificar(MensagemAnagram pedido) {
    try {
      return _codificador.codificar(pedido);
    } on MensagemComMarcador catch (erro) {
      registro.e('anagram: ${pedido.acao} não enviado', error: erro);
      throw ErroRespostaInvalida('$erro');
    }
  }

  /// O envio também tem prazo: um relatório que nunca volta (USB travado)
  /// prenderia a fila, e nenhuma outra ação seria atendida.
  Future<void> _enviar(String acao, List<Uint8List> relatorios, Duration pausa, Duration prazo, _Espera espera) async {
    try {
      await _enviarTodos(relatorios, pausa, espera).timeout(prazo, onTimeout: () => throw ErroSemResposta(acao, prazo));
    } on ErroSemResposta {
      espera.cancelar();
      rethrow;
    } on Object catch (erro) {
      espera.cancelar();
      throw ErroDesconectado('Falha ao enviar "$acao": $erro');
    }
  }

  /// Para no meio se a espera foi cancelada: o resto de um pedido que estourou
  /// o prazo não pode cair no meio do pedido seguinte.
  Future<void> _enviarTodos(List<Uint8List> relatorios, Duration pausa, _Espera espera) async {
    for (final relatorio in relatorios) {
      if (espera.cancelada) return;
      await _transporte.enviarRelatorio(relatorio);
      if (pausa > Duration.zero) await Future<void>.delayed(pausa);
    }
  }

  _Espera _aguardarResposta(MensagemAnagram pedido, Duration prazo) {
    final concluido = Completer<Map<String, dynamic>>();
    final assinaturaDados = _transporte.relatoriosRecebidos.listen(_receptor(pedido, concluido, _atrasadas));
    final assinaturaEstado = _transporte.estados.listen((estado) {
      if (estado == EstadoTransporte.perdido && !concluido.isCompleted) {
        concluido.completeError(ErroDesconectado('A pedaleira foi desconectada durante "${pedido.acao}".'));
      }
    });
    void encerrar() {
      unawaited(assinaturaDados.cancel());
      unawaited(assinaturaEstado.cancel());
    }

    final resposta = concluido.future
        .timeout(prazo, onTimeout: () => throw ErroSemResposta(pedido.acao, prazo))
        .whenComplete(encerrar);
    // o erro de "cabo saiu" pode chegar enquanto ainda enviamos: já fica tratado
    resposta.ignore();
    return _Espera(resposta, encerrar);
  }

  /// Remonta os relatórios e completa com o primeiro quadro que responde a
  /// [pedido]; os de outra conversa (respostas atrasadas) são pulados.
  static void Function(Uint8List) _receptor(
      MensagemAnagram pedido, Completer<Map<String, dynamic>> concluido, RespostasAtrasadas atrasadas) {
    final montador = MontadorQuadros();
    return (relatorio) {
      if (concluido.isCompleted) return;
      try {
        // um relatório pode fechar a resposta atrasada de outra ação e já trazer esta
        for (var quadro = montador.acrescentar(relatorio); quadro != null; quadro = montador.proximoQuadro()) {
          if (!ehRespostaDe(pedido, quadro, atrasadas)) continue;
          concluido.complete(quadro);
          return;
        }
      } on QuadroMalformado catch (erro) {
        concluido.completeError(ErroRespostaInvalida('$erro'));
      }
    };
  }

  void _registrarMedicao(MedicaoChamada medicao) {
    registro.i(
      'anagram ${medicao.acao}: ida e volta ${medicao.duracao.inMilliseconds} ms '
      '(${medicao.relatoriosEnviados} relatórios, pausa ${medicao.pausa.inMilliseconds} ms)',
    );
    // uma chamada que termina depois do encerrar (cabo saiu, Desconectar) não pode estourar aqui
    if (!_medicoes.isClosed) _medicoes.add(medicao);
  }

  Map<String, dynamic> _extrairCarga(String acao, Map<String, dynamic> quadro) {
    final carga = quadro['payload'];
    if (carga is! Map<String, dynamic>) return const {};
    final erro = motivoDaRecusa(carga);
    if (erro != null) throw ErroRespostaInvalida('A pedaleira recusou "$acao": $erro');
    return carga;
  }

  /// Fecha o fluxo de medições quando a conexão acaba. Pode ser chamado mais
  /// de uma vez, e chamadas ainda pendentes terminam sem medir.
  Future<void> encerrar() => _medicoes.close();
}

class _Espera {
  _Espera(this.resposta, this._encerrar);
  final Future<Map<String, dynamic>> resposta;
  final void Function() _encerrar;
  bool _cancelada = false;

  bool get cancelada => _cancelada;

  void cancelar() {
    _cancelada = true;
    _encerrar();
  }
}
