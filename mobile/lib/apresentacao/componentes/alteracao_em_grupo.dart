// Vários parâmetros do bloco numa alteração só (template, solo da banda),
// com o DESFAZER no aviso de baixo, como o do knob: ele volta o preset de
// antes inteiro, também numa alteração só — com o valor de cada cena, que
// "Todas as cenas" apaga. Não pergunta antes de aplicar
// por cima do ajuste da pessoa — o desfazer devolve tudo, e perguntar a cada
// template tornaria comparar dois deles lento.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../../l10n/app_localizations.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/modelo/bloco_preset.dart';

Future<void> alterarEmGrupo(
  BuildContext context,
  WidgetRef ref, {
  required BlocoPreset bloco,
  required DefinicaoBloco definicao,
  required Map<String, num> valores,
  required String aviso,
}) async {
  final mensageiro = ScaffoldMessenger.maybeOf(context);
  final desfazer = AppLocalizations.of(context).desfazer;
  final editor = ref.read(editorProvider.notifier);
  final validos = <DefinicaoParametro, num>{};
  for (final MapEntry(key: simbolo, value: valor) in valores.entries) {
    final p = definicao.parametro(simbolo);
    if (p != null) validos[p] = p.limitar(valor);
  }
  final nomes = {for (final p in validos.keys) p.simbolo: p.nome};
  final padroes = {for (final p in validos.keys) p.simbolo: p.padrao};
  final ponto = await editor.comDesfazer(() => editor.alterarParametros(
      bloco.posicao, {for (final e in validos.entries) e.key.simbolo: e.value},
      nomes: nomes, padroes: padroes));
  mensageiro
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(aviso),
      action: ponto == null ? null : SnackBarAction(label: desfazer, onPressed: () => editor.desfazer(ponto)),
    ));
}
