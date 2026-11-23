// Backup completo pelas Configurações (DECISOES BK4): um diálogo que não fecha
// sozinho mostra o progresso e o CANCELAR; no fim, um aviso diz quantos foram
// guardados e onde. O diálogo cobre a tela de propósito: durante o backup a
// pedaleira está ocupada com ele, um pedido por vez.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/avisos.dart';
import '../../aplicacao/copias/copia_completa.dart';
import '../../l10n/app_localizations.dart';
import '../tema/tokens.dart';
import '../textos.dart';
import 'dialogo_confirmar.dart';

Future<void> executarCopiaCompleta(BuildContext context, WidgetRef ref) async {
  final l = AppLocalizations.of(context);
  final mensageiro = ScaffoldMessenger.of(context);
  final navegador = Navigator.of(context);
  final controlador = ref.read(copiaCompletaProvider.notifier);
  final dialogo = showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => PopScope(canPop: false, child: _DialogoProgresso(aoCancelar: controlador.cancelar)),
  );
  final resultado = await controlador.executar();
  navegador.pop();
  await dialogo;
  mensageiro.showSnackBar(SnackBar(content: Text(_frase(l, resultado))));
}

String _frase(AppLocalizations l, ResultadoCopiaCompleta resultado) => switch (resultado) {
      CopiaCompletaConcluida(:final feitos, :final pasta) => l.bkCompletoConcluido(feitos, pasta),
      CopiaCompletaCancelada(:final feitos, :final total) => l.bkCompletoCancelado(feitos, total),
      CopiaCompletaFalhou(:final feitos, :final erro) => l.bkCompletoFalhou(feitos, l.aviso(AvisoErro(erro))),
    };

class _DialogoProgresso extends ConsumerWidget {
  const _DialogoProgresso({required this.aoCancelar});

  final VoidCallback aoCancelar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final progresso = ref.watch(copiaCompletaProvider);
    final total = progresso?.total;
    final feitos = progresso?.feitos ?? 0;
    return AlertDialog(
      key: const ValueKey('backup-completo-progresso'),
      title: Text(l.bkCompletoTitulo),
      constraints: const BoxConstraints(maxWidth: Medidas.larguraDialogo),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        LinearProgressIndicator(value: total == null || total == 0 ? null : feitos / total, color: Cores.aluminioClaro),
        const SizedBox(height: Espacos.m),
        Semantics(
          liveRegion: true,
          child: Text(total == null ? l.bkCompletoListando : l.bkCompletoProgresso(feitos, total)),
        ),
      ]),
      actions: [BotaoCancelarDialogo(key: const ValueKey('backup-completo-cancelar'), rotulo: l.cancelar, aoTocar: aoCancelar)],
    );
  }
}
