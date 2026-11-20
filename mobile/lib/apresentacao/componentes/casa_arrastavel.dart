// Mudar a ordem da cadeia arrastando: a casa ocupada é a alça e qualquer casa
// é um alvo (vazia recebe, ocupada troca). Com mouse o arrasto começa na hora;
// no toque, segurando, para não brigar com a rolagem da grade.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../../nucleo/catalogo/biblioteca_blocos.dart';
import '../../nucleo/modelo/bloco_preset.dart';
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
    return DragTarget<PosicaoBloco>(
      onWillAcceptWithDetails: (d) => documento != null && podeMover(documento, d.data, posicao),
      onAcceptWithDetails: (d) => ref.read(editorProvider.notifier).moverBloco(d.data, posicao),
      builder: (context, candidatos, _) {
        final alvo = _realcar(child, ativo: candidatos.isNotEmpty);
        // split e merge não saem do lugar: não viram alça
        return bloco == null || ehBlocoDeRoteamento(bloco.uri) ? alvo : _alca(alvo);
      },
    );
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

  /// Contorno no tally sobre a casa que vai receber o bloco.
  static Widget _realcar(Widget casa, {required bool ativo}) => DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Raios.controle),
          border: Border.all(color: ativo ? Cores.tally : Colors.transparent, width: Medidas.contornoSelecao),
        ),
        child: casa,
      );
}
