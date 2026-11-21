// O que as ferramentas do MCP enxergam do app. Toda mudança passa pelo
// ControladorEditor, o mesmo caminho dos controles da tela: soa ao vivo e
// deixa o preset "não salvo". O app não tem histórico geral de desfazer;
// a sessão guarda o das mudanças feitas pela IA, e só volta se a pessoa não
// mexeu no preset depois (senão o desfazer apagaria a edição dela).
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../nucleo/catalogo/catalogo_blocos.dart';
import '../../nucleo/catalogo/catalogo_gabinetes.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/mcp/ferramenta_mcp.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../../nucleo/modelo/documento_preset.dart';
import '../estado/controlador_conexao.dart';
import '../estado/controlador_editor.dart';
import '../estado/estado_conexao.dart';
import '../estado/estado_editor.dart';
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
  final List<DocumentoPreset> _historico = [];

  /// O documento que a última mudança da IA deixou na tela.
  DocumentoPreset? _deixadoPelaIa;

  static const _limiteHistorico = 50;

  ControladorEditor get editor => _ref.read(editorProvider.notifier);
  EstadoEditor get estado => _ref.read(editorProvider);

  /// O preset aberto, ou a recusa que explica à IA o que falta.
  DocumentoPreset presetAberto() {
    exigirPedaleiraConectada(_ref);
    final atual = estado.atual;
    if (estado.ocupado) throw const RecusaFerramenta('The app is loading or saving a preset; try again in a moment.');
    if (atual == null) throw const RecusaFerramenta('No preset is open. Ask the player to open one in the app.');
    return atual;
  }

  CatalogoBlocos catalogo() =>
      _ref.read(catalogoProvider).value ?? (throw const RecusaFerramenta('The block catalog is still loading.'));

  CatalogoGabinetes gabinetes() =>
      _ref.read(indiceMiniaturasProvider).value?.escolhasDeGabinete ?? const CatalogoGabinetes.vazio();

  DefinicaoBloco definicao(String uri) => _ref.read(definicaoBlocoProvider(uri));

  /// O bloco na posição dos argumentos (`row`, `column`), ou a recusa.
  BlocoPreset bloco(Map<String, dynamic> argumentos, {String linha = 'row', String casa = 'column'}) {
    final posicao = posicaoDe(argumentos, linha: linha, casa: casa);
    return presetAberto().bloco(posicao) ??
        (throw RecusaFerramenta('There is no block at row ${posicao.linha}, column ${posicao.casa}. '
            'Call get_current_preset to see the chain.'));
  }

  static PosicaoBloco posicaoDe(Map<String, dynamic> argumentos, {String linha = 'row', String casa = 'column'}) {
    final l = argumentos.inteiroObrigatorio(linha);
    final c = argumentos.inteiroObrigatorio(casa);
    if (l < 1 || l > PosicaoBloco.linhas || c < 1 || c > PosicaoBloco.casasPorLinha) {
      throw const RecusaFerramenta('Position must be row 1-${PosicaoBloco.linhas}, column 1-${PosicaoBloco.casasPorLinha}.');
    }
    return PosicaoBloco(l, c);
  }

  /// Faz a mudança pelo editor e, se o preset mudou, guarda o anterior para
  /// o `undo` e avisa a tela de que a mudança veio da IA.
  ///
  /// Se a tela não está mais no que a IA deixou (a pessoa mexeu num knob ou
  /// abriu outro preset), o histórico anterior é descartado: voltar a ele
  /// apagaria a edição da pessoa ou poria outro preset dentro deste slot.
  Future<void> mudar(String resumo, Future<void> Function() acao) async {
    final antes = presetAberto();
    await acao();
    final depois = estado.atual;
    if (depois == null || identical(depois, antes)) return;
    if (!identical(antes, _deixadoPelaIa)) _historico.clear();
    _historico.add(antes);
    if (_historico.length > _limiteHistorico) _historico.removeAt(0);
    _deixadoPelaIa = depois;
    _ref.read(avisosMcpProvider.notifier).mudancaDaIa(resumo);
  }

  /// Volta a última mudança da IA; devolve quantas ainda dá para voltar.
  Future<int> desfazer() async {
    final atual = presetAberto();
    if (_historico.isEmpty) throw const RecusaFerramenta('Nothing to undo: no change was made through MCP.');
    if (!identical(atual, _deixadoPelaIa)) {
      _historico.clear();
      throw const RecusaFerramenta('The player changed the preset in the app after your last change; '
          'undo was refused so their edit is kept. Read the preset again.');
    }
    final anterior = _historico.removeLast();
    await editor.aplicarDocumento(anterior);
    _deixadoPelaIa = estado.atual;
    _ref.read(avisosMcpProvider.notifier).mudancaDaIa('undo');
    return _historico.length;
  }
}
