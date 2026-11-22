// Salvar (no slot aberto) e Salvar como (destino escolhido na lista de
// presets). Só pergunta quando o destino está ocupado e não é a origem, ou
// quando a origem mudou na pedaleira desde que foi aberta.
// Com a fábrica na tela, o destino começa pela área (fluxo_copiar_fabrica).
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/casos_de_uso/salvar_no_slot.dart';
import '../../aplicacao/estado/controlador_biblioteca.dart';
import '../../aplicacao/estado/controlador_editor.dart';
import '../../nucleo/modelo/slot_preset.dart';
import '../rotas.dart';
import 'dialogo_confirmar.dart';
import 'fluxo_copiar_fabrica.dart';
import 'fluxo_recarregar.dart';
import '../../l10n/app_localizations.dart';
import '../textos.dart';

Future<void> executarSalvar(BuildContext context, WidgetRef ref, {bool listaEmOutraTela = false}) async {
  final mensageiro = ScaffoldMessenger.of(context);
  final l = AppLocalizations.of(context);
  final controlador = ref.read(editorProvider.notifier);
  final resultado = await controlador.salvar();
  if (resultado == null) {
    if (context.mounted) abrirEscolhaDeDestino(context, ref, listaEmOutraTela: listaEmOutraTela);
    return;
  }
  if (resultado case SlotOcupado(:final slot, :final nomeAtual)) {
    // preset importado sobre um slot ocupado: confirma antes
    if (!context.mounted || !await _confirmarSubstituicao(context, slot, nomeAtual)) return;
    _avisar(mensageiro, l, await controlador.salvarComo(slot, confirmado: true));
    return;
  }
  if (resultado case SlotAlteradoFora(:final slot)) {
    if (!context.mounted) return;
    await _decidirSlotAlterado(context, ref, slot, () => controlador.salvar(mesmoAlteradoFora: true));
    return;
  }
  _avisar(mensageiro, l, resultado);
}

/// A origem mudou por fora: só grava se a pessoa mandar sobrescrever.
Future<ResultadoSalvar?> _decidirSlotAlterado(
    BuildContext context, WidgetRef ref, SlotPreset slot, Future<ResultadoSalvar?> Function() sobrescrever) async {
  final mensageiro = ScaffoldMessenger.of(context);
  final l = AppLocalizations.of(context);
  switch (await perguntarSlotAlterado(context, slot)) {
    case DecisaoSlotAlterado.sobrescrever:
      final resultado = await sobrescrever();
      if (resultado != null) _avisar(mensageiro, l, resultado);
      return resultado;
    case DecisaoSlotAlterado.recarregar:
      if (context.mounted) await executarRecarregar(context, ref);
    case DecisaoSlotAlterado.cancelar:
  }
  return null;
}

/// Põe a lista em modo "escolher destino"; no celular a lista é outra tela.
/// Na fábrica não há destino: pergunta antes para qual área copiar.
void abrirEscolhaDeDestino(BuildContext context, WidgetRef ref, {bool listaEmOutraTela = false}) {
  if (ref.read(bibliotecaProvider).naFabrica) {
    unawaited(copiarParaMinhaArea(context, ref, listaEmOutraTela: listaEmOutraTela));
    return;
  }
  ref.read(editorProvider.notifier).iniciarSalvarComo();
  if (listaEmOutraTela) const RotaPresets().push<void>(context);
}

/// Chamado pela lista quando o destino é tocado. Devolve se gravou.
Future<bool> salvarComoNoDestino(BuildContext context, WidgetRef ref, SlotPreset slot) async {
  final mensageiro = ScaffoldMessenger.of(context);
  final l = AppLocalizations.of(context);
  final controlador = ref.read(editorProvider.notifier);
  var resultado = await controlador.salvarComo(slot);
  if (resultado case SlotOcupado(:final nomeAtual)) {
    if (!context.mounted) return false;
    if (!await _confirmarSubstituicao(context, slot, nomeAtual)) return false;
    resultado = await controlador.salvarComo(slot, confirmado: true);
  }
  if (resultado is SlotAlteradoFora) {
    if (!context.mounted) return false;
    final decidido = await _decidirSlotAlterado(context, ref, slot, () => controlador.salvarComo(slot, confirmado: true));
    return decidido is PresetSalvo;
  }
  _avisar(mensageiro, l, resultado);
  return resultado is PresetSalvo;
}

void _avisar(ScaffoldMessengerState mensageiro, AppLocalizations l, ResultadoSalvar resultado) {
  final texto = switch (resultado) {
    PresetSalvo(:final relido, :final slot) => l.presetSalvoEm(relido.nome, slot.rotulo),
    final FalhaAoSalvar falha => l.falhaAoSalvar(falha),
    SlotOcupado() || SlotAlteradoFora() => null,
  };
  if (texto != null) mensageiro.showSnackBar(SnackBar(content: Text(texto)));
}

Future<bool> _confirmarSubstituicao(BuildContext context, SlotPreset slot, String nomeAtual) {
  final l = AppLocalizations.of(context);
  return confirmar(
    context,
    titulo: l.substituirTitulo(slot.rotulo),
    texto: l.substituirTexto(slot.rotulo, nomeAtual),
    rotuloCancelar: l.cancelar,
    rotuloConfirmar: l.substituir,
    chaveConfirmar: const ValueKey('confirmar-substituicao'),
  );
}
