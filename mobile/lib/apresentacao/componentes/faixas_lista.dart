// Faixas no topo da lista de presets: a de "escolha o destino" de mover,
// clonar ou trocar banco (âmbar, como a do "Salvar como") e a de erro da
// própria lista.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_organizar.dart';
import '../../l10n/app_localizations.dart';
import '../tema/tokens.dart';

class FaixaOrganizar extends ConsumerWidget {
  const FaixaOrganizar(this.pendente, {super.key});

  final OperacaoPendente pendente;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final origem = pendente.origem;
    final texto = switch (pendente.operacao) {
      OperacaoPreset.mover => l.opDestinoMover(origem.rotulo),
      OperacaoPreset.clonar => l.opDestinoClonar(origem.rotulo),
      OperacaoPreset.trocarBanco => l.opDestinoBanco(origem.banco.toString().padLeft(2, '0')),
    };
    return Container(
      key: const ValueKey('faixa-organizar'),
      color: context.cores.tally,
      padding: const EdgeInsets.only(left: Espacos.m),
      child: Row(children: [
        Expanded(child: Text(texto, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: context.cores.sobreTally))),
        TextButton(
          onPressed: ref.read(organizarProvider.notifier).cancelar,
          style: TextButton.styleFrom(foregroundColor: context.cores.sobreTally),
          child: Text(l.cancelar),
        ),
      ]),
    );
  }
}

class FaixaErroLista extends StatelessWidget {
  const FaixaErroLista(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) => Container(
        key: const ValueKey('erro-lista'),
        width: double.infinity,
        color: context.cores.painelElevado,
        padding: const EdgeInsets.symmetric(horizontal: Espacos.m, vertical: Espacos.s),
        child: Text(texto, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.cores.erro)),
      );
}
