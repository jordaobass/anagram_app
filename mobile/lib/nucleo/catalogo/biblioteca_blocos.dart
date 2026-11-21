// Biblioteca de efeitos para montar a cadeia: o que pode ir numa casa vazia,
// como um bloco novo nasce no formato que a pedaleira grava e quais blocos
// não podem mudar de lugar.
import '../modelo/bloco_preset.dart';
import '../modelo/documento_preset.dart';
import 'catalogo_blocos.dart';
import 'definicao_bloco.dart';
import 'familia_bloco.dart';
import 'linha_paralela.dart';

export 'linha_paralela.dart' show ehBlocoDeRoteamento;

class GrupoBiblioteca {
  const GrupoBiblioteca(this.familia, this.blocos);

  final FamiliaBloco familia;
  final List<DefinicaoBloco> blocos;
}

/// Blocos do sistema (saída, mixer, medidores, MIDI), não efeitos de cadeia.
/// Split e Merge NÃO estão aqui: entram pela biblioteca como os outros, um de
/// cada vez (DECISOES M11). Hipótese a conferir na bancada: se a pedaleira
/// aceita algum destes numa casa comum (DECISOES B3).
const _blocosDeSistema = {
  'urn:darkglass-anagram:output',
  'urn:darkglass-anagram:mixer',
  'urn:darkglass-anagram:meters',
  'urn:darkglass-anagram:exp-pedal',
  'urn:darkglass-anagram:midi-cc-helper',
  'urn:darkglass-anagram:midi-pc-gen',
  'urn:darkglass-anagram:sine-gen',
};


/// Papéis de parâmetro que os presets gravados pela pedaleira não guardam:
/// o liga/desliga é o `enabled` do bloco, e reset e tempo são ações do aparelho.
const _papeisFora = {'bypass', 'reset', 'hostTempo'};

/// O bloco escolhido na biblioteca, com as mesmas chaves que a pedaleira grava
/// e os valores padrão do catálogo. O quickpot é o parâmetro que o catálogo
/// marca como padrão; sem marca, o primeiro guardado.
Map<String, dynamic> blocoNovo(DefinicaoBloco definicao) {
  final guardados = [for (final p in definicao.parametros) if (!_papeisFora.contains(p.papel)) p];
  final quickpot = definicao.parametros.where((p) => p.papel == 'quickpotDefault').firstOrNull ?? guardados.firstOrNull;
  return {
    'enabled': true,
    'parameters': {
      for (var i = 0; i < guardados.length; i++)
        '${i + 1}': {'name': guardados[i].nome, 'symbol': guardados[i].simbolo, 'value': guardados[i].padrao},
    },
    'properties': <String, dynamic>{},
    'quickpot': quickpot?.simbolo ?? '',
    'scenes': {
      for (var cena = 1; cena <= 3; cena++) '$cena': {'enabled': true, 'parameters': <dynamic>[]},
    },
    'uri': definicao.uri,
  };
}

/// Efeitos agrupados pela família (a mesma da cor e do filtro), na ordem do
/// enum, sem os blocos de sistema. A busca ignora maiúsculas e pega nome ou
/// abreviação; [familia] restringe a uma família só.
List<GrupoBiblioteca> blocosDaBiblioteca(CatalogoBlocos catalogo, {String busca = '', FamiliaBloco? familia}) {
  final termo = busca.trim().toLowerCase();
  final porFamilia = <FamiliaBloco, List<DefinicaoBloco>>{};
  for (final bloco in _efeitos(catalogo)) {
    if (familia != null && bloco.familia != familia) continue;
    if (!_casaComBusca(bloco, termo)) continue;
    porFamilia.putIfAbsent(bloco.familia, () => []).add(bloco);
  }
  return [
    for (final f in FamiliaBloco.values)
      if (porFamilia[f] case final blocos?) GrupoBiblioteca(f, blocos..sort((a, b) => a.nome.compareTo(b.nome))),
  ];
}

/// Famílias que têm ao menos um efeito na biblioteca: só elas viram filtro,
/// para nenhum filtro levar a uma lista vazia.
List<FamiliaBloco> familiasDaBiblioteca(CatalogoBlocos catalogo) {
  final presentes = {for (final bloco in _efeitos(catalogo)) bloco.familia};
  return [for (final f in FamiliaBloco.values) if (presentes.contains(f)) f];
}

/// Outras palavras que acham Split e Merge na busca, nos três idiomas, além
/// do nome e da abreviação do catálogo: quem procura "paralela" ou "dividir"
/// não sabe que o bloco se chama Split.
const _sinonimos = {
  uriSplit: ['paralel', 'parallel', 'dividir', 'divide', 'linha 2', 'fila 2', 'row 2'],
  uriMerge: ['paralel', 'parallel', 'juntar', 'unir', 'join', 'linha 2', 'fila 2', 'row 2'],
};

Iterable<DefinicaoBloco> _efeitos(CatalogoBlocos catalogo) =>
    catalogo.todos.where((bloco) => !_blocosDeSistema.contains(bloco.uri));

bool _casaComBusca(DefinicaoBloco bloco, String termo) =>
    termo.isEmpty ||
    bloco.nome.toLowerCase().contains(termo) ||
    bloco.abreviacao.toLowerCase().contains(termo) ||
    // sinônimo só a partir de 3 letras: "a" sozinho não traz o Split
    (termo.length >= 3 && (_sinonimos[bloco.uri] ?? const []).any((s) => s.contains(termo) || termo.contains(s)));

/// Por que um "mover" (arrastar ou menu) não vale. Split e Merge andam pela
/// linha 1 e trocam com bloco comum, mas nunca vão para a linha 2 e o Split
/// fica sempre antes do Merge (nos presets reais eles não precisam estar
/// juntos nem alinhados com a linha 2: exemplos 1 e 2, DECISOES M10).
enum RecusaMover { semOrigem, mesmaCasa, roteamentoForaDaLinha1, splitDepoisDoMerge }

/// Nulo quando mover [de] para [para] vale; casa vazia recebe, ocupada troca.
RecusaMover? recusaAoMover(DocumentoPreset documento, PosicaoBloco de, PosicaoBloco para) {
  final origem = documento.bloco(de);
  if (origem == null) return RecusaMover.semOrigem;
  if (de == para) return RecusaMover.mesmaCasa;
  PosicaoBloco depois(PosicaoBloco p) => p == de ? para : (p == para ? de : p);
  final split = posicaoNaLinha1(documento, uriSplit);
  final merge = posicaoNaLinha1(documento, uriMerge);
  final novoSplit = split == null ? null : depois(split);
  final novoMerge = merge == null ? null : depois(merge);
  if ((novoSplit != null && novoSplit.linha != 1) || (novoMerge != null && novoMerge.linha != 1)) {
    return RecusaMover.roteamentoForaDaLinha1;
  }
  if (novoSplit != null && novoMerge != null && novoSplit.casa > novoMerge.casa) return RecusaMover.splitDepoisDoMerge;
  return null;
}

bool podeMover(DocumentoPreset documento, PosicaoBloco de, PosicaoBloco para) =>
    recusaAoMover(documento, de, para) == null;
