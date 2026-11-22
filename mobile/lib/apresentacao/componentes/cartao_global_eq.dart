// Global EQ da pedaleira, como a tela dela ([TelaEq]: modo, curva com os
// pontos e as 6 bandas com o valor do modo), SÓ DE LEITURA: a Anagram aceita
// `globaleq.*` pelo USB, mas não aplica ao som (DECISOES AJ1). Trocar o modo
// só muda o que se vê; "Input Gain" leva ao cartão Entrada.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_ajustes.dart';
import '../../l10n/app_localizations.dart';
import '../../nucleo/ajustes/curva_global_eq.dart';
import '../../nucleo/ajustes/mapa_ajustes.dart';
import 'cartao_secao_synth.dart';
import 'fileira_bandas_eq.dart';
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
      chave: TextButton(
          key: const ValueKey('eq-input-gain'), onPressed: widget.aoIrParaEntrada, child: Text(l.pdEqInputGain)),
      desenho: TelaEq(
        modo: _modo,
        aoEscolherModo: (m) => setState(() => _modo = m),
        chaveCurva: const ValueKey('curva-global-eq'),
        bandasDaCurva: bandasDaTela(ref.watch(controladorAjustesProvider)),
        bandas: bandasDoGlobalEq(_modo),
        dica: l.pdEqDica,
      ),
      filhos: const [],
    );
  }
}

/// As 6 bandas com o valor lido da pedaleira (sem leitura, o padrão).
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
