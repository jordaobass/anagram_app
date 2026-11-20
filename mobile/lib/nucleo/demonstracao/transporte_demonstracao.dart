// Pedaleira simulada em memória. Fala o MESMO protocolo de relatórios que
// o aparelho (recebe quadros fatiados, responde fatiado), então o caminho
// inteiro do cliente é exercitado sem hardware. Serve ao modo demonstração
// e aos testes, que podem injetar as falhas reais conhecidas.
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import '../protocolo/api_anagram.dart';
import '../protocolo/erros_anagram.dart';
import '../protocolo/quadros_hid.dart';
import '../protocolo/transporte_anagram.dart';

class TransporteDemonstracao with FluxosDoTransporte implements TransporteAnagram {
  TransporteDemonstracao({
    Map<int, Map<String, dynamic>> presets = const {},
    this.latencia = const Duration(milliseconds: 4),
    this.firmware = 'v1.18.1.23 (demonstração)',
  }) : _slots = {for (final e in presets.entries) e.key: jsonDecode(jsonEncode(e.value))};

  final Map<int, dynamic> _slots;
  final Duration latencia;
  final String firmware;
  final _montador = MontadorQuadros();
  final _codificador = const CodificadorQuadros();
  bool _aberto = false;

  /// Tudo o que a pedaleira simulada recebeu, em ordem.
  final List<MensagemAnagram> comandosRecebidos = [];

  /// Último documento tocado ao vivo (o que "está soando").
  Map<String, dynamic>? presetTocando;

  /// Falha injetada: ao receber esta ação, o cabo "sai".
  String? desconectarAoReceber;

  /// Falha injetada: um relatório de lixo antes da resposta (sobra de troca anterior
  /// que o cliente precisa ignorar) — mantido falso no uso normal.
  bool enviarSobraAntes = false;

  /// Falha injetada: a pedaleira recebe esta ação e não responde nada.
  String? naoResponder;

  /// Falha injetada: o envio de relatórios falha (sem o cabo "sair").
  bool falharEnvio = false;

  /// Falha injetada: antes da resposta certa chega um quadro completo de OUTRA
  /// ação (resposta atrasada de uma chamada anterior que estourou o prazo).
  bool enviarRespostaAtrasadaAntes = false;

  /// Para os testes: alguém ainda espera resposta?
  bool get temOuvintesDeResposta => temOuvintesDeRelatorio;

  @override
  Duration get pausaSugerida => Duration.zero;

  @override
  String get descricao => 'Demonstração';

  @override
  bool get aberto => _aberto;

  /// Para os testes: outro programa mudou o slot por fora.
  void substituirSlot(int numero, Map<String, dynamic> conteudo) => _slots[numero] = jsonDecode(jsonEncode(conteudo));

  Map<String, dynamic>? conteudoDoSlot(int numero) => _slots[numero] as Map<String, dynamic>?;

  @override
  Future<void> abrir() async {
    _aberto = true;
    anunciarEstado(EstadoTransporte.aberto);
  }

  @override
  Future<void> fechar() async {
    _aberto = false;
    anunciarEstado(EstadoTransporte.fechado);
  }

  /// Simula o cabo arrancado.
  void desconectar() {
    _aberto = false;
    anunciarEstado(EstadoTransporte.perdido);
  }

  @override
  Future<void> enviarRelatorio(Uint8List relatorio) async {
    if (!_aberto) throw const ErroDesconectado('Pedaleira de demonstração desligada.');
    if (falharEnvio) throw const ErroDesconectado('Falha de escrita simulada.');
    final quadro = _montador.acrescentar(relatorio);
    if (quadro == null) return;
    final mensagem = MensagemAnagram(
      quadro['action'] as String? ?? '',
      (quadro['payload'] as Map<String, dynamic>?) ?? const {},
    );
    comandosRecebidos.add(mensagem);
    if (mensagem.acao == desconectarAoReceber) {
      desconectar();
      return;
    }
    if (mensagem.acao == naoResponder) return;
    unawaited(_responder(mensagem));
  }

  Future<void> _responder(MensagemAnagram mensagem) async {
    await Future<void>.delayed(latencia);
    if (!_aberto) return;
    if (enviarSobraAntes) entregarRelatorio(_codificador.fatiar(utf8.encode('{"lixo":1}DEND')).first);
    if (enviarRespostaAtrasadaAntes) {
      _emitir({'action': AcoesAnagram.posicoes, 'payload': {'data': {'files': <dynamic>[]}}});
    }
    _emitir({'action': mensagem.acao, 'payload': _processar(mensagem)});
  }

  void _emitir(Map<String, dynamic> quadro) {
    final texto = ProtocoloAnagram.marcadorInicio + jsonEncode(quadro) + ProtocoloAnagram.marcadorFim;
    for (final relatorio in _codificador.fatiar(utf8.encode(texto))) {
      entregarRelatorio(relatorio);
    }
  }

  Map<String, dynamic> _processar(MensagemAnagram m) => switch (m.acao) {
        AcoesAnagram.firmware => {'data': {'version': firmware}},
        AcoesAnagram.posicoes => {'data': {'files': _posicoes()}},
        AcoesAnagram.lerPreset => _lerPreset(m.carga['filename'] as String?),
        AcoesAnagram.salvar => _salvar(m.carga['presets']),
        AcoesAnagram.excluir => _excluir(m.carga['filename'] as String?),
        AcoesAnagram.tocarAoVivo => _tocar(m.carga['presetData']),
        AcoesAnagram.infoBloco => {'data': {'name': '${m.carga['uri']}'.split(':').last}},
        _ => {'error': 'Ação desconhecida: ${m.acao}'},
      };

  List<Map<String, dynamic>> _posicoes() {
    final numeros = _slots.keys.toList()..sort();
    return [
      for (final n in numeros)
        {
          'filename': '$n.json',
          'id': (_slots[n]['preset'] as Map<String, dynamic>)['uuid'] ?? '',
          'name': (_slots[n]['preset'] as Map<String, dynamic>)['name'] ?? '',
        },
    ];
  }

  Map<String, dynamic> _lerPreset(String? arquivo) {
    final conteudo = _slots[_numero(arquivo)];
    return {
      'data': {'presetFile': conteudo == null ? <String, dynamic>{} : {'content': conteudo}},
    };
  }

  Map<String, dynamic> _salvar(Object? presets) {
    for (final item in (presets as List<dynamic>? ?? const [])) {
      final mapa = item as Map<String, dynamic>;
      _slots[_numero(mapa['name'] as String?)] = jsonDecode(jsonEncode(mapa['content']));
    }
    return {'status': 'ok'};
  }

  Map<String, dynamic> _excluir(String? arquivo) {
    _slots.remove(_numero(arquivo));
    return {'status': 'ok'};
  }

  Map<String, dynamic> _tocar(Object? documento) {
    presetTocando = documento as Map<String, dynamic>?;
    return {'status': 'ok'};
  }

  static int _numero(String? arquivo) => int.tryParse('$arquivo'.split('.').first) ?? -1;
}
