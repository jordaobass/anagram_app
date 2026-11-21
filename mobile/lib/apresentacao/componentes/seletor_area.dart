// Seletor de área de presets (firmware 1.18+), no topo da lista: os nomes
// que a pessoa deu na pedaleira ("Padrão", "Estudo", "User2"…). Só aparece
// quando a pedaleira tem áreas. Trocar de área com edição não salva pergunta
// antes, porque o preset aberto é fechado. Com os presets de fábrica no
// build (U18), a última opção é "Fábrica", marcada como só leitura.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_biblioteca.dart';
import '../../aplicacao/estado/controlador_editor.dart';
import '../../aplicacao/provedores.dart';
import '../../nucleo/modelo/areas_presets.dart';
import '../../nucleo/modelo/presets_fabrica.dart';
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
    final comFabrica = !(ref.watch(presetsFabricaProvider).value?.vazio ?? true);
    return Padding(
      padding: const EdgeInsets.fromLTRB(Espacos.m, Espacos.s, Espacos.m, Espacos.xs),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _escolha(context, ref, biblioteca, habilitado: !ocupado, comFabrica: comFabrica),
        if (biblioteca.naFabrica)
          _Nota(AppLocalizations.of(context).fbAreaSoLeitura)
        else if (biblioteca.areaForaDaPedaleira)
          const _AvisoAreaInativa(),
      ]),
    );
  }

  Widget _escolha(BuildContext context, WidgetRef ref, EstadoBiblioteca biblioteca,
          {required bool habilitado, required bool comFabrica}) =>
      Row(children: [
        Text(AppLocalizations.of(context).area,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Cores.textoSecundario)),
        const SizedBox(width: Espacos.s),
        Expanded(child: _lista(context, ref, biblioteca, habilitado: habilitado, comFabrica: comFabrica)),
        // a marca de ativa fica fora do nome: o nome nunca é cortado por ela
        if (biblioteca.areaSelecionada == biblioteca.areas.ativa) ...[
          const SizedBox(width: Espacos.s),
          const _EtiquetaAtiva(),
        ],
        if (biblioteca.naFabrica) ...[
          const SizedBox(width: Espacos.s),
          const SeloSoLeitura(),
        ],
      ]);

  Widget _lista(BuildContext context, WidgetRef ref, EstadoBiblioteca biblioteca,
      {required bool habilitado, required bool comFabrica}) {
    final l = AppLocalizations.of(context);
    final areas = biblioteca.areas.areas;
    return DropdownButton<String>(
      key: const ValueKey('seletor-area'),
      value: biblioteca.areaSelecionada,
      isExpanded: true,
      selectedItemBuilder: (_) => [
        for (final area in areas) Align(alignment: Alignment.centerLeft, child: _nome(l, area)),
        if (comFabrica)
          Align(alignment: Alignment.centerLeft, child: Text(l.fbAreaFabrica, maxLines: 1, overflow: TextOverflow.ellipsis)),
      ],
      items: _itens(l, biblioteca, comFabrica: comFabrica),
      onChanged: habilitado ? (id) => _trocar(context, ref, id) : null,
    );
  }

  /// No menu aberto: cada área com a etiqueta da ativa e, por último, a fábrica.
  List<DropdownMenuItem<String>> _itens(AppLocalizations l, EstadoBiblioteca biblioteca, {required bool comFabrica}) => [
        for (final area in biblioteca.areas.areas)
          DropdownMenuItem(
            key: ValueKey('area-${area.id}'),
            value: area.id,
            child: Row(children: [
              Expanded(child: _nome(l, area)),
              if (area.id == biblioteca.areas.ativa) const _EtiquetaAtiva(),
            ]),
          ),
        if (comFabrica)
          DropdownMenuItem(
            key: const ValueKey('area-${PresetsDeFabrica.idArea}'),
            value: PresetsDeFabrica.idArea,
            child: _fabrica(l),
          ),
      ];

  static Widget _nome(AppLocalizations l, AreaPresets area) =>
      Text(l.nomeDaArea(area), maxLines: 1, overflow: TextOverflow.ellipsis);

  /// No menu, o cadeado: o selo inteiro não cabe na largura do seletor.
  static Widget _fabrica(AppLocalizations l) => Row(children: [
        Expanded(child: Text(l.fbAreaFabrica, maxLines: 1, overflow: TextOverflow.ellipsis)),
        Icon(Icons.lock_outline, size: Medidas.iconeLapis, color: Cores.textoSecundario, semanticLabel: l.fbSoLeitura),
      ]);

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

/// Explicação curta sob o seletor, em letra secundária.
class _Nota extends StatelessWidget {
  const _Nota(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: Espacos.xs),
        child: Text(texto, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Cores.textoSecundario)),
      );
}

/// "SÓ LEITURA" contornado: diz que dali nada é gravado, sem cor de alerta.
class SeloSoLeitura extends StatelessWidget {
  const SeloSoLeitura({super.key});

  @override
  Widget build(BuildContext context) => Container(
        key: const ValueKey('selo-so-leitura'),
        padding: const EdgeInsets.symmetric(horizontal: Espacos.xs, vertical: Espacos.xxs),
        decoration: BoxDecoration(
          border: Border.all(color: Cores.textoSecundario),
          borderRadius: BorderRadius.circular(Raios.controle),
        ),
        child: Text(AppLocalizations.of(context).fbSoLeitura,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Cores.textoSecundario)),
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
