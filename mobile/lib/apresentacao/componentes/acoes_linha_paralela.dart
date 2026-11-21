// Embaixo da cadeia: mandar o sinal também para a linha 2 (Split e Merge na
// linha 1) ou desfazer isso. À vista, e não num menu, porque é o jeito de
// montar um caminho paralelo e a pessoa não acharia o Split na biblioteca.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../../l10n/app_localizations.dart';
import '../../nucleo/catalogo/linha_paralela.dart';
import '../tema/tokens.dart';
import 'dialogo_confirmar.dart';

class AcoesLinhaParalela extends ConsumerWidget {
  const AcoesLinhaParalela({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documento = ref.watch(editorProvider.select((e) => e.atual));
    final ocupado = ref.watch(editorProvider.select((e) => e.ocupado));
    if (documento == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final paralela = temLinhaParalela(documento);
    return Align(
      alignment: Alignment.centerRight,
      child: Tooltip(
        message: paralela ? '' : l.lpCriarDica,
        child: TextButton.icon(
          key: ValueKey(paralela ? 'remover-linha-paralela' : 'criar-linha-paralela'),
          style: TextButton.styleFrom(foregroundColor: Cores.aluminioClaro),
          icon: Icon(paralela ? Icons.call_merge : Icons.call_split),
          label: Text(paralela ? l.lpRemover : l.lpCriar),
          onPressed: ocupado ? null : () => paralela ? _remover(context, ref) : _criar(context, ref),
        ),
      ),
    );
  }

  Future<void> _criar(BuildContext context, WidgetRef ref) async {
    final mensageiro = ScaffoldMessenger.of(context);
    final texto = AppLocalizations.of(context).lpSemEspaco;
    if (!await ref.read(editorProvider.notifier).criarLinhaParalela()) {
      mensageiro.showSnackBar(SnackBar(content: Text(texto)));
    }
  }

  /// Com blocos na linha 2, pergunta: eles saem junto (sem a divisão, não
  /// recebem sinal, e jogá-los na linha 1 mudaria o som sem a pessoa pedir).
  Future<void> _remover(BuildContext context, WidgetRef ref) async {
    final controlador = ref.read(editorProvider.notifier);
    final naLinha2 = ref.read(editorProvider).atual?.blocosDaLinha(2).length ?? 0;
    if (naLinha2 > 0) {
      final l = AppLocalizations.of(context);
      final sim = await confirmar(
        context,
        titulo: l.lpRemoverTitulo,
        texto: l.lpRemoverTexto(naLinha2),
        rotuloCancelar: l.cancelar,
        rotuloConfirmar: l.lpRemoverConfirmar,
        chaveConfirmar: const ValueKey('confirmar-remover-linha-paralela'),
      );
      if (!sim) return;
    }
    await controlador.removerLinhaParalela();
  }
}
