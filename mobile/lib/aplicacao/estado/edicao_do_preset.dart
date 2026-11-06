// Edições do documento aberto (bloco, cena, nome). Cada uma passa por
// [aplicarDocumento], que atualiza o estado e toca ao vivo se ligado.
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  Future<void> removerBloco(PosicaoBloco posicao) async {
    final atual = state.atual;
    if (atual == null || atual.bloco(posicao) == null) return;
    await aplicarDocumento(atual.semBloco(posicao));
    state = state.copiar(selecionado: primeiraPosicao(state.atual!));
  }

  /// Slot vazio aberto: começa um preset novo ali (com uuid próprio).
  Future<void> novoPresetNoSlot() async {
    if (state.slot == null || state.atual != null) return;
    await carregarDocumento(DocumentoPreset.vazio('Novo preset').comUuid(novoUuidPreset()));
  }
}

PosicaoBloco? primeiraPosicao(DocumentoPreset documento) {
  for (final linha in const [1, 2]) {
    final blocos = documento.blocosDaLinha(linha);
    if (blocos.isNotEmpty) return blocos.first.posicao;
  }
  return null;
}
