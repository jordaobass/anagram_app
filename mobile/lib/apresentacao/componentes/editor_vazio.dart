// Conectado e sem preset aberto: ou nada foi escolhido ainda, ou o slot
// escolhido está vazio (aí dá para criar um preset nele).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../tema/tokens.dart';

class EditorVazio extends ConsumerWidget {
  const EditorVazio({super.key, this.aoAbrirLista});

  final VoidCallback? aoAbrirLista;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context).textTheme;
    final slot = ref.watch(editorProvider.select((e) => e.slot));
    final titulo = slot == null ? 'Escolha um preset' : 'O slot ${slot.rotulo} está vazio';
    final texto = slot == null
        ? 'Ao abrir, ele passa a tocar na pedaleira. As mudanças soam na hora e só ficam gravadas quando você salva.'
        : 'Crie um preset aqui e cole blocos copiados de outro preset (toque longo numa casa).';
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
            _botoes(ref, slotVazio: slot != null),
          ]),
        ),
      ),
    );
  }

  Widget _botoes(WidgetRef ref, {required bool slotVazio}) => Wrap(spacing: Espacos.s, runSpacing: Espacos.s, children: [
        if (slotVazio)
          FilledButton(
            key: const ValueKey('botao-novo-preset'),
            onPressed: ref.read(editorProvider.notifier).novoPresetNoSlot,
            child: const Text('CRIAR PRESET AQUI'),
          ),
        if (aoAbrirLista != null) OutlinedButton(onPressed: aoAbrirLista, child: const Text('VER PRESETS')),
      ]);
}
