// Mudar a ordem da cadeia arrastando: a casa ocupada é a alça e qualquer casa
// é um alvo (vazia recebe, ocupada troca). Com mouse o arrasto começa na hora;
// no toque, segurando, para não brigar com a rolagem da grade. Split e Merge
// também se arrastam; soltar onde a regra recusa (linha 2, Split depois do
// Merge) acende o alvo em vermelho e explica, em vez de não fazer nada calado.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../../nucleo/catalogo/biblioteca_blocos.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../../l10n/app_localizations.dart';
import '../tema/tokens.dart';

/// Computador (mouse/trackpad): arrasto imediato. Celular e tablet: segurar.
bool get arrastoComMouse => switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS || TargetPlatform.fuchsia => false,
      _ => true,
    };

class CasaArrastavel extends ConsumerWidget {
  const CasaArrastavel({super.key, required this.posicao, required this.largura, required this.child});

  final PosicaoBloco posicao;
  final double largura;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documento = ref.watch(editorProvider.select((e) => e.atual));
    final bloco = documento?.bloco(posicao);
    RecusaMover? recusa(PosicaoBloco de) => documento == null ? RecusaMover.semOrigem : recusaAoMover(documento, de, posicao);
    return DragTarget<PosicaoBloco>(
      onWillAcceptWithDetails: (d) => _explicavel(recusa(d.data)),
      onAcceptWithDetails: (d) => _soltar(context, ref, d.data, recusa(d.data)),
      builder: (context, candidatos, _) {
        final recusado = candidatos.any((de) => de != null && recusa(de) != null);
        final alvo = _realcar(child, context.cores, ativo: candidatos.isNotEmpty, recusado: recusado);
        return bloco == null ? alvo : _alca(alvo);
      },
    );
  }

  /// O alvo aceita o que pode mover e também o que a regra do roteamento
  /// recusa (para explicar); a própria casa e a origem vazia, não.
  static bool _explicavel(RecusaMover? recusa) =>
      recusa == null || recusa == RecusaMover.roteamentoForaDaLinha1 || recusa == RecusaMover.splitDepoisDoMerge;

  void _soltar(BuildContext context, WidgetRef ref, PosicaoBloco de, RecusaMover? recusa) {
    if (recusa == null) {
      ref.read(editorProvider.notifier).moverBloco(de, posicao);
      return;
    }
    final l = AppLocalizations.of(context);
    final texto = recusa == RecusaMover.splitDepoisDoMerge ? l.smOrdemInvalida : l.smSoNaLinha1;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Widget _alca(Widget alvo) {
    final naMao = Material(
      color: Colors.transparent,
      child: Opacity(opacity: Opacidades.blocoArrastado, child: SizedBox(width: largura, child: child)),
    );
    final sombra = Opacity(opacity: Opacidades.origemDoArrasto, child: alvo);
    return arrastoComMouse
        ? Draggable<PosicaoBloco>(data: posicao, feedback: naMao, childWhenDragging: sombra, child: alvo)
        : LongPressDraggable<PosicaoBloco>(data: posicao, feedback: naMao, childWhenDragging: sombra, child: alvo);
  }

  /// Contorno no tally sobre a casa que vai receber o bloco; no vermelho de
  /// erro quando soltar ali seria recusado.
  static Widget _realcar(Widget casa, Paleta cores, {required bool ativo, required bool recusado}) => DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Raios.controle),
          border: Border.all(
              color: !ativo ? Colors.transparent : (recusado ? cores.erro : cores.tallyTinta), width: Medidas.contornoSelecao),
        ),
        child: casa,
      );
}
