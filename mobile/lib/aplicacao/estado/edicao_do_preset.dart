// Edições do documento aberto (bloco, cena, nome). Cada uma passa por
// [aplicarDocumento], que atualiza o estado e toca ao vivo se ligado.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../nucleo/catalogo/biblioteca_blocos.dart';
import '../../nucleo/catalogo/linha_paralela.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../../nucleo/modelo/documento_preset.dart';
import 'escopo_cenas.dart';
import 'estado_editor.dart';
import 'ponto_desfazer.dart';

mixin EdicaoDoPreset on Notifier<EstadoEditor> {
  Future<void> aplicarDocumento(DocumentoPreset documento);

  /// Faz a [mudanca] e devolve como voltar ao documento de antes dela (nulo
  /// se nada mudou). Ver [PontoDesfazer].
  Future<PontoDesfazer?> comDesfazer(FutureOr<void> Function() mudanca) async {
    final antes = state.atual;
    await mudanca();
    final depois = state.atual;
    if (antes == null || depois == null || identical(antes, depois)) return null;
    return PontoDesfazer(antes, depois);
  }

  /// Volta ao documento de antes do [ponto], se o preset ainda é o que ele
  /// deixou (trocar de cena depois não conta); fica na cena atual. Devolve se
  /// voltou. Soa ao vivo, como qualquer edição.
  Future<bool> desfazer(PontoDesfazer ponto) async {
    final atual = state.atual;
    if (atual == null || !ponto.valeEm(atual)) return false;
    await aplicarDocumento(ponto.voltarEm(atual));
    return true;
  }

  /// Nas cenas da chave "Controlar" ([escopoCenasProvider]).
  Future<void> alternarBypass(PosicaoBloco posicao) async {
    final bloco = state.atual?.bloco(posicao);
    if (bloco == null) return;
    final ligado = bloco.habilitadoNaCena(state.atual!.cenaAtiva);
    await aplicarDocumento(state.atual!.comBlocoHabilitado(posicao, !ligado, escopo: ref.read(escopoCenasProvider)));
  }

  /// Cena que o preset não tem é ignorada (atalho 9 num preset de três).
  Future<void> escolherCena(int cena) async {
    final atual = state.atual;
    if (atual != null && cena >= 1 && cena <= atual.quantidadeCenas) await aplicarDocumento(atual.comCena(cena));
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

  /// Vários parâmetros do mesmo bloco numa alteração só (template, solo da
  /// banda): cada um vale como o knob (nas cenas da chave "Controlar"), mas a
  /// pedaleira recebe um envio só, sem passar pelos estados intermediários.
  Future<void> alterarParametros(PosicaoBloco posicao, Map<String, num> valores,
      {Map<String, String> nomes = const {}, Map<String, num> padroes = const {}}) async {
    var documento = state.atual;
    if (documento == null || documento.bloco(posicao) == null || valores.isEmpty) return;
    final escopo = ref.read(escopoCenasProvider);
    for (final MapEntry(key: simbolo, value: valor) in valores.entries) {
      documento = documento!.comParametro(posicao, simbolo, valor,
          nomeExibicao: nomes[simbolo], escopo: escopo, valorAntes: padroes[simbolo]);
    }
    await aplicarDocumento(documento!);
  }

  /// O arquivo do bloco: o IR do gabinete (modelo/microfone/posição) ou o
  /// tom/modelo do TONE3000 (ao vivo, desfazer, não salvo).
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
