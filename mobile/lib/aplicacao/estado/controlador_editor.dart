// Editor no estilo HX Edit: abrir preset faz ele tocar; mexer em bloco,
// bypass ou cena soa na hora (se "Ao vivo" estiver ligado); gravar no
// slot é separado e só acontece com confirmação.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dados/repositorio_pedaleira.dart';
import '../../nucleo/midi/saida_midi.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../../nucleo/registro.dart';
import '../../nucleo/modelo/documento_preset.dart';
import '../../nucleo/modelo/slot_preset.dart';
import '../../nucleo/protocolo/api_anagram.dart';
import '../../nucleo/protocolo/erros_anagram.dart';
import '../../nucleo/resultado.dart';
import '../casos_de_uso/salvar_no_slot.dart';
import '../envio_ao_vivo.dart';
import 'controlador_biblioteca.dart';
import 'controlador_conexao.dart';
import 'edicao_do_preset.dart';
import 'estado_conexao.dart';
import 'estado_editor.dart';

final editorProvider = NotifierProvider<ControladorEditor, EstadoEditor>(ControladorEditor.new);

class ControladorEditor extends Notifier<EstadoEditor> with EdicaoDoPreset {
  EnvioAoVivo? _envio;
  StreamSubscription<Object?>? _medicoes;

  @override
  EstadoEditor build() {
    ref.listen(conexaoProvider, (_, estado) => _aoMudarConexao(estado));
    ref.onDispose(_largarRepositorio);
    return const EstadoEditor();
  }

  RepositorioPedaleira? get _repositorio => ref.read(conexaoProvider.notifier).repositorio;

  Future<void> abrirSlot(SlotPreset slot) async {
    final repositorio = _repositorio;
    if (repositorio == null) return;
    state = state.copiar(slot: slot, carregando: true, aviso: null);
    final leitura = await repositorio.lerPreset(slot);
    // outro slot foi aberto enquanto este carregava: este resultado já não vale
    if (state.slot != slot) return;
    if (leitura case Sucesso(valor: final DocumentoPreset lido) when !_bateComALista(slot, lido)) {
      state = state.copiar(original: null, atual: null, carregando: false,
          aviso: 'A pedaleira devolveu outro preset para ${slot.rotulo} (id diferente da lista). A lista foi relida; abra de novo.');
      unawaited(ref.read(bibliotecaProvider.notifier).recarregar());
      return;
    }
    switch (leitura) {
      case Sucesso(:final valor):
        final primeiro = valor == null ? null : primeiraPosicao(valor);
        final trocou = await _trocarSlotNaPedaleira(slot);
        state = state.copiar(
            original: valor, atual: valor, selecionado: primeiro, carregando: false, slotNaPedaleira: trocou);
        if (valor != null && valor.versaoMaisNova) {
          state = state.copiar(aviso: 'Preset de formato mais novo que o deste app: campos desconhecidos são preservados.');
        }
        if (valor != null) await _enviarAgora(valor);
      case Falha(:final erro):
        // o slot mudou mas não foi lido: o preset anterior não pode ficar sob ele
        state = state.copiar(original: null, atual: null, carregando: false, aviso: erro.mensagem);
    }
  }

  /// O uuid lido tem de ser o que a lista de presets anunciou para o slot.
  bool _bateComALista(SlotPreset slot, DocumentoPreset lido) {
    final esperado = ref.read(bibliotecaProvider).resumo(slot)?.id;
    return esperado == null || esperado.isEmpty || esperado == lido.uuid;
  }

  /// Program Change: a pedaleira passa a ESTAR no slot (o try sozinho só toca).
  Future<bool> _trocarSlotNaPedaleira(SlotPreset slot) async {
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
    arrastando ? _envioAtivo()?.agendar(editado) : unawaited(_enviarAgora(editado));
  }

  Future<void> definirAoVivo(bool ligado) async {
    state = state.copiar(aoVivo: ligado);
    final atual = state.atual;
    if (ligado && atual != null) await _enviarAgora(atual);
  }

