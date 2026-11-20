// Seletor de área de presets (firmware 1.18+), no topo da lista: os nomes
// que a pessoa deu na pedaleira ("Padrão", "Estudo", "User2"…). Só aparece
// quando a pedaleira tem áreas. Trocar de área com edição não salva pergunta
// antes, porque o preset aberto é fechado.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_biblioteca.dart';
import '../../aplicacao/estado/controlador_editor.dart';
import '../tema/tokens.dart';
import 'dialogo_confirmar.dart';
import '../../l10n/app_localizations.dart';
import '../textos.dart';

class SeletorArea extends ConsumerWidget {
  const SeletorArea({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biblioteca = ref.watch(bibliotecaProvider);
    if (!biblioteca.areas.temAreas) return const SizedBox.shrink();
    final ocupado = ref.watch(editorProvider.select((e) => e.ocupado));
    return Padding(
      padding: const EdgeInsets.fromLTRB(Espacos.m, Espacos.s, Espacos.m, Espacos.xs),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _escolha(context, ref, biblioteca, habilitado: !ocupado),
        if (biblioteca.areaForaDaPedaleira) const _AvisoAreaInativa(),
      ]),
    );
  }

  Widget _escolha(BuildContext context, WidgetRef ref, EstadoBiblioteca biblioteca, {required bool habilitado}) =>
      Row(children: [
        Text(AppLocalizations.of(context).area, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Cores.textoSecundario)),
        const SizedBox(width: Espacos.s),
        Expanded(child: _lista(context, ref, biblioteca, habilitado: habilitado)),
      ]);

  Widget _lista(BuildContext context, WidgetRef ref, EstadoBiblioteca biblioteca, {required bool habilitado}) {
    final l = AppLocalizations.of(context);
    return DropdownButton<String>(
        key: const ValueKey('seletor-area'),
        value: biblioteca.areaSelecionada,
        isExpanded: true,
        items: [
          for (final area in biblioteca.areas.areas)
            DropdownMenuItem(
              key: ValueKey('area-${area.id}'),
              value: area.id,
              child: Text(
                  area.id == biblioteca.areas.ativa ? l.areaAtivaNaPedaleira(l.nomeDaArea(area)) : l.nomeDaArea(area),
                  overflow: TextOverflow.ellipsis),
            ),
        ],
        onChanged: habilitado ? (id) => _trocar(context, ref, id) : null,
      );
  }

  Future<void> _trocar(BuildContext context, WidgetRef ref, String? id) async {
    if (id == null) return;
    final editor = ref.read(editorProvider);
    if (editor.naoSalvo) {
      final l = AppLocalizations.of(context);
      final largar = await confirmar(
        context,
        titulo: l.largarEdicoesTitulo,
        texto: l.largarAoTrocarArea(editor.atual?.nome ?? ''),
        rotuloCancelar: l.continuarEditando,
        rotuloConfirmar: l.largar,
      );
      if (!largar) return;
    }
    await ref.read(bibliotecaProvider.notifier).selecionarArea(id);
  }
}

/// A área na tela não é a que a pedaleira está usando: abrir um preset só o
/// toca (o Program Change trocaria o slot de OUTRA área). "Tornar ativa"
/// passa a pedaleira para esta área.
class _AvisoAreaInativa extends ConsumerWidget {
  const _AvisoAreaInativa();

  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
        padding: const EdgeInsets.only(top: Espacos.xs),
        child: Row(children: [
          Expanded(
            child: Text(
              AppLocalizations.of(context).areaInativa,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Cores.textoSecundario),
            ),
          ),
          TextButton(
            key: const ValueKey('tornar-area-ativa'),
            onPressed: ref.read(bibliotecaProvider.notifier).tornarSelecionadaAtiva,
            child: Text(AppLocalizations.of(context).tornarAtiva),
          ),
        ]),
      );
}
