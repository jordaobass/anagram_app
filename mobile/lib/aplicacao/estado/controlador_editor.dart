// Editor no estilo HX Edit: abrir preset faz ele tocar; mexer em bloco,
// bypass ou cena soa na hora (se "Ao vivo" estiver ligado); gravar no
// slot é separado e só acontece com confirmação.
//
// Abrir fala com a pedaleira e leva de um a três segundos: cada passo
// confere, depois de cada espera, se o que ele ia mostrar ainda vale.
// A gravação fica em [GravacaoDoEditor]; o envio ao vivo, em [AoVivoDoEditor].
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../avisos.dart';
import '../provedores.dart';
import '../../dados/repositorio_pedaleira.dart';
import '../../nucleo/midi/saida_midi.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../../nucleo/modelo/documento_preset.dart';
import '../../nucleo/modelo/presets_fabrica.dart';
import '../../nucleo/modelo/slot_preset.dart';
import '../../nucleo/registro.dart';
import '../../nucleo/resultado.dart';
import 'ao_vivo_do_editor.dart';
import 'controlador_biblioteca.dart';
import 'controlador_conexao.dart';
import 'controles_do_editor.dart';
import 'edicao_do_preset.dart';
import 'estado_conexao.dart';
import 'estado_editor.dart';
import 'gravacao_do_editor.dart';
import 'limpeza_do_editor.dart';

final editorProvider = NotifierProvider<ControladorEditor, EstadoEditor>(ControladorEditor.new);

