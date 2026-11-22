// Um ajuste global num knob ou fader SÓ DE LEITURA: o mesmo desenho dos
// blocos, com o valor que a pedaleira exportou. Nada aqui grava — a Anagram
// aceita mixer, Global EQ e entrada pelo USB, mas não os aplica ao som
// (DECISOES AJ1).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_ajustes.dart';
import '../../nucleo/ajustes/mapa_ajustes.dart';
import '../../nucleo/catalogo/arranjo_parametros.dart';
import '../tema/tokens.dart';
import 'botao_giratorio.dart';

class ControleAjuste extends ConsumerWidget {
  const ControleAjuste({super.key, required this.definicao, this.forma = FormaControle.knob, this.cor, this.tamanho, this.rotulo, this.corChip});

  final DefinicaoAjuste definicao;
  final FormaControle forma;
  final Color? cor;
  final double? tamanho;
  final String? rotulo;
  final Color? corChip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final valor = ref.watch(controladorAjustesProvider.select((e) => e.valor(definicao))) ?? definicao.padrao;
    final faixa = ref.watch(controladorAjustesProvider.select((e) => e.faixa(definicao)));
    return BotaoGiratorio(
      key: ValueKey('ajuste-${definicao.id}'),
      parametro: faixa.parametro,
      valor: valor,
      cor: cor ?? context.cores.linhaLevel,
      tamanho: tamanho ?? Medidas.knobCompacto,
      forma: forma,
      rotulo: rotulo,
      corChipValor: corChip,
    );
  }
}
