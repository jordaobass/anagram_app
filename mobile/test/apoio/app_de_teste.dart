// O app inteiro com assets lidos do disco de forma síncrona: o carregamento
// em isolate do rootBundle (arquivo > 50 KB) não anda no relógio falso.
import 'package:anagram_app/apresentacao/app_anagram.dart';
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/aplicacao/versao_app.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import 'fixtures.dart';
import 'package:anagram_app/aplicacao/arte/indice_miniaturas.dart';
import 'package:anagram_app/aplicacao/idioma.dart';
import 'package:anagram_app/aplicacao/tema.dart';
import 'package:anagram_app/dados/preferencias_tema.dart';
import 'package:anagram_app/aplicacao/mcp/controlador_mcp.dart';
import 'package:anagram_app/dados/preferencias_idioma.dart';
import 'package:anagram_app/dados/preferencias_mcp.dart';
import 'package:anagram_app/dados/preferencias_pausa.dart';
import 'package:anagram_app/dados/preferencias_paineis.dart';
import 'package:anagram_app/aplicacao/estado/paineis_recolhidos.dart';
import 'package:anagram_app/nucleo/mcp/protocolo_mcp.dart';
import 'package:anagram_app/plataforma/servidor_mcp.dart';
import 'package:anagram_app/nucleo/modelo/presets_fabrica.dart';
import 'package:anagram_app/aplicacao/versao_nova.dart';
import 'package:anagram_app/dados/preferencias_versao.dart';
import 'package:anagram_app/aplicacao/conectar_ao_abrir.dart';
import 'package:anagram_app/dados/preferencias_conexao.dart';
import 'package:anagram_app/plataforma/acesso_entrada_mac.dart';
import 'versao_falsa.dart';

/// Latência fixa: a real varia de execução para execução e sujaria as capturas.
class CronometroFixo implements Stopwatch {
  @override
  Duration get elapsed => const Duration(milliseconds: 42);

  @override
  void start() {}

  @override
  void stop() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const versaoNasCapturas = '0.1.3';

/// [indice]: o índice de arte (o padrão é o das capturas, sem a arte de terceiros).
/// [fabrica]: os presets de fábrica (o padrão é nenhum, como no build sem a arte).
/// [github]: a última release roteirizada; sem ele, a verificação de versão
/// nova fica indisponível (como no celular) e nada aparece nas capturas.
/// [abertura]: onde o app procura a pedaleira sozinho ao abrir; o padrão é
/// não procurar (como no celular), para nenhum teste conectar sem pedir.
Widget appDeTeste(
        {List<Override> overrides = const [],
        IdiomaApp? idioma = IdiomaApp.portugues,
        EscolhaTema? tema = EscolhaTema.escuro,
        IndiceMiniaturas? indice,
        PresetsDeFabrica? fabrica,
        ServidorMcp? servidorMcp,
        bool mcpDisponivel = true,
        GithubFalso? github,
        PreferenciasVersao? preferenciasVersao,
        PreferenciasPausa? preferenciasPausa,
        PreferenciasPaineis? preferenciasPaineis,
        PlataformaDeAbertura abertura = PlataformaDeAbertura.semTentativa,
        PreferenciasConexao? preferenciasConexao,
        ConsultaAcessoEntrada? acessoEntradaMac}) =>
    ProviderScope(
      overrides: [
        ...overrides,
        // o MCP nunca abre porta de verdade nos testes de tela (relógio falso)
        servidorMcpProvider.overrideWithValue(servidorMcp ?? ServidorMcpFalso()),
        preferenciasMcpProvider.overrideWithValue(PreferenciasMcpEmMemoria()),
        mcpDisponivelProvider.overrideWithValue(mcpDisponivel),
        // nenhum teste de tela chama a rede de verdade
        consultaHttpProvider.overrideWithValue(github ?? GithubFalso()),
        verificacaoVersaoDisponivelProvider.overrideWithValue(github != null),
        preferenciasVersaoProvider.overrideWithValue(preferenciasVersao ?? PreferenciasVersaoEmMemoria()),
        preferenciasPausaProvider.overrideWithValue(preferenciasPausa ?? PreferenciasPausaEmMemoria()),
        preferenciasPaineisProvider.overrideWithValue(preferenciasPaineis ?? PreferenciasPaineisEmMemoria()),
        plataformaDeAberturaProvider.overrideWithValue(abertura),
        preferenciasConexaoProvider.overrideWithValue(preferenciasConexao ?? PreferenciasConexaoEmMemoria()),
        // nenhum teste chama o canal nativo do Mac
        acessoEntradaMacProvider.overrideWithValue(acessoEntradaMac ?? () async => AcessoEntrada.desconhecido),
        cronometroProvider.overrideWithValue(CronometroFixo.new),
        catalogoProvider.overrideWith((ref) async => lerCatalogo()),
        explicacoesProvider.overrideWith((ref) async => lerExplicacoes()),
        templatesProvider.overrideWith((ref) async => lerTemplates()),
        presetsDemonstracaoProvider.overrideWith((ref) async => lerPresetsDemonstracao()),
        indiceMiniaturasProvider.overrideWith((ref) async => indice ?? lerIndiceMiniaturas()),
        presetsFabricaProvider.overrideWith((ref) async => fabrica ?? const PresetsDeFabrica.vazio()),
        // versão fixa: com a do pubspec, toda release mudaria todas as capturas
        versaoAppProvider.overrideWith((ref) async => versaoNasCapturas),
        // o ambiente de teste é en-US: as capturas de referência são em português
        // (nulo = seguir o idioma do sistema)
        idiomaSalvoProvider.overrideWithValue(idioma),
        // o ambiente de teste é claro: as capturas e os testes de tela são no
        // escuro, a não ser que o teste peça outro tema
        temaSalvoProvider.overrideWithValue(tema),
      ],
      child: const AppAnagram(),
    );

/// Guarda a escolha de tema só em memória (o teste não toca no disco).
class PreferenciasTemaEmMemoria implements PreferenciasTema {
  String? salvo;

