// Gravar no slot: Salvar (no slot aberto) e Salvar como (destino escolhido).
// Enquanto grava, o estado fica "salvando" e abrir outro slot é recusado até
// ela terminar: o resultado da gravação ainda vai escrever o slot salvo.
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../nucleo/modelo/documento_preset.dart';
import '../../nucleo/modelo/slot_preset.dart';
import '../../nucleo/protocolo/erros_anagram.dart';
import '../casos_de_uso/salvar_no_slot.dart';
import 'ao_vivo_do_editor.dart';
import 'controlador_biblioteca.dart';
import 'estado_editor.dart';

mixin GravacaoDoEditor on Notifier<EstadoEditor>, AoVivoDoEditor {
  /// Program Change para o slot; devolve se a pedaleira passou a estar nele.
  @protected
  Future<bool> trocarSlotNaPedaleira(SlotPreset slot);

  /// Salvar (Cmd+S): grava no slot aberto, sem perguntar — é a origem.
  /// Sem slot (preset importado), cai no "Salvar como".
  Future<ResultadoSalvar?> salvar() async {
    if (_motivoParaNaoGravar() case final recusa?) return recusa;
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
    if (_motivoParaNaoGravar() case final recusa?) return recusa;
    final resultado = await _gravar(slot, confirmado: confirmado || slot == state.slot);
    if (resultado is! SlotOcupado) state = state.copiar(escolhendoDestino: false);
    return resultado;
  }

  /// Enquanto um preset carrega, o aberto ainda é o anterior: gravar agora
  /// poria o preset errado no slot novo (o Cmd+S não passa pelo botão). E
  /// duas gravações ao mesmo tempo disputariam o mesmo slot.
  FalhaAoSalvar? _motivoParaNaoGravar() {
    if (state.carregando) {
      return const FalhaAoSalvar(ErroOperacaoEmCurso('Espere o preset terminar de carregar para salvar.'));
    }
    if (state.salvando) return const FalhaAoSalvar(ErroOperacaoEmCurso('Espere a gravação em curso terminar.'));
    return null;
  }

  /// A lista de presets passa a escolher o destino em vez de abrir.
  void iniciarSalvarComo() => state = state.copiar(escolhendoDestino: true);

  void cancelarSalvarComo() => state = state.copiar(escolhendoDestino: false);

  Future<ResultadoSalvar> _gravar(SlotPreset slot, {required bool confirmado}) async {
    final repositorio = repositorioAtual;
    final atual = state.atual;
    if (repositorio == null || atual == null) {
      return const FalhaAoSalvar(ErroDesconectado('Conecte a pedaleira para salvar.'));
    }
    // mesmo slot e mesmo preset mantém o uuid; outro slot ou importado ganha novo
    final mesmoPreset = slot == state.slot && state.original != null;
    final documento = mesmoPreset ? atual : atual.comUuid(novoUuidPreset());
    state = state.copiar(salvando: true);
    try {
      final resultado =
          await SalvarNoSlot(repositorio).executar(slot, documento, sobrescreverConfirmado: confirmado);
      if (resultado case PresetSalvo(:final relido)) await _aplicarSalvo(slot, relido, gravado: atual);
      return resultado;
    } finally {
      state = state.copiar(salvando: false);
    }
  }

  /// [gravado] é o documento que estava aberto quando a gravação começou. Se a
  /// pessoa editou nesse meio-tempo (knob, bypass, nome), a edição fica na
  /// tela, já com o uuid do que foi salvo, e o preset volta a "não salvo".
  Future<void> _aplicarSalvo(SlotPreset slot, DocumentoPreset relido, {required DocumentoPreset gravado}) async {
    // gravou em outro slot: a pedaleira vai junto para ele
    final mudou = slot != state.slot;
    final editadoDurante = state.atual;
    final uuidSalvo = relido.uuid;
    final atual = switch (editadoDurante) {
      null => relido,
      _ when identical(editadoDurante, gravado) => relido,
      _ => uuidSalvo == null ? editadoDurante : editadoDurante.comUuid(uuidSalvo),
    };
    state = state.copiar(slot: slot, original: relido, atual: atual);
    if (mudou) state = state.copiar(slotNaPedaleira: await trocarSlotNaPedaleira(slot));
    ref.read(bibliotecaProvider.notifier).registrarSalvo(slot, relido.nome, id: relido.uuid);
  }
}