class ControladorEditor extends Notifier<EstadoEditor>
    with EdicaoDoPreset, ControlesDoEditor, AoVivoDoEditor, GravacaoDoEditor, LimpezaDoEditor {
  /// Cresce a cada abertura: o resultado de uma abertura vencida é descartado.
  int _abertura = 0;

  @override
  EstadoEditor build() {
    ref.listen(conexaoProvider, (_, estado) => _aoMudarConexao(estado));
    ref.listen<String?>(bibliotecaProvider.select((b) => b.areaSelecionada), _aoMudarArea);
    ref.onDispose(largarEnvioAoVivo);
    return const EstadoEditor();
  }

  @override
  RepositorioPedaleira? get repositorioAtual => ref.read(conexaoProvider.notifier).repositorio;

  @override
  Future<void> abrirSlot(SlotPreset slot) async {
    final repositorio = repositorioAtual;
    // gravando: o resultado da gravação ainda vai escrever o slot salvo
    if (repositorio == null || state.salvando) return;
    final abertura = ++_abertura;
    // o arraste do preset anterior não pode soar depois do Program Change deste
    descartarEnvioPendente();
    // o slot é desta área: se ela mudar depois, o "Salvar" pergunta o destino
    final area = ref.read(bibliotecaProvider).areaSelecionada;
    state = state.copiar(slot: slot, area: area, carregando: true, aviso: null);
    try {
      await _carregar(repositorio, slot, area, abertura);
    } finally {
      // nenhuma saída, nem erro inesperado, deixa a tela presa em "carregando"
      if (abertura == _abertura && state.carregando) state = state.copiar(carregando: false);
    }
  }

  /// Um preset importado (ou novo) vence a abertura que ainda estiver a
  /// caminho: sem isto, o slot lido por cima apagaria o importado.
  @override
  Future<void> carregarDocumento(DocumentoPreset documento) async {
    _abertura++;
    state = state.copiar(carregando: false);
    await super.carregarDocumento(documento);
  }

  Future<void> _carregar(RepositorioPedaleira repositorio, SlotPreset slot, String? area, int abertura) async {
    // a fábrica vem do arquivo do Suite: a pedaleira não a entrega (U18)
    final leitura = area == PresetsDeFabrica.idArea
        ? Sucesso((await ref.read(presetsFabricaProvider.future)).documento(slot))
        : await repositorio.lerPreset(slot, area: area);
    // outro slot foi aberto enquanto este carregava: este resultado já não vale
    if (abertura != _abertura) return;
    switch (leitura) {
      case Sucesso(valor: final DocumentoPreset lido) when !_bateComALista(slot, lido):
        await _conferirMudancaExterna(slot, lido, abertura);
      case Sucesso(:final valor):
        await _mostrar(slot, valor, abertura);
      case Falha(:final erro):
        // o slot mudou mas não foi lido: o preset anterior não pode ficar sob ele
        state = state.copiar(original: null, atual: null, carregando: false, aviso: AvisoErro(erro));
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
      state = state.copiar(aviso: const AvisoFormatoMaisNovo());
    }
    // com o slot trocado por Program Change, a pedaleira já tocou o preset
    // salvo; mandar também o "temporário" (try) fazia a tela dela mostrar
    // outro slot. Sem MIDI (ou em área não ativa), o temporário é a audição.
    if (!trocou) await enviarAoVivo(preset);
  }

  /// O slot pode ter mudado fora do app (outro programa gravou nele): relê a
  /// lista e, se ela agora anuncia o preset lido, abre a versão atual. Se a
  /// lista continuar com outro id, a pedaleira devolveu o preset errado.
  Future<void> _conferirMudancaExterna(SlotPreset slot, DocumentoPreset lido, int abertura) async {
    await ref.read(bibliotecaProvider.notifier).recarregar(relerAreas: false);
    if (abertura != _abertura) return;
    if (!_bateComALista(slot, lido)) return _recusarPresetTrocado(slot);
    await _mostrar(slot, lido, abertura);
    if (abertura == _abertura) state = state.copiar(aviso: AvisoPresetAtualizado(slot.rotulo));
  }

  void _recusarPresetTrocado(SlotPreset slot) {
    state = state.copiar(original: null, atual: null, carregando: false,
        aviso: AvisoPresetTrocado(slot.rotulo));
    unawaited(ref.read(bibliotecaProvider.notifier).recarregar());
  }

  /// O uuid lido tem de ser o que a lista de presets anunciou para o slot.
  bool _bateComALista(SlotPreset slot, DocumentoPreset lido) {
    final esperado = ref.read(bibliotecaProvider).resumo(slot)?.id;
    return esperado == null || esperado.isEmpty || esperado == lido.uuid;
  }

  /// Program Change: a pedaleira passa a ESTAR no slot (o try sozinho só toca).
  /// O Program Change vale na área ATIVA da pedaleira: com outra área na tela
  /// (ou sem saber qual está ativa), ele levaria a pedaleira ao mesmo número
  /// na área errada, então não sai. A ativa é relida antes, porque a pessoa
  /// pode ter trocado de área na própria pedaleira.
  @override
  Future<bool> trocarSlotNaPedaleira(SlotPreset slot) async {
    final midi = ref.read(conexaoProvider.notifier).midi;
    if (midi == null) return false;
    if (!await ref.read(bibliotecaProvider.notifier).areaDaTelaEstaAtiva()) return false;
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

  void _aoMudarArea(String? antes, String? depois) {
    // aberto antes de as áreas chegarem: foi lido sem `userArea`, isto é, da
    // área ativa da pedaleira — que é a primeira a aparecer na tela
    final semArea = state.slot != null && state.area == null;
    if (antes == null && semArea && depois != null && depois == ref.read(bibliotecaProvider).areas.ativa) {
      state = state.copiar(area: depois);
      return;
    }
    // só troca entre duas áreas: desconectar zera a área, e a edição não
    // salva tem de sobreviver ao cabo que saiu
    if (antes != null && depois != null && antes != depois) _soltarDoSlot();
  }

  /// Um preset de backup (DECISOES BK6): abre como o importado, mas sem slot,
  /// para nenhum "Salvar" o pôr de volta sem passar pelo "Salvar como".
  Future<void> abrirSemSlot(DocumentoPreset documento) async {
    _soltarDoSlot();
    await carregarDocumento(documento);
  }

  /// Outra área na tela: o preset aberto era de um slot da área anterior e não
  /// pode continuar sob o mesmo rótulo. Ele fica na tela sem slot, como um
  /// importado: o "Salvar" vira "Salvar como" e pergunta o destino na área
  /// nova (é assim que se copia um preset de uma área para outra).
  void _soltarDoSlot() {
    _abertura++;
    state = state.copiar(slot: null, area: null, original: null, carregando: false, slotNaPedaleira: false);
  }

  /// Presets mudaram de lugar na pedaleira (mover, trocar, trocar bancos): o
  /// aberto acompanha o preset, não o slot. A pedaleira pode continuar tocando
  /// o slot antigo, então a marca "na pedaleira" sai até o próximo Program Change.
  void acompanharTroca(Map<SlotPreset, SlotPreset> novoLugar, {required String? area}) {
    final slot = state.slot;
    final destino = slot == null ? null : novoLugar[slot];
    if (destino == null || state.area != area) return;
    state = state.copiar(slot: destino, slotNaPedaleira: false);
  }

  void _aoMudarConexao(EstadoConexao estado) {
    if (estado is Conectada) return;
    largarEnvioAoVivo();
    // sem pedaleira não há destino para gravar nem slot em que ela esteja
    state = state.copiar(escolhendoDestino: false, slotNaPedaleira: false);
    // o aviso de desconexão fica só na tela de conectar (não repetir a frase)
  }
}
