// Editor no estilo HX Edit: abrir preset faz ele tocar; mexer em bloco,
// bypass ou cena soa na hora (se "Ao vivo" estiver ligado); gravar no
// slot é separado e só acontece com confirmação.
//
// Abrir fala com a pedaleira e leva de um a três segundos: cada passo
// confere, depois de cada espera, se o que ele ia mostrar ainda vale.
// A gravação fica em [GravacaoDoEditor]; o envio ao vivo, em [AoVivoDoEditor].
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dados/repositorio_pedaleira.dart';
import '../../nucleo/midi/saida_midi.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../../nucleo/modelo/documento_preset.dart';
import '../../nucleo/modelo/slot_preset.dart';
import '../../nucleo/registro.dart';
import '../../nucleo/resultado.dart';
import 'ao_vivo_do_editor.dart';
import 'controlador_biblioteca.dart';
import 'controlador_conexao.dart';
import 'edicao_do_preset.dart';
import 'estado_conexao.dart';
import 'estado_editor.dart';
import 'gravacao_do_editor.dart';

final editorProvider = NotifierProvider<ControladorEditor, EstadoEditor>(ControladorEditor.new);

class ControladorEditor extends Notifier<EstadoEditor> with EdicaoDoPreset, AoVivoDoEditor, GravacaoDoEditor {
  /// Cresce a cada abertura: o resultado de uma abertura vencida é descartado.
  int _abertura = 0;

  @override
  EstadoEditor build() {
    ref.listen(conexaoProvider, (_, estado) => _aoMudarConexao(estado));
    ref.onDispose(largarEnvioAoVivo);
    return const EstadoEditor();
  }

  @override
  RepositorioPedaleira? get repositorioAtual => ref.read(conexaoProvider.notifier).repositorio;

  Future<void> abrirSlot(SlotPreset slot) async {
    final repositorio = repositorioAtual;
    // gravando: o resultado da gravação ainda vai escrever o slot salvo
    if (repositorio == null || state.salvando) return;
    final abertura = ++_abertura;
    state = state.copiar(slot: slot, carregando: true, aviso: null);
    try {
      await _carregar(repositorio, slot, abertura);
    } finally {
      // nenhuma saída, nem erro inesperado, deixa a tela presa em "carregando"
      if (abertura == _abertura && state.carregando) state = state.copiar(carregando: false);
    }
  }

  Future<void> _carregar(RepositorioPedaleira repositorio, SlotPreset slot, int abertura) async {
    final leitura = await repositorio.lerPreset(slot);
    // outro slot foi aberto enquanto este carregava: este resultado já não vale
    if (abertura != _abertura) return;
    switch (leitura) {
      case Sucesso(valor: final DocumentoPreset lido) when !_bateComALista(slot, lido):
        _recusarPresetTrocado(slot);
      case Sucesso(:final valor):
        await _mostrar(slot, valor, abertura);
      case Falha(:final erro):
        // o slot mudou mas não foi lido: o preset anterior não pode ficar sob ele
        state = state.copiar(original: null, atual: null, carregando: false, aviso: erro.mensagem);
    }
  }

  Future<void> _mostrar(SlotPreset slot, DocumentoPreset? preset, int abertura) async {
    final trocou = await trocarSlotNaPedaleira(slot);
    // a troca por MIDI também leva tempo: se outro slot abriu nesse meio, ele vence
    if (abertura != _abertura) return;
    state = state.copiar(
      original: preset,
      atual: preset,
      selecionado: preset == null ? null : primeiraPosicao(preset),
      carregando: false,
      slotNaPedaleira: trocou,
    );
    if (preset == null) return;
    if (preset.versaoMaisNova) {
      state = state.copiar(aviso: 'Preset de formato mais novo que o deste app: campos desconhecidos são preservados.');
    }
    await enviarAoVivo(preset);
  }

  void _recusarPresetTrocado(SlotPreset slot) {
    state = state.copiar(original: null, atual: null, carregando: false,
        aviso: 'A pedaleira devolveu outro preset para ${slot.rotulo} (id diferente da lista). A lista foi relida; abra de novo.');
    unawaited(ref.read(bibliotecaProvider.notifier).recarregar());
  }

  /// O uuid lido tem de ser o que a lista de presets anunciou para o slot.
  bool _bateComALista(SlotPreset slot, DocumentoPreset lido) {
    final esperado = ref.read(bibliotecaProvider).resumo(slot)?.id;
    return esperado == null || esperado.isEmpty || esperado == lido.uuid;
  }

  /// Program Change: a pedaleira passa a ESTAR no slot (o try sozinho só toca).
  @override
  Future<bool> trocarSlotNaPedaleira(SlotPreset slot) async {
    final midi = ref.read(conexaoProvider.notifier).midi;
    if (midi == null) return false;
    try {
      await midi.enviar(MensagensMidi.trocaDePrograma(slot));
      return true;
    } on Exception catch (erro) {
      registro.w('editor: Program Change para ${slot.rotulo} falhou', error: erro);
      return false;
    }
  }

  void selecionarBloco(PosicaoBloco posicao) => state = state.copiar(selecionado: posicao);

  /// `arrastando`: ainda no gesto (envio com vazão limitada); ao soltar, final.
  /// `posicao`: o bloco do controle (o Desfazer pode chegar com outro selecionado).
  void alterarParametro(String simbolo, num valor,
      {required bool arrastando, String? nome, PosicaoBloco? posicao}) {
    final atual = state.atual;
    posicao ??= state.selecionado;
    if (atual == null || posicao == null) return;
    final editado = atual.comParametro(posicao, simbolo, valor, nomeExibicao: nome);
    state = state.copiar(atual: editado);
    if (!state.aoVivo) return;
    arrastando ? agendarAoVivo(editado) : unawaited(enviarAoVivo(editado));
  }

  void limparAviso() => state = state.copiar(aviso: null);

  @override
  Future<void> aplicarDocumento(DocumentoPreset documento) async {
    state = state.copiar(atual: documento);
    await enviarAoVivo(documento);
  }

  void _aoMudarConexao(EstadoConexao estado) {
    if (estado is Conectada) return;
    largarEnvioAoVivo();
    // sem pedaleira não há destino para gravar nem slot em que ela esteja
    state = state.copiar(escolhendoDestino: false, slotNaPedaleira: false);
    // o aviso de desconexão fica só na tela de conectar (não repetir a frase)
  }
}
