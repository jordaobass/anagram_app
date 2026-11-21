// Toque simples na hora e toque duplo por cima dele. O onDoubleTap do Flutter
// segura o toque simples até o prazo do duplo (300 ms) para saber se vem um
// segundo: selecionar um bloco ficaria lento. Aqui o primeiro toque já chega
// e, se o segundo vier dentro do prazo, ele vira o toque duplo.
import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

class ToqueDuplo extends StatefulWidget {
  const ToqueDuplo({super.key, this.aoTocar, this.aoTocarDuas, required this.child});

  final VoidCallback? aoTocar;
  final VoidCallback? aoTocarDuas;
  final Widget child;

  @override
  State<ToqueDuplo> createState() => _EstadoToqueDuplo();
}

class _EstadoToqueDuplo extends State<ToqueDuplo> {
  /// Aberto entre o primeiro toque e o fim do prazo do toque duplo.
  Timer? _prazo;

  void _aoTocar() {
    final duas = widget.aoTocarDuas;
    if (_prazo?.isActive ?? false) {
      _prazo!.cancel();
      _prazo = null;
      duas?.call();
      return;
    }
    widget.aoTocar?.call();
    if (duas != null) _prazo = Timer(kDoubleTapTimeout, () => _prazo = null);
  }

  @override
  void dispose() {
    _prazo?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      GestureDetector(behavior: HitTestBehavior.opaque, onTap: _aoTocar, child: widget.child);
}
