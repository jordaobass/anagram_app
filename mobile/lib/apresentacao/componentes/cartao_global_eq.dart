// Global EQ da pedaleira, como a tela dela ([TelaEq]: modo, curva com os
// pontos e as 6 bandas com o valor do modo). "Input Gain" leva ao cartão
// Entrada; "Reset" volta aos padrões de fábrica, com desfazer.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_ajustes.dart';
import '../../l10n/app_localizations.dart';
import '../../nucleo/ajustes/curva_global_eq.dart';
import '../../nucleo/ajustes/mapa_ajustes.dart';
import 'cartao_secao_synth.dart';
import 'controles_ajuste.dart';
import 'fileira_bandas_eq.dart';
import 'reset_global_eq.dart';
import 'tela_eq.dart';

class CartaoGlobalEq extends ConsumerStatefulWidget {
  const CartaoGlobalEq({super.key, this.aoIrParaEntrada});

  final VoidCallback? aoIrParaEntrada;

  @override
  ConsumerState<CartaoGlobalEq> createState() => _CartaoGlobalEqState();
}

class _CartaoGlobalEqState extends ConsumerState<CartaoGlobalEq> {
  ModoEq _modo = ModoEq.gain;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return CartaoSecaoSynth(
      key: const ValueKey('cartao-global-eq'),
      titulo: l.pdGlobalEq,
      largura: double.infinity,
      chave: _acoes(l),
      desenho: TelaEq(
        modo: _modo,
        aoEscolherModo: (m) => setState(() => _modo = m),
        chaveCurva: const ValueKey('curva-global-eq'),
        bandasDaCurva: bandasDaTela(ref.watch(controladorAjustesProvider)),
        aoArrastar: _arrastar,
        bandas: bandasDoGlobalEq(_modo),
        dica: l.pdEqDica,
        rodape: AvisoErroAjustes(ids: {for (final a in ajustesConfirmados(GrupoAjuste.globalEq)) a.id}),
      ),
      filhos: const [],
    );
  }

  Widget _acoes(AppLocalizations l) => Row(mainAxisSize: MainAxisSize.min, children: [
        TextButton(key: const ValueKey('eq-input-gain'), onPressed: widget.aoIrParaEntrada, child: Text(l.pdEqInputGain)),
        TextButton(
            key: const ValueKey('eq-reset'),
            onPressed: () => resetarGlobalEq(context, ref, estaMontado: () => mounted),
            child: Text(l.pdEqReset)),
      ]);

  /// Arrastar o ponto da banda [i] muda frequência e ganho dela. Os ajustes
  /// globais vão a cada mudança (sem janela de arraste), então o soltar repete o último.
  void _arrastar(int i, double frequencia, double ganho, {required bool arrastando}) {
    final controlador = ref.read(controladorAjustesProvider.notifier);
    final banda = bandasEqGlobal[i];
    controlador.alterar(ajustePorIdOuChave(banda.id(ModoEq.freq))!, frequencia);
    controlador.alterar(ajustePorIdOuChave(banda.id(ModoEq.gain))!, ganho);
  }
}

/// As 6 bandas com o valor da tela (o mexido ou o lido; sem leitura, o padrão).
List<BandaGlobalEq> bandasDaTela(EstadoAjustes estado) => [
      for (final banda in bandasEqGlobal)
        BandaGlobalEq(
          banda.tipo,
          _valor(estado, banda, ModoEq.freq),
          _valor(estado, banda, ModoEq.gain),
          _valor(estado, banda, ModoEq.width),
        ),
    ];

double _valor(EstadoAjustes estado, BandaEqGlobal banda, ModoEq modo) {
  final a = ajustePorIdOuChave(banda.id(modo))!;
  return (estado.valor(a) ?? a.padrao).toDouble();
}
