// Seletor de área de presets (firmware 1.18+), no topo da lista: os nomes
// que a pessoa deu na pedaleira ("Padrão", "Estudo", "User2"…). Só aparece
// quando a pedaleira tem áreas. Trocar de área com edição não salva pergunta
// antes, porque o preset aberto é fechado.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_biblioteca.dart';
import '../../aplicacao/estado/controlador_editor.dart';
import '../../nucleo/modelo/areas_presets.dart';
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
        Text(AppLocalizations.of(context).area,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Cores.textoSecundario)),
        const SizedBox(width: Espacos.s),
        Expanded(child: _lista(context, ref, biblioteca, habilitado: habilitado)),
        // a marca de ativa fica fora do nome: o nome nunca é cortado por ela
        if (biblioteca.areaSelecionada == biblioteca.areas.ativa) ...[
          const SizedBox(width: Espacos.s),
          const _EtiquetaAtiva(),
        ],
      ]);

  Widget _lista(BuildContext context, WidgetRef ref, EstadoBiblioteca biblioteca, {required bool habilitado}) {
    final l = AppLocalizations.of(context);
    final areas = biblioteca.areas.areas;
    return DropdownButton<String>(
      key: const ValueKey('seletor-area'),
      value: biblioteca.areaSelecionada,
      isExpanded: true,
      selectedItemBuilder: (_) => [
        for (final area in areas) Align(alignment: Alignment.centerLeft, child: _nome(l, area)),
      ],
      items: [
        for (final area in areas)
          DropdownMenuItem(
            key: ValueKey('area-${area.id}'),
            value: area.id,
            child: Row(children: [
              Expanded(child: _nome(l, area)),
              if (area.id == biblioteca.areas.ativa) const _EtiquetaAtiva(),
            ]),
          ),
      ],
      onChanged: habilitado ? (id) => _trocar(context, ref, id) : null,
    );
  }

  static Widget _nome(AppLocalizations l, AreaPresets area) =>
      Text(l.nomeDaArea(area), maxLines: 1, overflow: TextOverflow.ellipsis);

  Future<void> _trocar(BuildContext context, WidgetRef ref, String? id) async {
    if (id == null) return;
    final editor = ref.read(editorProvider);
    if (editor.naoSalvo) {
      final l = AppLocalizations.of(context);
      final descartar = await confirmar(
        context,
        titulo: l.largarEdicoesTitulo,
        texto: l.largarAoTrocarArea(editor.atual?.nome ?? ''),
        rotuloCancelar: l.continuarEditando,
        rotuloConfirmar: l.largar,
      );
      if (!descartar) return;
    }
    await ref.read(bibliotecaProvider.notifier).selecionarArea(id);
  }
}

/// A área na tela não é a que a pedaleira está usando: abrir um preset só o
/// toca (o Program Change trocaria o slot de OUTRA área). "Tornar ativa"
/// passa a pedaleira para esta área.
class _AvisoAreaInativa extends ConsumerWidget {
  const _AvisoAreaInativa();

  // o botão embaixo do texto: lado a lado, no painel estreito da lista, o
  // texto virava uma coluna de palavras e a lista ficava com dois slots à vista
  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
        padding: const EdgeInsets.only(top: Espacos.xs),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(
            AppLocalizations.of(context).areaInativa,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Cores.textoSecundario),
          ),
          TextButton(
            key: const ValueKey('tornar-area-ativa'),
            onPressed: ref.read(bibliotecaProvider.notifier).tornarSelecionadaAtiva,
            child: Text(AppLocalizations.of(context).tornarAtiva),
          ),
        ]),
      );
}

/// LED verde + "ATIVA": a área que a pedaleira está usando agora.
class _EtiquetaAtiva extends StatelessWidget {
  const _EtiquetaAtiva();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Tooltip(
      message: l.txAtivaNaPedaleiraDica,
      child: Row(key: const ValueKey('etiqueta-area-ativa'), mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: Medidas.led,
          height: Medidas.led,
          decoration: const BoxDecoration(color: Cores.ledLigado, shape: BoxShape.circle),
        ),
        const SizedBox(width: Espacos.xs),
        Text(l.txAtiva, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Cores.ledLigado)),
      ]),
    );
  }
}
