// O que as ferramentas do MCP enxergam do app. Toda mudança passa pelo
// ControladorEditor, o mesmo caminho dos controles da tela: soa ao vivo e
// deixa o preset "não salvo". O app não tem histórico geral de desfazer;
// a sessão guarda o das mudanças feitas pela IA, e só volta se a pessoa não
// mexeu no preset depois (senão o desfazer apagaria a edição dela).
import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';

import '../../nucleo/ajustes/modo_footswitches.dart';
import '../../nucleo/catalogo/catalogo_blocos.dart';
import '../../nucleo/catalogo/catalogo_gabinetes.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/catalogo/explicacoes_parametros.dart';
import '../../nucleo/conhecimento/base_conhecimento.dart';
import '../../nucleo/mcp/ferramenta_mcp.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../../nucleo/modelo/cenas_do_bloco.dart';
import '../../nucleo/modelo/documento_preset.dart';
import '../estado/blocos_da_pedaleira.dart';
import '../estado/controlador_ajustes.dart';
import '../estado/controlador_conexao.dart';
import '../estado/controlador_editor.dart';
import '../estado/controlador_modo_footswitches.dart';
import '../estado/estado_conexao.dart';
import '../estado/escopo_cenas.dart';
import '../estado/estado_editor.dart';
import '../estado/ponto_desfazer.dart';
import '../idioma.dart';
import '../provedores.dart';
import 'avisos_mcp.dart';

/// Recusa que a IA consegue explicar à pessoa, a mesma em toda ferramenta.
void exigirPedaleiraConectada(Ref ref) {
  if (ref.read(conexaoProvider) is! Conectada) {
    throw const RecusaFerramenta('The pedal is not connected. Ask the player to connect it '
        '(or open the demo) in the Anagram App.');
  }
}

class SessaoMcp {
  SessaoMcp(this._ref);

  final Ref _ref;
  final List<PontoDesfazer> _historico = [];

  static const _limiteHistorico = 50;

  ControladorEditor get editor => _ref.read(editorProvider.notifier);
  EstadoEditor get estado => _ref.read(editorProvider);

  /// A chave "Controlar" da tela: o `scope` quando a IA não manda um.
  EscopoCenas get escopoDaTela => _ref.read(escopoCenasProvider);

  /// O preset aberto, ou a recusa que explica à IA o que falta.
  DocumentoPreset presetAberto() {
    exigirPedaleiraConectada(_ref);
    final atual = estado.atual;
    if (estado.ocupado) throw const RecusaFerramenta('The app is loading or saving a preset; try again in a moment.');
    if (atual == null) throw const RecusaFerramenta('No preset is open. Ask the player to open one in the app.');
    return atual;
  }

  /// Espera a pedaleira terminar de descrever os blocos fora do catálogo
  /// (instalados e do preset aberto, P4) antes de listar ou descrever blocos.
  Future<void> esperarBlocosDaPedaleira() => _ref.read(blocosDaPedaleiraProvider.notifier).emAndamento;

  /// O catálogo de fábrica com os blocos que a pedaleira descreveu (P4).
  CatalogoBlocos catalogo() =>
      _ref.read(catalogoEmUsoProvider) ?? (throw const RecusaFerramenta('The block catalog is still loading.'));

  CatalogoGabinetes gabinetes() =>
      _ref.read(indiceMiniaturasProvider).value?.escolhasDeGabinete ?? const CatalogoGabinetes.vazio();

  DefinicaoBloco definicao(String uri) => _ref.read(definicaoBlocoProvider(uri));

  /// O conhecimento de timbre (IC1), esperando o arquivo carregar na primeira
  /// chamada; sem o arquivo, a base vem vazia e a ferramenta explica.
  Future<BaseConhecimento> conhecimento() => _ref.read(conhecimentoProvider.future);

  Future<ExplicacoesParametros> explicacoes() => _ref.read(explicacoesProvider.future);

