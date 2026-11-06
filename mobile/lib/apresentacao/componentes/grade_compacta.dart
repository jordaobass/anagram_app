// Cadeia no celular: só as casas ocupadas (em ordem) e uma casa livre por
// linha para colar, quebrando em fileiras. Nada fica escondido à direita.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../../nucleo/modelo/documento_preset.dart';
import '../tema/tokens.dart';
import 'grade_blocos.dart';

class GradeCompacta extends ConsumerWidget {
  const GradeCompacta({super.key});

  /// No celular, 4 por fileira; no iPad em retrato cabem mais, sem a casa
  /// passar do tamanho máximo da grade ampla.
  static const casasPorFileiraMinimo = 4;

  static int casasPorFileira(double largura) =>
      ((largura + Espacos.s) / (Medidas.casaMaxima + Espacos.s)).ceil().clamp(casasPorFileiraMinimo, PosicaoBloco.casasPorLinha);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documento = ref.watch(editorProvider.select((e) => e.atual));
    if (documento == null) return const SizedBox.shrink();
    return LayoutBuilder(builder: (context, restricoes) {
      final porFileira = casasPorFileira(restricoes.maxWidth);
      final largura = (restricoes.maxWidth - (porFileira - 1) * Espacos.s) / porFileira;
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (final linha in const [1, 2]) ..._linha(context, ref, documento, linha, largura),
      ]);
    });
  }

  List<Widget> _linha(BuildContext context, WidgetRef ref, DocumentoPreset documento, int linha, double largura) {
    final tema = Theme.of(context).textTheme;
    final casas = [for (final b in documento.blocosDaLinha(linha)) b.posicao.casa];
    final livre = _primeiraLivre(casas);
    return [
      Padding(
        padding: const EdgeInsets.only(top: Espacos.xs, bottom: Espacos.xs),
        child: Text(linha == 1 ? 'LINHA 1' : 'LINHA 2 · PARALELA', style: tema.labelSmall),
      ),
      Wrap(spacing: Espacos.s, runSpacing: Espacos.s, children: [
        for (final casa in [...casas, ?livre])
          casaDaGrade(context, ref, documento, PosicaoBloco(linha, casa), largura),
      ]),
    ];
  }

  /// Primeira casa vazia depois da última ocupada (ou a 1 numa linha vazia).
  static int? _primeiraLivre(List<int> ocupadas) {
    final depois = ocupadas.isEmpty ? 1 : ocupadas.last + 1;
    return depois <= PosicaoBloco.casasPorLinha ? depois : null;
  }
}
