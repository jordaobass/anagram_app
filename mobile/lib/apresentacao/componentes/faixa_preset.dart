// Fita gaffer do preset aberto: slot em estêncil, nome a marcador, selo
// "NÃO SALVO" e as ações de gravar. É o que se lê de longe no palco.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../../aplicacao/estado/estado_editor.dart';
import '../tema/tokens.dart';
import 'acoes_preset.dart';
import 'dialogo_renomear.dart';

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

  /// Slot em estêncil; no layout de uma coluna, abre a lista.
  Widget _slot(BuildContext context, EstadoEditor estado) => Semantics(
        button: aoTocarSlot != null,
        label: 'Slot ${estado.slot?.rotulo ?? 'novo'}${aoTocarSlot != null ? ', abrir lista de presets' : ''}',
        child: InkWell(
          key: const ValueKey('abrir-lista'),
          onTap: aoTocarSlot,
          child: Padding(
            padding: const EdgeInsets.all(Espacos.xs),
            child: Text(estado.slot?.rotulo ?? '--', style: Theme.of(context).textTheme.displaySmall),
          ),
        ),
      );

  /// A fita com o nome: tocar renomeia.
  Widget _fitaTocavel(BuildContext context, WidgetRef ref, EstadoEditor estado) => Semantics(
        button: true,
        label: 'Renomear preset ${estado.atual!.nome}',
        child: InkWell(
          key: const ValueKey('fita-nome'),
          onTap: () => renomearPreset(context, ref),
          child: _Fita(nome: estado.atual!.nome, naoSalvo: estado.naoSalvo, linhas: compacta ? 2 : 1),
        ),
      );
}

/// Ao vivo desligado e audição (sem USB MIDI), em letra de alerta.
class _Avisos extends StatelessWidget {
  const _Avisos({required this.estado});

  final EstadoEditor estado;

  @override
  Widget build(BuildContext context) {
    final estilo = Theme.of(context).textTheme.labelMedium?.copyWith(color: Cores.tally);
    final avisos = [
      if (!estado.aoVivo) 'AO VIVO DESLIGADO — as edições ficam só no app, a pedaleira não muda.',
      if (estado.slot != null && !estado.slotNaPedaleira)
        'AUDIÇÃO — a pedaleira continua no slot dela (sem USB MIDI).',
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
    return Container(
      constraints: const BoxConstraints(minHeight: Medidas.alvoMinimo + Espacos.s),
      padding: const EdgeInsets.symmetric(horizontal: Espacos.l, vertical: Espacos.s),
      decoration: const BoxDecoration(
        color: Cores.fitaGaffer,
        border: Border(bottom: BorderSide(color: Cores.fitaGafferSombra, width: Medidas.contornoSelecao)),
      ),
      child: Row(children: [
        Expanded(child: Text(nome, maxLines: linhas, overflow: TextOverflow.ellipsis, style: tema.headlineSmall)),
        if (naoSalvo) ...[
          const SizedBox(width: Espacos.s),
          Container(
            key: const ValueKey('selo-nao-salvo'),
            padding: const EdgeInsets.symmetric(horizontal: Espacos.s, vertical: Espacos.xxs),
            color: Cores.fitaAlerta,
            child: Text('NÃO SALVO', style: tema.labelMedium?.copyWith(color: Cores.sobreAlerta)),
          ),
        ],
      ]),
    );
  }
}
