// Split e Merge entram e saem como os outros blocos (DECISOES M11); aqui
// ficam só o que eles têm de diferente na tela: o motivo de uma recusa, dito
// em uma frase, e a pergunta antes de tirar o Split com blocos na linha 2.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../../l10n/app_localizations.dart';
import '../../nucleo/catalogo/linha_paralela.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import 'dialogo_confirmar.dart';

String textoDaRecusa(AppLocalizations l, RecusaAdicionar recusa) => switch (recusa) {
      RecusaAdicionar.splitRepetido => l.smUmSplit,
      RecusaAdicionar.mergeRepetido => l.smUmMerge,
      RecusaAdicionar.mergeSemSplit => l.smMergeSemSplit,
      RecusaAdicionar.foraDaLinha1 => l.smSoNaLinha1,
      RecusaAdicionar.mergeAntesDoSplit || RecusaAdicionar.splitDepoisDoMerge => l.smOrdemInvalida,
    };

/// Remover pelo menu. Tirar o Split com blocos na linha 2 pergunta antes:
/// eles e o Merge saem juntos, porque sem a divisão não recebem sinal.
Future<void> removerBlocoComAviso(BuildContext context, WidgetRef ref, PosicaoBloco posicao) async {
  final controlador = ref.read(editorProvider.notifier);
  final documento = ref.read(editorProvider).atual;
  final naLinha2 = documento?.blocosDaLinha(2).length ?? 0;
  if (documento?.bloco(posicao)?.uri == uriSplit && naLinha2 > 0) {
    final l = AppLocalizations.of(context);
    final sim = await confirmar(
      context,
      titulo: l.lpRemoverTitulo,
      texto: l.lpRemoverTexto(naLinha2),
      rotuloCancelar: l.cancelar,
      rotuloConfirmar: l.lpRemoverConfirmar,
      chaveConfirmar: const ValueKey('confirmar-remover-split'),
    );
    if (!sim) return;
  }
  await controlador.removerBloco(posicao);
}
