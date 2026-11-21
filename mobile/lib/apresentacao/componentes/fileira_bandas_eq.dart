// As 6 bandas do Global EQ lado a lado, como na tela da Anagram: em cima o
// rótulo da banda (a frequência; no modo Frequency, o ganho) e o valor do
// modo num chip na cor dele, que se toca para digitar; o knob de cada banda
// mexe só no atributo do modo, como os 6 knobs da pedaleira. Abaixo de
// [Medidas.larguraEqEmLinha] as bandas viram duas linhas de 3.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_ajustes.dart';
import '../../l10n/app_localizations.dart';
import '../../nucleo/ajustes/mapa_ajustes.dart';
import '../tema/tokens.dart';
import '../textos.dart';
import 'controles_ajuste.dart';

/// As 6 bandas do Global EQ no [modo], para a [LinhaDeBandas].
List<Widget> bandasDoGlobalEq(ModoEq modo) => [for (final banda in bandasEqGlobal) _BandaEq(banda: banda, modo: modo)];

/// As bandas de um equalizador lado a lado, todas da mesma largura; abaixo de
/// [Medidas.larguraEqEmLinha] viram linhas de 3. Serve ao Global EQ e ao
/// bloco Parametric EQ.
class LinhaDeBandas extends StatelessWidget {
  const LinhaDeBandas({super.key, required this.filhos});

  final List<Widget> filhos;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, restricoes) {
        final porLinha = restricoes.maxWidth < Medidas.larguraEqEmLinha ? 3 : filhos.length;
        final largura = restricoes.maxWidth / porLinha;
        return Wrap(
          runSpacing: Espacos.m,
          children: [for (final f in filhos) SizedBox(width: largura, child: Center(child: f))],
        );
      });
}

class _BandaEq extends ConsumerWidget {
  const _BandaEq({required this.banda, required this.modo});

  final BandaEqGlobal banda;
  final ModoEq modo;

  /// O rótulo é o outro número da banda: a frequência; no modo Frequency, o
  /// ganho (a pedaleira mostra "[35.0 Hz] -18.0 dB").
  String _rotulo(AppLocalizations l, EstadoAjustes estado) {
    final outro = ajustePorIdOuChave(banda.id(modo == ModoEq.freq ? ModoEq.gain : ModoEq.freq))!;
    return l.valorDe(estado.faixa(outro).parametro, estado.valor(outro) ?? outro.padrao);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(controladorAjustesProvider);
    return ControleAjuste(
      key: ValueKey('banda-eq-${banda.codigo}'),
      definicao: ajustePorIdOuChave(banda.id(modo))!,
      rotulo: _rotulo(AppLocalizations.of(context), estado),
      cor: Cores.doModoEq(modo),
      corChip: Cores.doModoEq(modo),
    );
  }
}
