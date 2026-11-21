// Edições do documento aberto (bloco, cena, nome). Cada uma passa por
// [aplicarDocumento], que atualiza o estado e toca ao vivo se ligado.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../nucleo/catalogo/biblioteca_blocos.dart';
import '../../nucleo/catalogo/linha_paralela.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../../nucleo/modelo/documento_preset.dart';
import 'estado_editor.dart';

mixin EdicaoDoPreset on Notifier<EstadoEditor> {
  Future<void> aplicarDocumento(DocumentoPreset documento);

  Future<void> alternarBypass(PosicaoBloco posicao) async {
    final bloco = state.atual?.bloco(posicao);
    if (bloco == null) return;
    final ligado = bloco.habilitadoNaCena(state.atual!.cenaAtiva);
    await aplicarDocumento(state.atual!.comBlocoHabilitado(posicao, !ligado));
  }

  Future<void> escolherCena(int cena) async {
    final atual = state.atual;
    if (atual != null) await aplicarDocumento(atual.comCena(cena));
  }

  void copiarBloco(PosicaoBloco posicao) {
    final bloco = state.atual?.bloco(posicao);
    if (bloco != null) state = state.copiar(blocoCopiado: bloco.bruto);
  }

  Future<void> colarBloco(PosicaoBloco posicao) async {
    final copia = state.blocoCopiado;
    final atual = state.atual;
    if (copia == null || atual == null) return;
    await aplicarDocumento(atual.comBlocoColado(posicao, copia));
    state = state.copiar(selecionado: posicao);
  }

  Future<void> descartarEdicoes() async {
    final original = state.original;
    if (original != null) await aplicarDocumento(original);
  }

  /// Troca o documento aberto por um importado (fica "não salvo").
  Future<void> carregarDocumento(DocumentoPreset documento) async {
    state = state.copiar(original: null, selecionado: primeiraPosicao(documento));
    await aplicarDocumento(documento);
  }

  /// Nome vazio ou com marcador de quadro HID é ignorado (o diálogo já explica).
  Future<void> renomear(String nome) async {
    final atual = state.atual;
    if (atual != null && motivoNomeInvalido(nome) == null) await aplicarDocumento(atual.comNome(nome.trim()));
  }

  /// Gabinete: o IR do modelo/microfone/posição escolhido (ao vivo, desfazer).
  Future<void> escolherIrDoGabinete(PosicaoBloco posicao, String caminho) async {
    final atual = state.atual;
    if (atual == null || atual.bloco(posicao) == null) return;
    await aplicarDocumento(atual.comArquivoDeIr(posicao, caminho));
  }

  /// Tirar o Split leva junto o Merge e a linha 2 (ver [semSplit]; a tela
  /// pergunta antes quando a linha 2 tem blocos).
  Future<void> removerBloco(PosicaoBloco posicao) async {
    final atual = state.atual;
    final bloco = atual?.bloco(posicao);
    if (atual == null || bloco == null) return;
    await aplicarDocumento(bloco.uri == uriSplit ? semSplit(atual) : atual.semBloco(posicao));
    state = state.copiar(selecionado: primeiraPosicao(state.atual!));
  }

  /// Efeito escolhido na biblioteca entra numa casa vazia, com os padrões do
  /// catálogo. Casa ocupada fica como está: substituir é remover e adicionar.
  /// Split e Merge seguem [recusaAoAdicionar]; a recusa volta para a tela.
  Future<RecusaAdicionar?> adicionarBloco(PosicaoBloco posicao, DefinicaoBloco definicao) async {
    final atual = state.atual;
    if (atual == null || atual.bloco(posicao) != null) return null;
    final recusa = recusaAoAdicionar(atual, posicao, definicao.uri);
    if (recusa != null) return recusa;
    await aplicarDocumento(atual.comBlocoColado(posicao, blocoNovo(definicao)));
    state = state.copiar(selecionado: posicao);
    return null;
  }

  /// Arrastar ou "Mover para": casa vazia recebe o bloco, ocupada troca.
  /// Split e merge ficam onde estão (definem o caminho da linha paralela).
  Future<void> moverBloco(PosicaoBloco de, PosicaoBloco para) async {
    final atual = state.atual;
    if (atual == null || !podeMover(atual, de, para)) return;
    await aplicarDocumento(atual.comBlocoMovido(de, para));
    state = state.copiar(selecionado: para);
  }

  /// Slot vazio aberto: começa um preset novo ali (com uuid próprio). O
  /// [nome] vem da tela, no idioma em uso: ele é gravado na pedaleira.
  Future<void> novoPresetNoSlot(String nome) async {
    if (state.slot == null || state.atual != null) return;
    await carregarDocumento(DocumentoPreset.vazio(nome).comUuid(novoUuidPreset()));
  }
}

PosicaoBloco? primeiraPosicao(DocumentoPreset documento) {
  for (final linha in const [1, 2]) {
    final blocos = documento.blocosDaLinha(linha);
    if (blocos.isNotEmpty) return blocos.first.posicao;
  }
  return null;
}