  @override
  Future<String?> ler() async => salvo;

  @override
  Future<void> gravar(String codigo) async => salvo = codigo;
}

/// Guarda a escolha de idioma só em memória (o teste não toca no disco).
class PreferenciasIdiomaEmMemoria implements PreferenciasIdioma {
  String? salvo;

  @override
  Future<String?> ler() async => salvo;

  @override
  Future<void> gravar(String? codigo) async => salvo = codigo;
}

/// Guarda o "conectar ao abrir" só em memória (ligado, como na primeira abertura).
class PreferenciasConexaoEmMemoria implements PreferenciasConexao {
  PreferenciasConexaoEmMemoria([this.ligado = true]);

  bool ligado;

  @override
  Future<bool> lerConectarAoAbrir() async => ligado;

  @override
  Future<void> gravarConectarAoAbrir(bool ligado) async => this.ligado = ligado;
}

/// Guarda a pausa USB só em memória (o teste não toca no disco).
class PreferenciasPausaEmMemoria implements PreferenciasPausa {
  int? salvo;

  @override
  Future<int?> ler() async => salvo;

  @override
  Future<void> gravar(int? milissegundos) async => salvo = milissegundos;
}

class PreferenciasPaineisEmMemoria implements PreferenciasPaineis {
  bool? controlesAbertos;

  @override
  Future<bool?> lerControlesAbertos() async => controlesAbertos;

  @override
  Future<void> gravarControlesAbertos(bool abertos) async => controlesAbertos = abertos;
}

class PreferenciasMcpEmMemoria implements PreferenciasMcp {
  ConfiguracaoMcp salvo = const ConfiguracaoMcp();

  @override
  Future<ConfiguracaoMcp> ler() async => salvo;

  @override
  Future<void> gravar(ConfiguracaoMcp configuracao) async => salvo = configuracao;
}

/// Servidor que só finge escutar; com [ocupada], a porta já tem dono.
class ServidorMcpFalso implements ServidorMcp {
  ServidorMcpFalso({this.ocupada = false});

  final bool ocupada;
  String? tokenEmUso;

  @override
  Future<int> iniciar({required int porta, required String token, required ProtocoloMcp protocolo}) async {
    if (ocupada) throw ErroPortaOcupada(porta, 'em uso');
    tokenEmUso = token;
    return porta;
  }

  @override
  Future<void> parar() async => tokenEmUso = null;
}
