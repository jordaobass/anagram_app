// Cadeia no celular: as casas na posição real, da 1 até a seguinte à última
// ocupada, quebrando em fileiras. Os buracos entre blocos aparecem como
// encaixe com "+" (como na grade ampla), para o bloco não parecer colado no
// vizinho e para dar para pôr efeito no meio. Nada fica escondido à direita.
// O fio do sinal liga as caixas de cada fileira; a linha 2 só tem fio com
// split, e em amarelo, a cor da derivação na grade ampla.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../../nucleo/catalogo/linha_paralela.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../../nucleo/modelo/documento_preset.dart';
import '../tema/tokens.dart';
import 'grade_blocos.dart';
import 'pintor_linha_sinal.dart';
import '../../l10n/app_localizations.dart';

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
      final comSplit = temLinhaParalela(documento);
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (final linha in const [1, 2])
          ..._linha(context, ref, documento, linha, _Fileiras(porFileira, largura,
              comFio: linha == 1 || comSplit, cor: linha == 1 ? context.cores.aluminio : context.cores.sinalSplit)),
      ]);
    });
  }

  List<Widget> _linha(BuildContext context, WidgetRef ref, DocumentoPreset documento, int linha, _Fileiras fileiras) {
    final tema = Theme.of(context).textTheme;
    final casas = casasVisiveis([for (final b in documento.blocosDaLinha(linha)) b.posicao.casa]);
    final geometria = GradeBlocos.geometriaDaCasa(fileiras.largura);
    return [
      Padding(
        padding: const EdgeInsets.only(top: Espacos.xs, bottom: Espacos.xs),
        child: Text(linha == 1 ? AppLocalizations.of(context).linha1 : AppLocalizations.of(context).linha2Paralela,
            style: tema.labelSmall),
      ),
      CustomPaint(
        painter: fileiras.comFio ? _PintorFileiras(fileiras, geometria, casas.length) : null,
        child: Wrap(spacing: Espacos.s, runSpacing: Espacos.s, children: [
          for (final casa in casas)
            // altura fixa da fileira (o fio passa no centro das caixas), com a
            // casa no topo: esticada, o encaixe vazio viraria um retângulo alto
            SizedBox(
              width: fileiras.largura,
              height: geometria.alturaLinha,
              child: Align(
                alignment: Alignment.topCenter,
                child: casaDaGrade(context, ref, documento, PosicaoBloco(linha, casa), fileiras.largura),
              ),
            ),
        ]),
      ),
    ];
  }

  /// Da casa 1 até a seguinte à última ocupada (a 1 numa linha vazia), sem
  /// passar da última casa da linha.
  static List<int> casasVisiveis(List<int> ocupadas) {
    final ultima = ocupadas.isEmpty ? 0 : ocupadas.reduce((a, b) => a > b ? a : b);
    final ate = (ultima + 1).clamp(1, PosicaoBloco.casasPorLinha);
    return [for (var casa = 1; casa <= ate; casa++) casa];
  }
}

/// Como as casas se arrumam: quantas por fileira, de que largura e se a linha tem fio.
class _Fileiras {
  const _Fileiras(this.porFileira, this.largura, {required this.comFio, required this.cor});

  final int porFileira;
  final double largura;
  final bool comFio;
  final Color cor;
}

/// O fio de cada fileira, do centro da primeira caixa ao da última: entre as
/// caixas (opacas) sobra a ligação curta de pedal a pedal.
class _PintorFileiras extends CustomPainter {
  const _PintorFileiras(this.fileiras, this.geometria, this.quantidade);

  final _Fileiras fileiras;
  final GeometriaGrade geometria;
  final int quantidade;

  @override
  void paint(Canvas canvas, Size size) {
    final fio = Paint()
      ..color = fileiras.cor
      ..strokeWidth = Medidas.linhaSinal;
    final passo = fileiras.largura + Espacos.s;
    for (var inicio = 0; inicio < quantidade; inicio += fileiras.porFileira) {
      final naFileira = (quantidade - inicio).clamp(1, fileiras.porFileira);
      if (naFileira < 2) continue;
      final y = (inicio ~/ fileiras.porFileira) * (geometria.alturaLinha + Espacos.s) + geometria.centroArte;
      canvas.drawLine(Offset(fileiras.largura / 2, y), Offset((naFileira - 1) * passo + fileiras.largura / 2, y), fio);
    }
  }

  @override
  bool shouldRepaint(_PintorFileiras antigo) =>
      antigo.quantidade != quantidade || antigo.fileiras.largura != fileiras.largura || antigo.fileiras.cor != fileiras.cor;
}
