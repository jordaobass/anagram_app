// Abre e fecha a conversa com a pedaleira (real ou de demonstração) e
// avisa quando o cabo sai. A tentativa automática ao abrir o app (DECISOES
// CA2) é a mesma conversa, mas não achar a pedaleira não vira erro na tela.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dados/repositorio_pedaleira.dart';
import '../../nucleo/demonstracao/areas_demonstracao.dart';
import '../../nucleo/demonstracao/transporte_demonstracao.dart';
import '../../nucleo/midi/saida_midi.dart';
import '../../nucleo/protocolo/api_anagram.dart';
import '../../nucleo/protocolo/cliente_anagram.dart';
import '../../nucleo/protocolo/erros_anagram.dart';
import '../../nucleo/protocolo/transporte_anagram.dart';
import '../../nucleo/registro.dart';
import '../../nucleo/resultado.dart';
import '../../plataforma/fabrica_transporte.dart';
import '../avisos.dart';
import '../provedores.dart';
import 'estado_conexao.dart';

final conexaoProvider = NotifierProvider<ControladorConexao, EstadoConexao>(ControladorConexao.new);

class ControladorConexao extends Notifier<EstadoConexao> {
  RepositorioPedaleira? _repositorio;
  ClienteAnagram? _cliente;
  int _tentativa = 0;

  /// A tentativa em curso é a do app abrindo, não um clique.
  bool _automatica = false;
  TransporteAnagram? _transporte;
  StreamSubscription<EstadoTransporte>? _vigia;

  /// MIDI da pedaleira, quando há (Program Change para trocar de slot).
  SaidaMidiAnagram? get midi => _midi;
  SaidaMidiAnagram? _midi;

  /// Só existe enquanto conectado.
  RepositorioPedaleira? get repositorio => _repositorio;

  /// Transporte em uso (os testes inspecionam a pedaleira simulada).
  TransporteAnagram? get transporte => _transporte;

  @override
  EstadoConexao build() {
    ref.onDispose(() => unawaited(_soltar()));
    return const SemConexao();
  }

  Future<void> conectarDemonstracao() async {
    final Map<int, Map<String, dynamic>> presets;
    try {
      presets = await ref.read(presetsDemonstracaoProvider.future);
    } on Object catch (erro, pilha) {
      registro.e('conexão: presets da demonstração não carregaram', error: erro, stackTrace: pilha);
      state = const FalhaDeConexao(AvisoDemonstracaoFalhou());
      return;
    }
    final midi = ref.read(midiDemonstracaoProvider)();
    // como uma Anagram com firmware 1.18+: três áreas de presets
    final pedaleira = TransporteDemonstracao(
      presets: presets,
      outrasAreas: AreasDemonstracao.outras(presets),
      nomesAreas: AreasDemonstracao.nomes,
    );
    ref.read(ajusteDemonstracaoProvider)(pedaleira);
    await _conectar(pedaleira, demonstracao: true, midi: midi);
  }

  Future<void> conectarAparelho() => _conectarAparelho(automatica: false);

  /// Uma tentativa só, ao abrir o app; sem pedaleira, a tela fica como estava.
  Future<void> conectarAoAbrir() => _conectarAparelho(automatica: true);

  Future<void> _conectarAparelho({required bool automatica}) async {
    final fabrica = ref.read(fabricaTransporteProvider);
    if (fabrica.suporte case AparelhoIndisponivel(:final motivo)) {
      if (!automatica) state = FalhaDeConexao(AvisoPlataformaIndisponivel(motivo));
      return;
    }
    await _conectar(fabrica.criarAparelho(), demonstracao: false, midi: fabrica.criarMidi(), automatica: automatica);
  }

  /// Desiste da tentativa em curso; o que ela terminar depois é ignorado.
  Future<void> cancelarConexao() async {
    _tentativa++;
    await _soltar();
    state = const SemConexao();
  }

  Future<void> desconectar() async {
    await _soltar();
    state = const SemConexao();
  }

  Future<void> _conectar(TransporteAnagram transporte,
      {required bool demonstracao, SaidaMidiAnagram? midi, bool automatica = false}) async {
    await _soltar();
    final tentativa = ++_tentativa;
    _automatica = automatica;
    state = Conectando(transporte.descricao, demonstracao: demonstracao, automatica: automatica);
    if (!await _abrirTransporte(transporte, tentativa)) return;
    if (tentativa != _tentativa) return unawaited(_fecharSemFalhar(transporte.descricao, transporte.fechar));
    final cliente = ClienteAnagram(
      transporte,
      pausaEntreRelatorios: () => ref.read(pausaRelatoriosProvider) ?? transporte.pausaSugerida,
      cronometro: ref.read(cronometroProvider),
    );
    _transporte = transporte;
    _cliente = cliente;
    _repositorio = RepositorioPedaleira(ApiAnagram(cliente));
    await _abrirMidi(midi, tentativa);
    // cancelaram enquanto o MIDI abria: _soltar já fechou tudo
    if (tentativa != _tentativa) return;
    _vigia = transporte.estados.listen(_aoMudarTransporte);
    await _confirmarFirmware(transporte.descricao, demonstracao, tentativa);
  }

