// Versão do app (e se o build traz a arte da pedaleira), discreta e sempre à
// vista: na barra de cima e na tela Sobre.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/versao_app.dart';
import '../tema/tokens.dart';

class RotuloVersao extends ConsumerWidget {
  const RotuloVersao({super.key, this.estilo});

  /// Sem estilo, usa o texto pequeno da barra.
  final TextStyle? estilo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rotulo = ref.watch(rotuloVersaoProvider);
    if (rotulo.isEmpty) return const SizedBox.shrink();
    return Text(
      rotulo,
      key: const ValueKey('versao-app'),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: estilo ?? Theme.of(context).textTheme.labelSmall?.copyWith(color: Cores.textoSecundario),
    );
  }
}
