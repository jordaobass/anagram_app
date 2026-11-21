// Um ajuste global num knob ou fader: o mesmo controle dos blocos (arrastar,
// rodinha, digitar o número, segurar volta ao padrão), ligado ao
// [ControladorAjustes] em vez do editor. E o aviso que aparece perto dos
// controles quando a pedaleira recusa a mudança.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_ajustes.dart';
import '../../l10n/app_localizations.dart';
import '../../nucleo/ajustes/mapa_ajustes.dart';
import '../../nucleo/catalogo/arranjo_parametros.dart';
import '../tema/tokens.dart';
import 'botao_giratorio.dart';

class ControleAjuste extends ConsumerWidget {
  const ControleAjuste({super.key, required this.definicao, this.forma = FormaControle.knob, this.cor});

  final DefinicaoAjuste definicao;
  final FormaControle forma;
  final Color? cor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final valor = ref.watch(controladorAjustesProvider.select((e) => e.valor(definicao))) ?? definicao.padrao;
    return BotaoGiratorio(
      key: ValueKey('ajuste-${definicao.id}'),
      parametro: definicao.parametro,
      valor: valor,
      cor: cor ?? Cores.linhaLevel,
      tamanho: Medidas.knobCompacto,
      forma: forma,
      aoMudar: (v, {required arrastando}) => ref.read(controladorAjustesProvider.notifier).alterar(definicao, v),
    );
  }
}

/// A frase curta, sem detalhe técnico, quando o último envio de algum dos
/// [ids] foi recusado (a causa real vai para o log pelo repositório).
class AvisoErroAjustes extends ConsumerWidget {
  const AvisoErroAjustes({super.key, required this.ids});

  final Set<String> ids;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comErro = ref.watch(controladorAjustesProvider.select((e) => e.comErro.any(ids.contains)));
    if (!comErro) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: Espacos.s),
      child: Text(
        AppLocalizations.of(context).pdErroGravar,
        key: const ValueKey('erro-ajuste'),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Cores.erro),
      ),
    );
  }
}
