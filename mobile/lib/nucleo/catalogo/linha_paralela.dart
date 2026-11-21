// Linha paralela: o sinal se divide no Split, passa pela linha 2 e volta no
// Merge. Nos presets reais (exemplos 1 e 2) Split e Merge ficam na linha 1
// (casas 5 e 11; 6 e 7) e a linha 2 é uma cadeia própria, que começa na casa
// 1 dela: não precisa ficar "entre" as casas do Split e do Merge.
import '../modelo/bloco_preset.dart';
import '../modelo/documento_preset.dart';
import 'biblioteca_blocos.dart';
import 'catalogo_blocos.dart';

const uriSplit = 'urn:darkglass-anagram:split';
const uriMerge = 'urn:darkglass-anagram:merge';

bool temLinhaParalela(DocumentoPreset documento) => documento.blocosDaLinha(1).any((b) => b.uri == uriSplit);

/// Põe o Split na primeira casa livre da linha 1 depois de [depoisDe] (sem
/// escolha: depois do último bloco, para o sinal passar por tudo e só então
/// dividir) e o Merge na casa livre seguinte, com os padrões do catálogo.
/// Sem duas casas livres depois do ponto, tenta do começo; sem nenhuma, nulo.
DocumentoPreset? comLinhaParalela(DocumentoPreset documento, CatalogoBlocos catalogo, {int? depoisDe}) {
  if (temLinhaParalela(documento)) return documento;
  final ocupadas = {for (final bloco in documento.blocosDaLinha(1)) bloco.posicao.casa};
  final ultimo = ocupadas.isEmpty ? 0 : ocupadas.reduce((a, b) => a > b ? a : b);
  final casas = _duasLivresDepois(ocupadas, depoisDe ?? ultimo) ?? _duasLivresDepois(ocupadas, 0);
  if (casas == null) return null;
  final (split, merge) = casas;
  return documento
      .comBlocoColado(PosicaoBloco(1, split), blocoNovo(catalogo.definicao(uriSplit)))
      .comBlocoColado(PosicaoBloco(1, merge), blocoNovo(catalogo.definicao(uriMerge)));
}

/// Tira Split e Merge e os blocos da linha 2: sem a divisão, a linha 2 não
/// recebe sinal, e mover os blocos para a linha 1 mudaria o som sem a pessoa
/// pedir (a tela pergunta antes quando a linha 2 tem blocos).
DocumentoPreset semLinhaParalela(DocumentoPreset documento) {
  var resultado = documento;
  final saem = [
    for (final bloco in documento.blocosDaLinha(1))
      if (bloco.uri == uriSplit || bloco.uri == uriMerge) bloco.posicao,
    for (final bloco in documento.blocosDaLinha(2)) bloco.posicao,
  ];
  for (final posicao in saem) {
    resultado = resultado.semBloco(posicao);
  }
  return resultado;
}

(int, int)? _duasLivresDepois(Set<int> ocupadas, int referencia) {
  final livres = [
    for (var casa = referencia + 1; casa <= PosicaoBloco.casasPorLinha; casa++)
      if (!ocupadas.contains(casa)) casa,
  ];
  return livres.length < 2 ? null : (livres[0], livres[1]);
}
