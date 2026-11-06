// Abre e fecha a conversa com a pedaleira (real ou de demonstração) e
// avisa quando o cabo sai.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dados/repositorio_pedaleira.dart';
import '../../nucleo/demonstracao/transporte_demonstracao.dart';
import '../../nucleo/midi/saida_midi.dart';
import '../../nucleo/protocolo/api_anagram.dart';
import '../../nucleo/protocolo/cliente_anagram.dart';
import '../../nucleo/protocolo/erros_anagram.dart';
import '../../nucleo/protocolo/transporte_anagram.dart';
import '../../nucleo/registro.dart';
import '../../nucleo/resultado.dart';
import '../../plataforma/fabrica_transporte.dart';
import '../provedores.dart';
import 'estado_conexao.dart';

final conexaoProvider = NotifierProvider<ControladorConexao, EstadoConexao>(ControladorConexao.new);

class ControladorConexao extends Notifier<EstadoConexao> {
  RepositorioPedaleira? _repositorio;
  ClienteAnagram? _cliente;
  int _tentativa = 0;
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
      state = const FalhaDeConexao('Não foi possível abrir a demonstração.');
      return;
    }
    final midi = ref.read(midiDemonstracaoProvider)();
    final pedaleira = TransporteDemonstracao(presets: presets);
    ref.read(ajusteDemonstracaoProvider)(pedaleira);
    await _conectar(pedaleira, demonstracao: true, midi: midi);
  }

  Future<void> conectarAparelho() async {
    final fabrica = ref.read(fabricaTransporteProvider);
    if (fabrica.suporte case AparelhoIndisponivel(:final motivo)) {
      state = FalhaDeConexao(motivo);
      return;
    }
    await _conectar(fabrica.criarAparelho(), demonstracao: false, midi: fabrica.criarMidi());
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

  Future<void> _conectar(TransporteAnagram transporte, {required bool demonstracao, SaidaMidiAnagram? midi}) async {
    await _soltar();
    final tentativa = ++_tentativa;
    state = Conectando(transporte.descricao);
    try {
      await transporte.abrir();
    } on ErroAnagram catch (erro) {
      registro.e('conexão: não abriu ${transporte.descricao}', error: erro);
      if (tentativa == _tentativa) state = FalhaDeConexao(_explicar(erro));
      return;
    } on Object catch (erro, pilha) {
      // erro fora do protocolo (DOMException do WebHID bloqueado por política,
      // falha ao criar o isolate do hidapi): sem isto a tela ficaria em
      // "Conectando…" para sempre
      registro.e('conexão: falha inesperada ao abrir ${transporte.descricao}', error: erro, stackTrace: pilha);
      if (tentativa == _tentativa) state = FalhaDeConexao('Não foi possível abrir ${transporte.descricao}: $erro');
      return;
    }
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

  /// Aperto de mão curto (3 s): quem espera na tela pode desistir antes.
  Future<void> _confirmarFirmware(String meio, bool demonstracao, int tentativa) async {
    final firmware = await _repositorio!.firmware(prazo: const Duration(seconds: 3));
    if (tentativa != _tentativa) return;
    state = switch (firmware) {
      Sucesso(:final valor) => Conectada(meio: meio, firmware: valor, demonstracao: demonstracao),
      Falha(:final erro) => FalhaDeConexao(_explicar(erro)),
    };
    if (state is FalhaDeConexao) await _soltar();
  }

  void _aoMudarTransporte(EstadoTransporte estado) {
    if (estado != EstadoTransporte.perdido) return;
    registro.w('conexão: pedaleira desconectada');
    unawaited(_soltar());
    state = const SemConexao(aviso: 'A pedaleira foi desconectada. Edições não salvas continuam no app.');
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

  static String _explicar(ErroAnagram erro) => switch (erro) {
        ErroInterfaceOcupada() =>
          'A Anagram está plugada, mas outro programa a segura. Feche o Darkglass Suite '
              'e qualquer aba do navegador conectada à pedaleira.',
        ErroDesconectado() => 'Nenhuma Anagram encontrada no USB. Confira o cabo e se ela está ligada.',
        ErroSemResposta() => 'A Anagram não respondeu. Desligue e ligue o cabo e tente de novo.',
        ErroPlataformaSemSuporte(:final mensagem) => mensagem,
        ErroOperacaoEmCurso(:final mensagem) => mensagem,
        ErroRespostaInvalida(:final mensagem) => 'Resposta inesperada da pedaleira: $mensagem',
      };
}