  /// O bloco na posição dos argumentos (`row`, `column`), ou a recusa.
  BlocoPreset bloco(Map<String, dynamic> argumentos, {String linha = 'row', String casa = 'column'}) {
    final posicao = posicaoDe(argumentos, linha: linha, casa: casa);
    return presetAberto().bloco(posicao) ??
        (throw RecusaFerramenta('There is no block at row ${posicao.linha}, column ${posicao.casa}. '
            'Call get_current_preset to see the chain.'));
  }

  static PosicaoBloco posicaoDe(Map<String, dynamic> argumentos, {String linha = 'row', String casa = 'column'}) {
    final numeroLinha = argumentos.inteiroObrigatorio(linha);
    final numeroCasa = argumentos.inteiroObrigatorio(casa);
    final foraDaGrade = numeroLinha < 1 || numeroLinha > PosicaoBloco.linhas ||
        numeroCasa < 1 || numeroCasa > PosicaoBloco.casasPorLinha;
    if (foraDaGrade) {
      throw const RecusaFerramenta('Position must be row 1-${PosicaoBloco.linhas}, column 1-${PosicaoBloco.casasPorLinha}.');
    }
    return PosicaoBloco(numeroLinha, numeroCasa);
  }

  /// O esquema da posição que [posicaoDe] lê (`row`, `column`, com [prefixo]).
  static Map<String, Map<String, dynamic>> esquemaPosicao({String prefixo = ''}) => {
        '${prefixo}row': inteiro('Row (1 = main line, 2 = parallel line).', minimo: 1, maximo: PosicaoBloco.linhas),
        '${prefixo}column':
            inteiro('Column, 1-${PosicaoBloco.casasPorLinha}.', minimo: 1, maximo: PosicaoBloco.casasPorLinha),
      };

  /// O modo dos footswitches lido da pedaleira (nulo se o firmware não informa).
  Future<ModoFootswitches?> modoFootswitches() async {
    await _ref.read(controladorModoProvider.notifier).garantirLeitura();
    return _ref.read(controladorAjustesProvider).lidos?.modo;
  }

  /// O nome que a tela dá a um preset novo ("Novo preset"), no idioma do
  /// app: o escolhido, ou o do sistema como a tela resolve.
  String nomeDePresetNovo() {
    final idioma = _ref.read(idiomaProvider) ?? IdiomaApp.doSistema(PlatformDispatcher.instance.locale.toLanguageTag());
    return lookupAppLocalizations(Locale(idioma.codigo)).cdNovoPreset;
  }

  /// A tela mostra o aviso "IA: …" também do que não muda o preset aberto.
  void avisar(String resumo) => _ref.read(avisosMcpProvider.notifier).mudancaDaIa(resumo);

  /// Faz a mudança pelo editor e, se o preset mudou, guarda o anterior para
  /// o `undo` e avisa a tela de que a mudança veio da IA.
  ///
  /// Se a tela não está mais no que a IA deixou (a pessoa mexeu num knob ou
  /// abriu outro preset), o histórico anterior é descartado: voltar a ele
  /// apagaria a edição da pessoa ou poria outro preset dentro deste slot.
  Future<void> mudar(String resumo, Future<void> Function() acao) async {
    presetAberto();
    final ponto = await editor.comDesfazer(acao);
    if (ponto == null) return;
    if (_historico.isNotEmpty && !_historico.last.valeEm(ponto.antes)) _historico.clear();
    _historico.add(ponto);
    if (_historico.length > _limiteHistorico) _historico.removeAt(0);
    avisar(resumo);
  }

  /// Volta a última mudança da IA; devolve quantas ainda dá para voltar.
  Future<int> desfazer() async {
    final atual = presetAberto();
    if (_historico.isEmpty) throw const RecusaFerramenta('Nothing to undo: no change was made through MCP.');
    if (!_historico.last.valeEm(atual)) {
      _historico.clear();
      throw const RecusaFerramenta('The player changed the preset in the app after your last change; '
          'undo was refused so their edit is kept. Read the preset again.');
    }
    await editor.desfazer(_historico.removeLast());
    avisar('undo');
    return _historico.length;
  }
}
