// "Controles da pedaleira": os três footswitches, os seis pots e o pedal de
// expressão na ordem em que estão no aparelho, cada um com o nome que o
// visor mostra e o que ele move. Tocar abre a edição do controle.
// Recolhível: aberto por padrão só com algum controle atribuído (DECISOES UI2).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../../aplicacao/estado/paineis_recolhidos.dart';
import '../../l10n/app_localizations.dart';
import '../../nucleo/modelo/controles_pedaleira.dart';
import '../../nucleo/modelo/documento_preset.dart';
import '../tema/tokens.dart';
import '../textos.dart';
import 'alvo_do_controle.dart';
import 'botao_dicas.dart';
import 'casa_arrastavel.dart' show arrastoComMouse;
import 'dialogo_controle.dart';
import 'seletor_modo_footswitches.dart' show AvisoModoNosControles;

class PainelControles extends ConsumerWidget {
  const PainelControles({super.key, required this.compacto});

  /// No celular três cartões por fileira, para FOOT 1–3 ficarem juntos.
  final bool compacto;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documento = ref.watch(editorProvider.select((e) => e.atual));
    if (documento == null) return const SizedBox.shrink();
    // o arquivo traz os footswitches com nome mesmo sem alvo: conta quem move algo
    final atribuidos = documento.controles.values.where((c) => c.alvos.isNotEmpty).length;
    final aberto = ControlesAbertos.resolver(ref.watch(controlesAbertosProvider), temAtribuicao: atribuidos > 0);
    return Column(key: const ValueKey('painel-controles'), crossAxisAlignment: CrossAxisAlignment.start, children: [
      _CabecalhoControles(aberto: aberto, atribuidos: atribuidos),
      if (aberto) ...[
        const AvisoModoNosControles(),
        const SizedBox(height: Espacos.m),
        LayoutBuilder(builder: (context, restricoes) => _grupos(documento, _largura(restricoes.maxWidth))),
      ],
    ]);
  }

  double _largura(double disponivel) {
    if (!compacto) return Medidas.larguraCartaoControle;
    final tres = (disponivel - 2 * Espacos.s) / 3;
    return tres.clamp(Medidas.larguraMinimaCartaoControle, Medidas.larguraCartaoControle);
  }

  /// Footswitches, pots e pedal em grupos separados, como no painel do aparelho.
  Widget _grupos(DocumentoPreset documento, double largura) {
    final controles = documento.controles;
    Widget grupo(TipoControle tipo) => Wrap(spacing: Espacos.s, runSpacing: Espacos.s, children: [
          for (final id in IdControle.doTipo(tipo))
            CartaoControle(id: id, controle: controles[id], documento: documento, largura: largura),
        ]);
    return Wrap(
      spacing: Espacos.xl,
      runSpacing: Espacos.m,
      children: [for (final tipo in TipoControle.values) grupo(tipo)],
    );
  }
}

/// Título clicável (abre e recolhe, e a escolha fica guardada), quantos
/// controles estão atribuídos e o "?" com as dicas de uso.
class _CabecalhoControles extends ConsumerWidget {
  const _CabecalhoControles({required this.aberto, required this.atribuidos});

  final bool aberto;
  final int atribuidos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final tema = Theme.of(context).textTheme;
    return Row(children: [
      Expanded(
        child: Semantics(
          button: true,
          expanded: aberto,
          label: aberto ? l.ctlRecolher : l.ctlMostrar,
          child: InkWell(
            key: const ValueKey('cabecalho-controles'),
            borderRadius: BorderRadius.circular(Raios.controle),
            onTap: () => ref.read(controlesAbertosProvider.notifier).definir(abertos: !aberto),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: Medidas.alvoMinimo),
              child: Row(children: [
                Icon(aberto ? Icons.expand_less : Icons.expand_more, color: context.cores.aluminioClaro),
                const SizedBox(width: Espacos.s),
                Flexible(child: Text(l.ctlTitulo.toUpperCase(), style: tema.labelLarge)),
                const SizedBox(width: Espacos.m),
                Text(l.ctlResumo(atribuidos), style: tema.labelMedium),
              ]),
            ),
          ),
        ),
      ),
      BotaoDicas(dicas: [l.ctlDicaPara(mouse: arrastoComMouse), l.ctlDicaPedaleira, l.fmDica]),
    ]);
  }
}

/// Um controle: sigla e número como impressos no aparelho, o nome do visor
/// e uma fita por alvo; livre, só o contorno.
class CartaoControle extends ConsumerWidget {
  const CartaoControle(
      {super.key, required this.id, required this.controle, required this.documento, required this.largura});

  final IdControle id;
  final ControlePedaleira? controle;
  final DocumentoPreset documento;
  final double largura;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final atual = controle;
    void abrir() => abrirEdicaoControle(context, ref, id);
    return Semantics(
      button: true,
      excludeSemantics: true,
      label: '${l.rotuloControle(id)}, ${atual?.nome ?? l.ctlLivre}',
      onTap: abrir,
      child: InkWell(
        key: ValueKey('controle-${id.chave}'),
        borderRadius: BorderRadius.circular(Raios.controle),
        onTap: abrir,
        child: Container(
          width: largura,
          constraints: const BoxConstraints(minHeight: Medidas.alvoMinimo),
          padding: const EdgeInsets.all(Espacos.s),
          decoration: BoxDecoration(
            color: atual == null ? null : context.cores.painelElevado,
            border: Border.all(color: context.cores.filete, width: Medidas.filete),
            borderRadius: BorderRadius.circular(Raios.controle),
          ),
          child: _conteudo(context, ref, l, atual),
        ),
      ),
    );
  }

  Widget _conteudo(BuildContext context, WidgetRef ref, AppLocalizations l, ControlePedaleira? atual) {
    final tema = Theme.of(context).textTheme;
    final apoio = tema.bodySmall?.copyWith(color: context.cores.textoSecundario);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
      IdentidadeControle(id: id),
      const SizedBox(height: Espacos.xs),
      Text(atual?.nome ?? l.ctlLivre,
          maxLines: 1, overflow: TextOverflow.ellipsis, style: atual == null ? apoio : tema.bodyMedium),
      for (final alvo in atual?.alvos ?? const <AlvoControle>[]) ...[
        const SizedBox(height: Espacos.xs),
        FitaDoAlvo(
            alvo: AlvoNaTela.de(ref, documento, alvo), estilo: tema.labelSmall?.copyWith(color: context.cores.textoSecundario)),
      ],
    ]);
  }
}

/// "POT" em rótulo e o "2" em estêncil (o estêncil é só para o número).
class IdentidadeControle extends StatelessWidget {
  const IdentidadeControle({super.key, required this.id});

  final IdControle id;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
      Text(AppLocalizations.of(context).siglaControle(id), style: tema.labelMedium?.copyWith(color: context.cores.aluminioClaro)),
      if (id.tipo != TipoControle.expressao) ...[
        const SizedBox(width: Espacos.xs),
        Text('${id.numero}', style: tema.displaySmall?.copyWith(fontSize: tema.titleLarge?.fontSize)),
      ],
    ]);
  }
}
