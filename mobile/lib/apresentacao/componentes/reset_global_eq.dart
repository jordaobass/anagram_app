// O Reset do Global EQ: volta as chaves confirmadas do EQ aos padrões de
// fábrica, com desfazer. A regra (quais chaves, de onde vem o "antes") fica
// fora do cartão, que só pergunta e mostra o aviso.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_ajustes.dart';
import '../../l10n/app_localizations.dart';
import '../../nucleo/ajustes/mapa_ajustes.dart';
import 'dialogo_confirmar.dart';

/// O valor de agora de cada chave do Global EQ (o lido, o mexido ou, sem
/// leitura, o padrão): é o que o desfazer devolve.
Map<DefinicaoAjuste, num> valoresDoGlobalEq(EstadoAjustes estado) =>
    {for (final a in ajustesConfirmados(GrupoAjuste.globalEq)) a: estado.valor(a) ?? a.padrao};

/// Os padrões de fábrica das mesmas chaves.
Map<DefinicaoAjuste, num> padroesDoGlobalEq() => {for (final a in ajustesConfirmados(GrupoAjuste.globalEq)) a: a.padrao};

/// Pergunta, volta as chaves ao padrão e oferece desfazer. [estaMontado]:
/// o cartão ainda está na tela depois da pergunta.
Future<void> resetarGlobalEq(BuildContext context, WidgetRef ref, {required bool Function() estaMontado}) async {
  final l = AppLocalizations.of(context);
  final mensageiro = ScaffoldMessenger.of(context);
  final sim = await confirmar(context,
      titulo: l.pdEqResetTitulo,
      texto: l.pdEqResetTexto,
      rotuloCancelar: l.cancelar,
      rotuloConfirmar: l.pdEqResetConfirmar,
      chaveConfirmar: const ValueKey('confirmar-reset-eq'));
  if (!sim || !estaMontado()) return;
  final controlador = ref.read(controladorAjustesProvider.notifier);
  final antes = valoresDoGlobalEq(ref.read(controladorAjustesProvider));
  padroesDoGlobalEq().forEach(controlador.alterar);
  mensageiro.showSnackBar(SnackBar(
    content: Text(l.pdEqResetFeito),
    action: SnackBarAction(label: l.desfazer, onPressed: () => antes.forEach(controlador.alterar)),
  ));
}