  /// Salvar (Cmd+S): grava no slot aberto, sem perguntar — é a origem.
  /// Sem slot (preset importado), cai no "Salvar como".
  Future<ResultadoSalvar?> salvar() async {
    if (state.carregando) return _carregandoAinda;
    final slot = state.slot;
    if (slot == null) {
      iniciarSalvarComo();
      return null;
    }
    // importado (sem original) não é o que está no slot: pergunta antes
    return _gravar(slot, confirmado: state.original != null);
  }

  /// Salvar como: slot ocupado e diferente da origem volta [SlotOcupado] até
  /// vir a confirmação. Em outro slot o preset ganha uuid novo.
  Future<ResultadoSalvar> salvarComo(SlotPreset slot, {bool confirmado = false}) async {
    if (state.carregando) return _carregandoAinda;
    final resultado = await _gravar(slot, confirmado: confirmado || slot == state.slot);
    if (resultado is! SlotOcupado) state = state.copiar(escolhendoDestino: false);
    return resultado;
  }

  /// Enquanto um preset carrega, o aberto ainda é o anterior: gravar agora
  /// poria o preset errado no slot novo (o Cmd+S não passa pelo botão).
  static const _carregandoAinda =
      FalhaAoSalvar(ErroOperacaoEmCurso('Espere o preset terminar de carregar para salvar.'));

  /// A lista de presets passa a escolher o destino em vez de abrir.
  void iniciarSalvarComo() => state = state.copiar(escolhendoDestino: true);

  void cancelarSalvarComo() => state = state.copiar(escolhendoDestino: false);

  Future<ResultadoSalvar> _gravar(SlotPreset slot, {required bool confirmado}) async {
    final repositorio = _repositorio;
    final atual = state.atual;
    if (repositorio == null || atual == null) {
      return const FalhaAoSalvar(ErroDesconectado('Conecte a pedaleira para salvar.'));
    }
    // mesmo slot e mesmo preset mantém o uuid; outro slot ou importado ganha novo
    final mesmoPreset = slot == state.slot && state.original != null;
    final documento = mesmoPreset ? atual : atual.comUuid(novoUuidPreset());
    final resultado =
        await SalvarNoSlot(repositorio).executar(slot, documento, sobrescreverConfirmado: confirmado);
    if (resultado case PresetSalvo(:final relido)) {
      // gravou em outro slot: a pedaleira vai junto para ele
      final mudou = slot != state.slot;
      state = state.copiar(slot: slot, original: relido, atual: relido);
      if (mudou) state = state.copiar(slotNaPedaleira: await _trocarSlotNaPedaleira(slot));
      ref.read(bibliotecaProvider.notifier).registrarSalvo(slot, relido.nome, id: relido.uuid);
    }
    return resultado;
  }

  void limparAviso() => state = state.copiar(aviso: null);

  @override
  Future<void> aplicarDocumento(DocumentoPreset documento) async {
    state = state.copiar(atual: documento);
    if (state.aoVivo) await _enviarAgora(documento);
  }

  Future<void> _enviarAgora(DocumentoPreset documento) async {
    if (!state.aoVivo) return;
    await _envioAtivo()?.enviarAgora(documento);
  }

  EnvioAoVivo? _envioAtivo() {
    final repositorio = _repositorio;
    if (repositorio == null) return null;
    return _envio ??= _criarEnvio(repositorio);
  }

  EnvioAoVivo _criarEnvio(RepositorioPedaleira repositorio) {
    _medicoes = repositorio.medicoes
        .where((m) => m.acao == AcoesAnagram.tocarAoVivo)
        .listen((m) => state = state.copiar(latencia: m.duracao));
    return EnvioAoVivo((documento) async {
      final envio = await repositorio.tocarAoVivo(documento);
      if (envio case Falha(:final erro)) state = state.copiar(aviso: erro.mensagem);
    });
  }

  void _aoMudarConexao(EstadoConexao estado) {
    if (estado is Conectada) return;
    _largarRepositorio();
    // sem pedaleira não há destino para gravar nem slot em que ela esteja
    state = state.copiar(escolhendoDestino: false, slotNaPedaleira: false);
    // o aviso de desconexão fica só na tela de conectar (não repetir a frase)
  }

  void _largarRepositorio() {
    _envio?.cancelar();
    _envio = null;
    unawaited(_medicoes?.cancel());
    _medicoes = null;
  }

}
