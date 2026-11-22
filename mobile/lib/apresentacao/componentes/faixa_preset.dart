// Fita gaffer do preset aberto: slot em estêncil, nome a marcador, selo
// "NÃO SALVO" e as ações de gravar. É o que se lê de longe no palco.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../../aplicacao/estado/estado_editor.dart';
import '../../nucleo/modelo/presets_fabrica.dart';
import '../tema/tokens.dart';
import 'acoes_preset.dart';
import 'dialogo_renomear.dart';
import 'fita_gaffer.dart';
import '../../l10n/app_localizations.dart';

class FaixaPreset extends ConsumerWidget {
  const FaixaPreset({super.key, required this.compacta, this.aoTocarSlot});

  final bool compacta;
  final VoidCallback? aoTocarSlot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(editorProvider);
    final documento = estado.atual;
    if (documento == null) return const SizedBox.shrink();
    final linha = Row(children: [
      _slot(context, estado),
      const SizedBox(width: Espacos.m),
      Expanded(child: _fitaTocavel(context, ref, estado)),
    ]);
    final avisos = _Avisos(estado: estado);
    return LayoutBuilder(builder: (context, restricoes) {
      // sem largura para fita e botões lado a lado, os botões descem (iPad mini em paisagem)
      final empilhar = compacta || restricoes.maxWidth < Medidas.larguraFaixaEmLinha;
      final acoes = AcoesPreset(compactas: empilhar, listaEmOutraTela: aoTocarSlot != null);
      if (empilhar) {
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          linha,
          avisos,
          const SizedBox(height: Espacos.s),
          acoes,
        ]);
      }
      return Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [linha, avisos])),
        const SizedBox(width: Espacos.l),
        acoes,
      ]);
    });
  }

  /// Slot em estêncil; no layout de uma coluna, abre a lista. Ali ele leva
  /// "PRESETS ▾" embaixo: trocar de preset é a tarefa do palco, e um número
  /// sozinho não diz que é tocável.
  Widget _slot(BuildContext context, EstadoEditor estado) {
    final l = AppLocalizations.of(context);
    final tema = Theme.of(context).textTheme;
    final rotulo = Text(estado.slot?.rotulo ?? '--',
        style: tema.displaySmall?.copyWith(fontSize: MedidasDoTopo.daPlataforma.slot));
    return Semantics(
        button: aoTocarSlot != null,
        label: '${l.slotSemantica(estado.slot?.rotulo ?? l.slotNovo)}${aoTocarSlot != null ? l.abrirListaSemantica : ''}',
        child: InkWell(
          key: const ValueKey('abrir-lista'),
          onTap: aoTocarSlot,
          borderRadius: BorderRadius.circular(Raios.controle),
          child: Padding(
            padding: const EdgeInsets.all(Espacos.xs),
            child: aoTocarSlot == null
                ? rotulo
                : Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                    rotulo,
                    _abrirPresets(l, tema, context.cores),
                  ]),
          ),
        ),
      );
  }

  static Widget _abrirPresets(AppLocalizations l, TextTheme tema, Paleta cores) => ExcludeSemantics(
        child: Row(key: const ValueKey('rotulo-abrir-presets'), mainAxisSize: MainAxisSize.min, children: [
          Text(l.uiPresets, style: tema.labelMedium?.copyWith(color: cores.aluminioClaro)),
          Icon(Icons.arrow_drop_down, color: cores.aluminioClaro),
        ]),
      );

  /// A fita com o nome: tocar renomeia.
  Widget _fitaTocavel(BuildContext context, WidgetRef ref, EstadoEditor estado) => Semantics(
        button: true,
        label: AppLocalizations.of(context).renomearPresetSemantica(estado.atual!.nome),
        child: InkWell(
          key: const ValueKey('fita-nome'),
          onTap: () => renomearPreset(context, ref),
          child: _Fita(nome: estado.atual!.nome, naoSalvo: estado.naoSalvo, linhas: compacta ? 2 : 1),
        ),
      );
}

/// Ao vivo desligado e audição (sem USB MIDI), em letra de alerta: o âmbar
/// é da ação e da seleção, não de aviso. Preset de fábrica tem aviso próprio
/// (a audição é o único jeito de tocá-lo, então não é alerta repetir).
class _Avisos extends StatelessWidget {
  const _Avisos({required this.estado});

  final EstadoEditor estado;

  @override
  Widget build(BuildContext context) {
    final estilo = Theme.of(context).textTheme.labelMedium?.copyWith(color: context.cores.erro);
    final l = AppLocalizations.of(context);
    final daFabrica = estado.area == PresetsDeFabrica.idArea;
    final avisos = [
      if (!estado.aoVivo) l.avisoAoVivoDesligado,
      if (estado.slot != null && !estado.slotNaPedaleira && !daFabrica) l.avisoAudicao,
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (daFabrica)
        Padding(
          padding: const EdgeInsets.only(top: Espacos.xs),
          child: Text(l.fbAvisoPresetDeFabrica,
              key: const ValueKey('aviso-preset-fabrica'), style: estilo?.copyWith(color: context.cores.textoSecundario)),
        ),
      for (final aviso in avisos)
        Padding(padding: const EdgeInsets.only(top: Espacos.xs), child: Text(aviso, style: estilo)),
    ]);
  }
}

class _Fita extends StatelessWidget {
  const _Fita({required this.nome, required this.naoSalvo, required this.linhas});

  final String nome;
  final bool naoSalvo;
  final int linhas;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final medidas = MedidasDoTopo.daPlataforma;
    return FitaGaffer(
      medidas: medidas,
      child: Row(children: [
        Expanded(
          child: Text(nome,
              maxLines: linhas,
              overflow: TextOverflow.ellipsis,
              style: tema.headlineSmall?.copyWith(fontSize: medidas.nomePreset)),
        ),
        // tocar a fita renomeia: o lápis diz isso sem competir com o nome
        Tooltip(
          message: AppLocalizations.of(context).uiRenomear,
          child: Icon(Icons.edit_outlined, size: Medidas.iconeLapis, color: context.cores.aluminio),
        ),
        if (naoSalvo) ...[
          const SizedBox(width: Espacos.s),
          Container(
            key: const ValueKey('selo-nao-salvo'),
            padding: const EdgeInsets.symmetric(horizontal: Espacos.s, vertical: Espacos.xxs),
            color: context.cores.fitaAlerta,
            child: Text(AppLocalizations.of(context).naoSalvo, style: tema.labelMedium?.copyWith(color: context.cores.sobreAlerta)),
          ),
        ],
      ]),
    );
  }
}
