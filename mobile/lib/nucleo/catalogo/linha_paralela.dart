// Linha paralela: o sinal se divide no Split, passa pela linha 2 e volta no
// Merge. Split e Merge são blocos comuns da biblioteca, postos um de cada vez
// como qualquer efeito (pedido do dono, DECISOES M11): o Split "abre abaixo"
// e o Merge "junta acima". Nos presets reais (exemplos 1 e 2) os dois ficam
// na linha 1 (casas 5 e 11; 6 e 7) e a linha 2 é uma cadeia própria, que
// começa na casa 1 dela: não precisa ficar "entre" o Split e o Merge.
import '../modelo/bloco_preset.dart';
import '../modelo/documento_preset.dart';

const uriSplit = 'urn:darkglass-anagram:split';
const uriMerge = 'urn:darkglass-anagram:merge';

/// Split e merge marcam onde a linha 2 sai e volta: copiar ou colar por cima
/// deles quebraria o roteamento. Mudar de lugar pode, com as regras de
/// `recusaAoMover`; pôr e tirar, com as daqui.
bool ehBlocoDeRoteamento(String uri) => uri == uriSplit || uri == uriMerge;

bool temLinhaParalela(DocumentoPreset documento) => documento.blocosDaLinha(1).any((b) => b.uri == uriSplit);

/// Por que um Split ou Merge não pode entrar numa casa. Os outros blocos
/// entram em qualquer casa vazia.
enum RecusaAdicionar { splitRepetido, mergeRepetido, mergeSemSplit, foraDaLinha1, mergeAntesDoSplit, splitDepoisDoMerge }

/// Nulo quando o bloco [uri] pode entrar em [posicao]: um Split e um Merge
/// por preset, os dois na linha 1, o Merge só com Split e sempre depois dele.
RecusaAdicionar? recusaAoAdicionar(DocumentoPreset documento, PosicaoBloco posicao, String uri) {
  if (!ehBlocoDeRoteamento(uri)) return null;
  final split = _casaNaLinha1(documento, uriSplit);
  final merge = _casaNaLinha1(documento, uriMerge);
  if (uri == uriSplit) {
    if (split != null) return RecusaAdicionar.splitRepetido;
    if (posicao.linha != 1) return RecusaAdicionar.foraDaLinha1;
    if (merge != null && posicao.casa > merge) return RecusaAdicionar.splitDepoisDoMerge;
    return null;
  }
  if (merge != null) return RecusaAdicionar.mergeRepetido;
  if (split == null) return RecusaAdicionar.mergeSemSplit;
  if (posicao.linha != 1) return RecusaAdicionar.foraDaLinha1;
  if (posicao.casa < split) return RecusaAdicionar.mergeAntesDoSplit;
  return null;
}

/// Remover o Split leva junto o Merge e os blocos da linha 2: sem a divisão
/// a linha 2 não recebe sinal e o Merge não tem o que juntar (a tela pergunta
/// antes quando a linha 2 tem blocos). Remover o Merge sozinho é comum: a
/// linha 2 segue até a saída.
DocumentoPreset semSplit(DocumentoPreset documento) {
  var resultado = documento;
  final saem = [
    for (final bloco in documento.blocosDaLinha(1))
      if (ehBlocoDeRoteamento(bloco.uri)) bloco.posicao,
    for (final bloco in documento.blocosDaLinha(2)) bloco.posicao,
  ];
  for (final posicao in saem) {
    resultado = resultado.semBloco(posicao);
  }
  return resultado;
}

/// Onde está o bloco [uri] na linha 1 (Split e Merge só moram nela).
PosicaoBloco? posicaoNaLinha1(DocumentoPreset documento, String uri) =>
    documento.blocosDaLinha(1).where((b) => b.uri == uri).firstOrNull?.posicao;

int? _casaNaLinha1(DocumentoPreset documento, String uri) => posicaoNaLinha1(documento, uri)?.casa;
