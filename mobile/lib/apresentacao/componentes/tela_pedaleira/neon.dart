// O neon do Axioma: o traço com halo (desfoque largo na cor, o traço e um
// núcleo quase branco) e o pulso de brilho. O pulso é o único movimento do
// painel: duas respirações lentas quando ele abre, depois parado; com
// "reduzir movimento" do sistema, não pulsa.
import 'package:flutter/material.dart';

import '../../tema/paletas_painel.dart';

/// Pinta [caminho] como tubo de neon. [brilho] de 0 (sem halo) a 1 (pico).
void tracoNeon(Canvas canvas, Path caminho, Color cor, {double largura = 2, double brilho = 1}) {
  if (brilho > 0) {
    canvas.drawPath(
        caminho,
        Paint()
          ..color = cor.withValues(alpha: 0.75 * brilho)
          ..style = PaintingStyle.stroke
          ..strokeWidth = largura * 3
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, CoresNeon.espalhamento * brilho));
  }
  final traco = Paint()
    ..color = cor
    ..style = PaintingStyle.stroke
    ..strokeWidth = largura
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;
  canvas.drawPath(caminho, traco);
  if (brilho > 0) {
    canvas.drawPath(caminho, traco
      ..color = CoresNeon.nucleo.withValues(alpha: 0.6 * brilho)
      ..strokeWidth = largura * 0.35);
  }
}

/// O brilho atual do neon (0,8 a 1) para quem pinta abaixo.
class BrilhoNeon extends InheritedWidget {
  const BrilhoNeon({super.key, required this.valor, required super.child});

  final double valor;

  static double of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<BrilhoNeon>()?.valor ?? 1;

  @override
  bool updateShouldNotify(BrilhoNeon antigo) => antigo.valor != valor;
}

/// Duas respirações de brilho ao abrir o painel; parado depois e com
/// "reduzir movimento".
class PulsoNeon extends StatefulWidget {
  const PulsoNeon({super.key, required this.child});

  final Widget child;

  @override
  State<PulsoNeon> createState() => _EstadoPulsoNeon();
}

class _EstadoPulsoNeon extends State<PulsoNeon> with SingleTickerProviderStateMixin {
  late final _controle = AnimationController(vsync: this, duration: _respiracao);
  var _iniciado = false;

  static const _respiracao = Duration(milliseconds: 1400);
  static const _respiracoes = 4;
  static const _queda = 0.2;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_iniciado || MediaQuery.disableAnimationsOf(context)) return;
    _iniciado = true;
    _controle.repeat(reverse: true, count: _respiracoes);
  }

  @override
  void dispose() {
    _controle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controle,
        builder: (context, filho) =>
            BrilhoNeon(valor: 1 - _queda * Curves.easeInOut.transform(_controle.value), child: filho!),
        child: widget.child,
      );
}
