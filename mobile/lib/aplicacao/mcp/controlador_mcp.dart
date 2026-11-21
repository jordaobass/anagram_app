// Liga e desliga o servidor MCP conforme a escolha da tela Configurações, e
// diz em que pé ele está (escutando, porta ocupada). A escolha fica guardada:
// ligado uma vez, ele volta a escutar quando o app abre.
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dados/preferencias_mcp.dart';
import '../../nucleo/mcp/ferramenta_mcp.dart';
import '../../nucleo/mcp/protocolo_mcp.dart';
import '../../plataforma/servidor_mcp.dart';
import '../versao_app.dart';
import 'ferramenta_salvar.dart';
import 'ferramentas_ajuste.dart';
import 'ferramentas_ajustes_globais.dart';
import 'ferramentas_cadeia.dart';
import 'ferramentas_leitura.dart';
import 'sessao_mcp.dart';

sealed class SituacaoMcp {
  const SituacaoMcp();
}

final class McpDesligado extends SituacaoMcp {
  const McpDesligado();
}

final class McpIniciando extends SituacaoMcp {
  const McpIniciando();
}

final class McpEscutando extends SituacaoMcp {
  const McpEscutando(this.porta);
  final int porta;

  String get endereco => 'http://127.0.0.1:$porta/mcp';
}

final class McpPortaOcupada extends SituacaoMcp {
  const McpPortaOcupada(this.porta);
  final int porta;
}

class EstadoMcp {
  const EstadoMcp({this.configuracao = const ConfiguracaoMcp(), this.situacao = const McpDesligado()});

  final ConfiguracaoMcp configuracao;
  final SituacaoMcp situacao;

  EstadoMcp copiar({ConfiguracaoMcp? configuracao, SituacaoMcp? situacao}) =>
      EstadoMcp(configuracao: configuracao ?? this.configuracao, situacao: situacao ?? this.situacao);
}

final preferenciasMcpProvider = Provider<PreferenciasMcp>((ref) => PreferenciasMcpLocais());

/// Desktop sim, celular e web não (os testes fixam).
final mcpDisponivelProvider = Provider<bool>((ref) => mcpDisponivel);

final servidorMcpProvider = Provider<ServidorMcp>((ref) => criarServidorMcp());

final controladorMcpProvider = NotifierProvider<ControladorMcp, EstadoMcp>(ControladorMcp.new);

/// Porta que não é de sistema (abaixo de 1024 pede administrador).
String? motivoPortaInvalida(String texto) {
  final porta = int.tryParse(texto.trim());
  if (porta == null || porta < 1024 || porta > 65535) return 'faixa';
  return null;
}

class ControladorMcp extends Notifier<EstadoMcp> {
  late final SessaoMcp _sessao = SessaoMcp(ref);

  /// A configuração salva; toda mudança espera por ela, senão a leitura que
  /// chega depois apagaria a escolha que a pessoa acabou de fazer.
  late Future<void> _carregamento;

  @override
  EstadoMcp build() {
    final servidor = ref.read(servidorMcpProvider);
    ref.onDispose(() => unawaited(servidor.parar()));
    _carregamento = ref.read(mcpDisponivelProvider) ? _carregar() : Future.value();
    return const EstadoMcp();
  }

  Future<void> _carregar() async {
    final salvo = await ref.read(preferenciasMcpProvider).ler();
    state = state.copiar(configuracao: salvo);
    if (salvo.ativo) await _iniciar();
  }

  Future<void> ativar(bool ligado) async {
    await _carregamento;
    if (!ref.read(mcpDisponivelProvider)) return;
    final token = state.configuracao.token ?? novoTokenMcp();
    await _guardar(state.configuracao.copiar(ativo: ligado, token: token));
    ligado ? await _iniciar() : await _parar();
  }

  /// Porta nova; já validada pela tela ([motivoPortaInvalida]).
  Future<void> definirPorta(int porta) async {
    await _carregamento;
    await _guardar(state.configuracao.copiar(porta: porta));
    if (state.configuracao.ativo) await _iniciar();
  }

  /// Token novo: o antigo para de valer na hora (os clientes precisam do novo).
  Future<void> gerarNovoToken() async {
    await _carregamento;
    await _guardar(state.configuracao.copiar(token: novoTokenMcp()));
    if (state.configuracao.ativo) await _iniciar();
  }

  Future<void> _guardar(ConfiguracaoMcp configuracao) async {
    state = state.copiar(configuracao: configuracao);
    await ref.read(preferenciasMcpProvider).gravar(configuracao);
  }

  Future<void> _iniciar() async {
    final configuracao = state.configuracao;
    state = state.copiar(situacao: const McpIniciando());
    try {
      final protocolo = _protocolo(await ref.read(versaoAppProvider.future));
      final porta = await ref
          .read(servidorMcpProvider)
          .iniciar(porta: configuracao.porta, token: configuracao.token!, protocolo: protocolo);
      state = state.copiar(situacao: McpEscutando(porta));
    } on ErroPortaOcupada catch (erro) {
      state = state.copiar(situacao: McpPortaOcupada(erro.porta));
    }
  }

  Future<void> _parar() async {
    await ref.read(servidorMcpProvider).parar();
    state = state.copiar(situacao: const McpDesligado());
  }

  ProtocoloMcp _protocolo(String versaoApp) => ProtocoloMcp(ferramentasDoTimbre(_sessao, ref), versaoApp: versaoApp);
}

List<FerramentaMcp> ferramentasDoTimbre(SessaoMcp sessao, Ref ref) => [
      LerPresetAtual(sessao),
      ListarTiposDeBloco(sessao),
      MudarParametro(sessao),
      LigarDesligarBloco(sessao),
      EscolherCena(sessao),
      AdicionarBloco(sessao),
      MoverBloco(sessao),
      RemoverBloco(sessao),
      EscolherGabinete(sessao),
      Desfazer(sessao),
      SalvarPreset(sessao, ref),
      LerAjustesGlobais(ref),
      MudarAjusteGlobal(ref),
    ];

/// 32 bytes aleatórios do gerador seguro, em base64 de URL (sem "=").
String novoTokenMcp([Random? aleatorio]) {
  final gerador = aleatorio ?? Random.secure();
  return base64Url.encode(List.generate(32, (_) => gerador.nextInt(256))).replaceAll('=', '');
}
