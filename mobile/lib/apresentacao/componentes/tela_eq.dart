// A tela de um equalizador como a da Anagram, a mesma no Global EQ e no bloco
// Parametric EQ (é o mesmo DSP, DECISOES EQ11): o seletor de modo (com as
// ações ao lado, quando há), a curva somada com os pontos (arrastáveis no
// bloco; no Global EQ, só leitura), uma dica opcional e as bandas lado a
// lado. Quem usa decide o que é cada banda e para onde vai cada mudança.
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../nucleo/ajustes/curva_global_eq.dart';
import '../../nucleo/ajustes/mapa_ajustes.dart';
import '../tema/tokens.dart';
import 'curva_eq_arrastavel.dart';
import 'fileira_bandas_eq.dart';

class TelaEq extends StatelessWidget {
  const TelaEq({
    super.key,
    required this.modo,
    required this.aoEscolherModo,
    required this.chaveCurva,
    required this.bandasDaCurva,
    this.aoArrastar,
    required this.bandas,
    this.ganhoGeral = 0,
    this.acoes,
    this.dica,
    this.rodape,
  });

  final ModoEq modo;
  final ValueChanged<ModoEq> aoEscolherModo;
  final Key chaveCurva;
  final List<BandaGlobalEq> bandasDaCurva;

  /// Nulo = curva só de leitura (o Global EQ).
  final AoArrastarBanda? aoArrastar;

  /// Um controle por banda, na ordem da curva.
  final List<Widget> bandas;
  final double ganhoGeral;

  /// Ao lado do seletor de modo (o Reset do bloco).
  final Widget? acoes;

  /// Embaixo da curva, em texto secundário.
  final String? dica;

  /// Embaixo das bandas (o aviso de ajuste recusado).
  final Widget? rodape;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
        Row(children: [Expanded(child: SeletorModoEq(modo: modo, aoEscolher: aoEscolherModo)), ?acoes]),
        const SizedBox(height: Espacos.s),
        CurvaEqArrastavel(
            key: chaveCurva, bandas: bandasDaCurva, cor: Cores.doModoEq(modo), ganhoGeral: ganhoGeral, aoArrastar: aoArrastar),
        if (dica case final texto?) ...[
          const SizedBox(height: Espacos.xs),
          Text(texto, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Cores.textoSecundario)),
        ],
        const SizedBox(height: Espacos.m),
        LinhaDeBandas(filhos: bandas),
        ?rodape,
      ]);
}

/// Os três modos, botões de ícone na cor de cada um, como o canto da tela da
/// Anagram: o escolhido fica cheio, os outros só com o contorno.
class SeletorModoEq extends StatelessWidget {
  const SeletorModoEq({super.key, required this.modo, required this.aoEscolher});

  final ModoEq modo;
  final ValueChanged<ModoEq> aoEscolher;

  static IconData _icone(ModoEq m) => switch (m) {
        ModoEq.gain => Icons.unfold_more,
        ModoEq.freq => Icons.code,
        ModoEq.width => Icons.width_normal_outlined,
      };

  static String _nome(AppLocalizations l, ModoEq m) => switch (m) {
        ModoEq.gain => l.pdEqModoGanho,
        ModoEq.freq => l.pdEqModoFrequencia,
        ModoEq.width => l.pdEqModoLargura,
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(children: [
      for (final m in ModoEq.values)
        Padding(
          padding: const EdgeInsets.only(right: Espacos.s),
          child: Tooltip(
            message: _nome(l, m),
            child: IconButton(
              key: ValueKey('modo-eq-${m.name}'),
              onPressed: () => aoEscolher(m),
              isSelected: m == modo,
              icon: Icon(_icone(m), color: m == modo ? Cores.textoSobreModoEq : Cores.doModoEq(m)),
              style: IconButton.styleFrom(
                backgroundColor: m == modo ? Cores.doModoEq(m) : Colors.transparent,
                side: BorderSide(color: Cores.doModoEq(m)),
              ),
            ),
          ),
        ),
      Flexible(
        child: Text(_nome(l, modo),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Cores.textoDoModoEq(modo))),
      ),
    ]);
  }
}
