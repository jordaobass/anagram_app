// Embaixo da cadeia: desfazer a linha paralela (Split, Merge e linha 2). Criar
// tem três portas à vista (DECISOES M8): a faixa tracejada no lugar da linha 2
// vazia, o par Split + Merge na biblioteca e o "Dividir o sinal depois deste
// bloco" no menu. O botão de criar daqui só sobra quando a linha 2 tem blocos
// sem Split (a faixa não aparece) — preset raro, que a pedaleira não toca.
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
    if (!paralela && documento.blocosDaLinha(2).isEmpty) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.centerRight,
      child: Tooltip(
        message: paralela ? '' : l.lpCriarDica,
        child: TextButton.icon(
          key: ValueKey(paralela ? 'remover-linha-paralela' : 'criar-linha-paralela'),
          style: TextButton.styleFrom(foregroundColor: Cores.aluminioClaro),
          icon: Icon(paralela ? Icons.call_merge : Icons.call_split),
          label: Text(paralela ? l.lpRemover : l.lpCriar),
          onPressed: ocupado ? null : () => paralela ? _remover(context, ref) : criarLinhaParalelaComAviso(context, ref),
        ),
      ),
    );
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

/// Cria a linha paralela (Split depois da casa [depoisDe] da linha 1, ou do
/// bloco selecionado) e avisa quando a linha 1 não tem duas casas livres.
/// Usada pela faixa da linha 2, pela biblioteca e pelo menu do bloco.
Future<void> criarLinhaParalelaComAviso(BuildContext context, WidgetRef ref, {int? depoisDe}) async {
  final mensageiro = ScaffoldMessenger.of(context);
  final texto = AppLocalizations.of(context).lpSemEspaco;
  if (!await ref.read(editorProvider.notifier).criarLinhaParalela(depoisDe: depoisDe)) {
    mensageiro.showSnackBar(SnackBar(content: Text(texto)));
  }
}