  /// Abre o transporte; se falhar, a tela mostra a falha e devolve falso.
  Future<bool> _abrirTransporte(TransporteAnagram transporte, int tentativa) async {
    try {
      await transporte.abrir();
      return true;
    } on ErroAnagram catch (erro) {
      if (tentativa == _tentativa) _falhar(AvisoConexao(erro), 'não abriu ${transporte.descricao}', erro);
    } on Object catch (erro, pilha) {
      // erro fora do protocolo (DOMException do WebHID bloqueado por política,
      // falha ao criar o isolate do hidapi): sem isto a tela ficaria em
      // "Conectando…" para sempre
      if (tentativa == _tentativa) {
        _falhar(AvisoFalhaInesperada(transporte.descricao), 'falha inesperada ao abrir ${transporte.descricao}', erro,
            pilha);
      }
    }
    return false;
  }

  /// Clique: a tela mostra a falha. Ao abrir o app: não achar a pedaleira não
  /// é erro, a tela fica como estava e o motivo vai só para o registro.
  void _falhar(Aviso aviso, String oQue, Object erro, [StackTrace? pilha]) {
    if (!_automatica) {
      registro.e('conexão: $oQue', error: erro, stackTrace: pilha);
      state = FalhaDeConexao(aviso);
      return;
    }
    registro.i('conexão ao abrir: pedaleira não encontrada ($oQue: $erro); espera o clique');
    state = const SemConexao();
  }

  /// Aperto de mão curto (3 s): quem espera na tela pode desistir antes.
  Future<void> _confirmarFirmware(String meio, bool demonstracao, int tentativa) async {
    final firmware = await _repositorio!.firmware(prazo: const Duration(seconds: 3), falhaEsperada: _automatica);
    if (tentativa != _tentativa) return;
    switch (firmware) {
      case Sucesso(:final valor):
        state = Conectada(meio: meio, firmware: valor, demonstracao: demonstracao);
      case Falha(:final erro):
        _falhar(AvisoConexao(erro), 'aperto de mão por $meio falhou', erro);
        await _soltar();
    }
  }

  void _aoMudarTransporte(EstadoTransporte estado) {
    if (estado != EstadoTransporte.perdido) return;
    registro.w('conexão: pedaleira desconectada');
    unawaited(_soltar());
    state = const SemConexao(aviso: AvisoPedaleiraDesconectada());
  }

  Future<void> _soltar() async {
    // não espera o cancelamento: com uma chamada pendente ele só termina no
    // prazo dela, e o Cancelar da tela ficaria congelado
    unawaited(_vigia?.cancel());
    _vigia = null;
    final transporte = _transporte;
    final cliente = _cliente;
    final midi = _midi;
    _transporte = null;
    _cliente = null;
    _repositorio = null;
    _midi = null;
    if (transporte != null && transporte.aberto) await _fecharSemFalhar(transporte.descricao, transporte.fechar);
    // depois do transporte: com ele fechado, nenhuma resposta nova gera medição
    if (cliente != null) unawaited(cliente.encerrar());
    if (midi != null && midi.aberta) await _fecharSemFalhar(midi.descricao, midi.fechar);
  }

  /// Fechar é arrumação: uma falha aqui (canal nativo que já sumiu) vai para o
  /// log, mas não pode impedir o Desconectar nem o Cancelar.
  static Future<void> _fecharSemFalhar(String meio, Future<void> Function() fechar) async {
    try {
      await fechar();
    } on Object catch (erro, pilha) {
      registro.w('conexão: $meio não fechou limpo', error: erro, stackTrace: pilha);
    }
  }

  /// MIDI é opcional: sem ele, abrir um preset só faz audição.
  Future<void> _abrirMidi(SaidaMidiAnagram? midi, int tentativa) async {
    if (midi == null) return;
    try {
      await midi.abrir();
      if (tentativa != _tentativa) return unawaited(_fecharSemFalhar(midi.descricao, midi.fechar));
      _midi = midi;
    } on Object catch (erro) {
      // qualquer falha do MIDI (Web MIDI sem permissão, porta que sumiu) só
      // tira a troca de slot; a conexão HID segue
      registro.w('conexão: sem MIDI (${midi.descricao}); abrir preset será só audição', error: erro);
    }
  }
}
