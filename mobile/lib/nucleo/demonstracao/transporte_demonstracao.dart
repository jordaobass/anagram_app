// Pedaleira simulada em memória. Fala o MESMO protocolo de relatórios que
// o aparelho (recebe quadros fatiados, responde fatiado), então o caminho
// inteiro do cliente é exercitado sem hardware. Serve ao modo demonstração
// e aos testes, que podem injetar as falhas reais conhecidas. Com
// [outrasAreas], simula o firmware 1.18+ com várias áreas de presets; sem,
// responde como o firmware de uma área só.
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import '../protocolo/api_anagram.dart';
import '../protocolo/erros_anagram.dart';
import '../protocolo/quadros_hid.dart';
import '../protocolo/transporte_anagram.dart';
import 'ajustes_globais_demonstracao.dart';
import 'organizacao_demonstracao.dart';
import 'plugins_demonstracao.dart';
import 'slots_demonstracao.dart';
import 'tons_demonstracao.dart';

class TransporteDemonstracao with FluxosDoTransporte implements TransporteAnagram {
  TransporteDemonstracao({
    Map<int, Map<String, dynamic>> presets = const {},
    Map<String, Map<int, Map<String, dynamic>>> outrasAreas = const {},
    List<String>? nomesAreas,
    this.latencia = const Duration(milliseconds: 4),
    this.firmware = 'v1.18.1.23 (demonstração)',
  })  : _slots = copiaDosSlots(presets),
        _nomesAreas = nomesAreas {
    _areas['user'] = _slots;
    for (final e in outrasAreas.entries) {
      _areas[e.key] = copiaDosSlots(e.value);
    }
  }

  final Map<int, dynamic> _slots;
  final Map<String, Map<int, dynamic>> _areas = {};
  final List<String>? _nomesAreas;

  /// Área que a pedaleira simulada está usando (a do Program Change).
  String areaAtiva = 'user';

  /// Mixer, Global EQ e entrada, no formato plano da pedaleira real.
  final Map<String, Object?> ajustesGlobais = ajustesGlobaisIniciais();
  final Map<String, Object?> placaDeSom = placaDeSomInicial();

  /// Falha injetada: firmware anterior aos ajustes, que recusa `export_settings`.
  bool semAjustes = false;

  /// Falhas injetadas das áreas: o firmware responde "ok" ao `edit_settings`
  /// sem trocar de área, ou não informa qual área está ativa.
  bool ignorarTrocaDeArea = false;
  bool semAreaAtiva = false;

  /// Falha injetada: firmware sem a capacidade `t3k` (recusa as ações dos tons).
  bool semTone3000 = false;

  /// Falha injetada: firmware sem `plugin-management` (anterior ao 1.14),
  /// que recusa `read_all_plugins`.
  bool semListaDePlugins = false;
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

  /// Falha injetada: a gravação é confirmada e a releitura ainda traz o antigo.
  final gravacaoAtrasada = GravacaoAtrasada();

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

  Map<String, dynamic>? conteudoDoSlot(int numero, {String area = 'user'}) =>
      _areas[area]?[numero] as Map<String, dynamic>?;

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
        AcoesAnagram.posicoes => {'data': {'files': posicoesDosSlots(_daArea(m))}},
        AcoesAnagram.lerPreset => lerSlot(gravacaoAtrasada.paraLer(_daArea(m)), m.carga['filename'] as String?),
        AcoesAnagram.salvar => gravarSlots(gravacaoAtrasada.antesDeGravar(_daArea(m)), m.carga['presets']),
        AcoesAnagram.excluir => excluirSlot(_daArea(m), m.carga['filename'] as String?),
        AcoesAnagram.lerAjustes => _ajustes(),
        AcoesAnagram.gravarAjustes => _gravarAjustes(m.carga['settings']),
        AcoesAnagram.tocarAoVivo => _tocar(m.carga['presetData']),
        AcoesAnagram.trocarPresets => trocarSlots(_daArea(m), m.carga['fromIndex'], m.carga['toIndex']),
        AcoesAnagram.trocarBancos => trocarBancosDeSlots(_daArea(m), m.carga['positions']),
        AcoesAnagram.infoBloco => infoDePluginDemonstracao('${m.carga['uri']}'),
        AcoesAnagram.plugins when !semListaDePlugins => listaDePluginsDemonstracao(),
        AcoesAnagram.tonsDeFabrica when !semTone3000 => {'success': 1, 'data': {'tones': tonsDeFabricaDemonstracao}},
        AcoesAnagram.tonsDoUsuario when !semTone3000 => paginaDeTonsDemonstracao(m.carga['page'], m.carga['itemsPerPage']),
        _ => {'error': 'Ação desconhecida: ${m.acao}'},
      };

  /// Os slots da área pedida; sem `userArea` (firmware antigo), a primeira.
  /// Área que não existe responde vazia, como uma área recém-criada.
  Map<int, dynamic> _daArea(MensagemAnagram m) => _areas.putIfAbsent('${m.carga['userArea'] ?? 'user'}', () => {});

  Map<String, dynamic> _ajustes() {
    if (semAjustes) return {'error': 'Ação desconhecida: ${AcoesAnagram.lerAjustes}'};
    final nomes = _nomesAreas;
    return {
      'settings': {
        ...ajustesGlobais,
        'user-areas': ?nomes,
        if (!semAreaAtiva) 'selected-preset-area': areaAtiva,
        'selected-preset': 0,
      },
      'soundcard': {...placaDeSom},
      'success': 1,
    };
  }

  Map<String, dynamic> _gravarAjustes(Object? ajustes) {
    if (ajustes is! Map<String, dynamic>) return {'success': 1};
    final area = ajustes['selected-preset-area'];
    if (area is String && !ignorarTrocaDeArea) areaAtiva = area;
    gravarAjustesGlobais(ajustesGlobais, ajustes);
    return {'success': 1, 'err_message': ''};
  }

  Map<String, dynamic> _tocar(Object? documento) {
    presetTocando = documento as Map<String, dynamic>?;
    return {'status': 'ok'};
  }
}
