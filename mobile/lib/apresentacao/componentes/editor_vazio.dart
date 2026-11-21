// Conectado e sem preset aberto: ou nada foi escolhido ainda, ou o slot
// escolhido está vazio (aí dá para criar um preset nele).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../tema/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../textos.dart';
import 'casa_arrastavel.dart' show arrastoComMouse;

class EditorVazio extends ConsumerWidget {
  const EditorVazio({super.key, this.aoAbrirLista});

  final VoidCallback? aoAbrirLista;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context).textTheme;
    final slot = ref.watch(editorProvider.select((e) => e.slot));
    final l = AppLocalizations.of(context);
    final titulo = slot == null ? l.escolhaUmPreset : l.slotEstaVazio(slot.rotulo);
    final texto = slot == null ? l.escolhaUmPresetTexto : l.slotVazioTextoPara(mouse: arrastoComMouse);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Medidas.larguraConteudoVazio),
        child: Padding(
          padding: const EdgeInsets.all(Espacos.xl),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(titulo, style: tema.titleLarge),
            const SizedBox(height: Espacos.s),
            Text(texto, style: tema.bodyMedium),
            const SizedBox(height: Espacos.l),
            _botoes(ref, l, slotVazio: slot != null),
          ]),
        ),
      ),
    );
  }

  Widget _botoes(WidgetRef ref, AppLocalizations l, {required bool slotVazio}) => Wrap(spacing: Espacos.s, runSpacing: Espacos.s, children: [
        if (slotVazio)
          FilledButton(
            key: const ValueKey('botao-novo-preset'),
            onPressed: ref.read(editorProvider.notifier).novoPresetNoSlot,
            child: Text(l.criarPresetAqui),
          ),
        if (aoAbrirLista != null) OutlinedButton(onPressed: aoAbrirLista, child: Text(l.verPresets)),
      ]);
}
