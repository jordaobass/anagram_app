// "Copiar para a minha área…" de um preset de fábrica (U18): primeiro a área,
// depois o slot. Escolhida a área, a lista passa a mostrá-la e o resto é o
// "Salvar como" de sempre (pergunta se o slot estiver ocupado, uuid novo):
// é ali que a pessoa vê o slot onde a cópia vai ficar.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_biblioteca.dart';
import '../../aplicacao/estado/controlador_editor.dart';
import '../../l10n/app_localizations.dart';
import '../../nucleo/modelo/areas_presets.dart';
import '../../nucleo/modelo/presets_fabrica.dart';
import '../../nucleo/modelo/slot_preset.dart';
import '../textos.dart';
import 'dialogo_confirmar.dart';
import 'fluxo_salvar.dart';

Future<void> copiarParaMinhaArea(BuildContext context, WidgetRef ref, {bool listaEmOutraTela = false}) async {
  final area = await _escolherArea(context, ref.read(bibliotecaProvider).areas);
  if (area == null || !context.mounted) return;
  // trocar de área solta o preset do slot da fábrica: ele fica na tela como cópia não salva
  await ref.read(bibliotecaProvider.notifier).selecionarArea(area);
  if (context.mounted) abrirEscolhaDeDestino(context, ref, listaEmOutraTela: listaEmOutraTela);
}

/// Pelo menu da lista da fábrica: abre o preset (se ainda não for o aberto) e copia.
Future<void> copiarDaFabrica(BuildContext context, WidgetRef ref, SlotPreset slot) async {
  final editor = ref.read(editorProvider);
  if (editor.slot != slot || editor.area != PresetsDeFabrica.idArea) {
    if (editor.naoSalvo && !await confirmarLargarEdicoes(context, editor.atual?.nome ?? '')) return;
    if (!context.mounted) return;
    await ref.read(editorProvider.notifier).abrirSlot(slot);
  }
  if (context.mounted) await copiarParaMinhaArea(context, ref);
}

/// Com uma área só, não há o que perguntar.
Future<String?> _escolherArea(BuildContext context, AreasDaPedaleira areas) async {
  if (areas.areas.length == 1) return areas.areas.single.id;
  final l = AppLocalizations.of(context);
  return showDialog<String>(
    context: context,
    builder: (contexto) => SimpleDialog(
      title: Text(l.fbCopiarTitulo),
      children: [
        for (final area in areas.areas)
          SimpleDialogOption(
            key: ValueKey('copiar-para-${area.id}'),
            onPressed: () => Navigator.pop(contexto, area.id),
            child: Text(area.id == areas.ativa ? '${l.nomeDaArea(area)} · ${l.txAtiva}' : l.nomeDaArea(area)),
          ),
      ],
    ),
  );
}
