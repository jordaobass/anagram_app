// Cliente do protocolo: uma ação por vez, com prazo, medição de latência e
// remontagem da resposta. Fala com qualquer [TransporteAnagram].
import 'dart:async';
import 'dart:typed_data';

import '../registro.dart';
import 'api_anagram.dart' show AcoesAnagram;
import 'erros_anagram.dart';
import 'quadros_hid.dart';
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
    final relatorios = _codificador.codificar(MensagemAnagram(acao, carga));
    final pausa = _pausa();
    final espera = _aguardarResposta(acao, prazo);
    try {
      await _enviarTodos(relatorios, pausa);
    } on Object catch (erro) {
      espera.cancelar();
      throw ErroDesconectado('Falha ao enviar "$acao": $erro');
    }
    final quadro = await espera.resposta;
    relogio.stop();
    _registrarMedicao(MedicaoChamada(acao, relogio.elapsed, relatorios.length, pausa));
    return _extrairCarga(acao, quadro);
  }

  Future<void> _enviarTodos(List<Uint8List> relatorios, Duration pausa) async {
    for (final relatorio in relatorios) {
      await _transporte.enviarRelatorio(relatorio);
      if (pausa > Duration.zero) await Future<void>.delayed(pausa);
    }
  }

  _Espera _aguardarResposta(String acao, Duration prazo) {
    final montador = MontadorQuadros();
    final concluido = Completer<Map<String, dynamic>>();
    final assinaturaDados = _transporte.relatoriosRecebidos.listen((relatorio) {
      if (concluido.isCompleted) return;
      try {
        // um relatório pode fechar a resposta atrasada de outra ação e já trazer esta
        for (var quadro = montador.acrescentar(relatorio); quadro != null; quadro = montador.proximoQuadro()) {
          if (!_ehRespostaDe(acao, quadro)) continue;
          concluido.complete(quadro);
          return;
        }
      } on QuadroMalformado catch (erro) {
        concluido.completeError(ErroRespostaInvalida('$erro'));
      }
    });
    final assinaturaEstado = _transporte.estados.listen((estado) {
      if (estado == EstadoTransporte.perdido && !concluido.isCompleted) {
        concluido.completeError(ErroDesconectado('A pedaleira foi desconectada durante "$acao".'));
      }
    });
    void encerrar() {
      unawaited(assinaturaDados.cancel());
      unawaited(assinaturaEstado.cancel());
    }

    final resposta = concluido.future
        .timeout(prazo, onTimeout: () => throw ErroSemResposta(acao, prazo))
        .whenComplete(encerrar);
    // o erro de "cabo saiu" pode chegar enquanto ainda enviamos: já fica tratado
    resposta.ignore();
    return _Espera(resposta, encerrar);
  }

  /// Resposta atrasada de OUTRA ação conhecida (de uma chamada que estourou o
  /// prazo) é descartada. Nome de ação desconhecido ou ausente é aceito: o
  /// formato exato do eco do firmware não está documentado.
  static bool _ehRespostaDe(String acao, Map<String, dynamic> quadro) {
    final ecoada = quadro['action'];
    final descartar = ecoada is String && ecoada != acao && AcoesAnagram.todas.contains(ecoada);
    if (descartar) registro.w('anagram: descartada resposta atrasada de "$ecoada" enquanto esperava "$acao"');
    return !descartar;
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
    final erro = carga['error'] ?? (carga['status'] == 'error' ? carga['message'] : null);
    if (erro != null) {
      throw ErroRespostaInvalida('A pedaleira recusou "$acao": $erro');
    }
    return carga;
  }

  /// Fecha o fluxo de medições quando a conexão acaba. Pode ser chamado mais
  /// de uma vez, e chamadas ainda pendentes terminam sem medir.
  Future<void> encerrar() => _medicoes.close();
}

class _Espera {
  const _Espera(this.resposta, this.cancelar);
  final Future<Map<String, dynamic>> resposta;
  final void Function() cancelar;
}
