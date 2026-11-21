// A linha 2 sem linha paralela: no lugar de doze encaixes que não recebem
// sinal, uma faixa tracejada da largura da linha que diz o que ela é e cria o
// Split e o Merge com um toque. Era o que faltava para achar o caminho
// paralelo — o botão de texto embaixo da grade passava despercebido.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../../l10n/app_localizations.dart';
import '../tema/tokens.dart';
import 'acoes_linha_paralela.dart';
import 'pintor_encaixe.dart';

class FaixaLinhaParalela extends ConsumerWidget {
  const FaixaLinhaParalela({super.key, required this.altura});

  final double altura;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final ocupado = ref.watch(editorProvider.select((e) => e.ocupado));
    final estilo = Theme.of(context).textTheme.labelLarge?.copyWith(color: Cores.textoSecundario);
    return Tooltip(
      message: l.lpCriarDica,
      child: Semantics(
        button: true,
        label: l.smFaixaCriar,
        child: InkWell(
          key: const ValueKey('faixa-criar-linha-paralela'),
          borderRadius: BorderRadius.circular(Raios.controle),
          onTap: ocupado ? null : () => criarLinhaParalelaComAviso(context, ref),
          child: SizedBox(
            height: altura,
            width: double.infinity,
            child: CustomPaint(
              painter: const PintorEncaixe(),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Espacos.m),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.call_split, color: Cores.sinalSplit),
                    const SizedBox(width: Espacos.s),
                    Flexible(child: Text(l.smFaixaCriar, style: estilo, textAlign: TextAlign.center)),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
