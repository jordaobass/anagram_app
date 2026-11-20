// Biblioteca de efeitos para montar a cadeia: o que pode ir numa casa vazia,
// como um bloco novo nasce no formato que a pedaleira grava e quais blocos
// não podem mudar de lugar.
import '../modelo/bloco_preset.dart';
import '../modelo/documento_preset.dart';
import 'catalogo_blocos.dart';
import 'definicao_bloco.dart';
import 'familia_bloco.dart';

class GrupoBiblioteca {
  const GrupoBiblioteca(this.familia, this.blocos);

  final FamiliaBloco familia;
  final List<DefinicaoBloco> blocos;
}

/// Blocos que definem o caminho do sinal (abrem e fecham a linha paralela,
/// saída) ou que são do sistema, não efeitos de cadeia. Hipótese a conferir
/// na bancada: se a pedaleira aceita algum deles numa casa comum (DECISOES B3).
const _blocosDeSistema = {
  'urn:darkglass-anagram:split',
  'urn:darkglass-anagram:merge',
  'urn:darkglass-anagram:output',
  'urn:darkglass-anagram:mixer',
  'urn:darkglass-anagram:meters',
  'urn:darkglass-anagram:exp-pedal',
  'urn:darkglass-anagram:midi-cc-helper',
  'urn:darkglass-anagram:midi-pc-gen',
  'urn:darkglass-anagram:sine-gen',
};

/// Split e merge marcam onde a linha 2 sai e volta: movê-los (ou trocá-los
/// com outro bloco) mudaria o roteamento sem a pessoa perceber.
bool ehBlocoDeRoteamento(String uri) =>
    uri == 'urn:darkglass-anagram:split' || uri == 'urn:darkglass-anagram:merge';

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

Iterable<DefinicaoBloco> _efeitos(CatalogoBlocos catalogo) =>
    catalogo.todos.where((bloco) => !_blocosDeSistema.contains(bloco.uri));

bool _casaComBusca(DefinicaoBloco bloco, String termo) =>
    termo.isEmpty || bloco.nome.toLowerCase().contains(termo) || bloco.abreviacao.toLowerCase().contains(termo);

/// Mover [de] para [para] só vale se há bloco na origem e nenhum dos dois
/// lados é split/merge.
bool podeMover(DocumentoPreset documento, PosicaoBloco de, PosicaoBloco para) {
  final origem = documento.bloco(de);
  if (origem == null || de == para || ehBlocoDeRoteamento(origem.uri)) return false;
  final destino = documento.bloco(para);
  return destino == null || !ehBlocoDeRoteamento(destino.uri);
}
