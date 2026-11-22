// O slot aberto mudou na pedaleira por fora (no próprio aparelho ou pelo
// Suite): o Salvar não grava sem a pessoa decidir. Recarregar descarta as
// edições, então pergunta antes quando há o que perder.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../../l10n/app_localizations.dart';
import '../../nucleo/modelo/slot_preset.dart';
import '../tema/tokens.dart';
import 'dialogo_confirmar.dart';

enum DecisaoSlotAlterado { sobrescrever, recarregar, cancelar }

/// Pergunta o que fazer com o slot que mudou por fora. Fechar sem escolher vale cancelar.
Future<DecisaoSlotAlterado> perguntarSlotAlterado(BuildContext context, SlotPreset slot) async {
  final l = AppLocalizations.of(context);
  final resposta = await showDialog<DecisaoSlotAlterado>(
    context: context,
    builder: (contexto) {
      void escolher(DecisaoSlotAlterado decisao) => Navigator.pop(contexto, decisao);
      return AlertDialog(
        title: Text(l.slotAlteradoForaTitulo(slot.rotulo)),
        content: Text(l.slotAlteradoForaTexto(slot.rotulo)),
        actionsOverflowButtonSpacing: Espacos.s,
        actions: [
          BotaoCancelarDialogo(rotulo: l.cancelar, aoTocar: () => escolher(DecisaoSlotAlterado.cancelar)),
          OutlinedButton(
            key: const ValueKey('recarregar-slot-alterado'),
            onPressed: () => escolher(DecisaoSlotAlterado.recarregar),
            child: Text(l.recarregarDaPedaleira),
          ),
          BotaoConfirmarPerda(
            key: const ValueKey('sobrescrever-slot-alterado'),
            rotulo: l.sobrescreverMesmoAssim,
            aoTocar: () => escolher(DecisaoSlotAlterado.sobrescrever),
          ),
        ],
      );
    },
  );
  return resposta ?? DecisaoSlotAlterado.cancelar;
}

/// Menu do preset, Ctrl/Cmd+R e o diálogo do slot alterado: relê o slot
/// aberto; com edição não salva, confirma antes de descartá-la.
Future<void> executarRecarregar(BuildContext context, WidgetRef ref) async {
  final estado = ref.read(editorProvider);
  final slot = estado.slot;
  if (slot == null || estado.ocupado) return;
  if (estado.naoSalvo && !await _confirmarRecarregar(context, slot, estado.atual?.nome ?? '')) return;
  await ref.read(editorProvider.notifier).recarregarDaPedaleira();
}

Future<bool> _confirmarRecarregar(BuildContext context, SlotPreset slot, String nome) {
  if (!context.mounted) return Future.value(false);
  final l = AppLocalizations.of(context);
  return confirmar(
    context,
    titulo: l.recarregarTitulo(slot.rotulo),
    texto: l.recarregarTexto(nome),
    rotuloCancelar: l.cancelar,
    rotuloConfirmar: l.recarregar,
    chaveConfirmar: const ValueKey('confirmar-recarregar'),
  );
}
