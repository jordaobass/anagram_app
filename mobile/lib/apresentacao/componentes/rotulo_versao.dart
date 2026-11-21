// Versão do app (e se o build traz a arte da pedaleira), na tela Sobre: é lá
// que a pessoa confere qual build abriu.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/versao_app.dart';
import '../tema/tokens.dart';
import '../../l10n/app_localizations.dart';

class RotuloVersao extends ConsumerWidget {
  const RotuloVersao({super.key, this.estilo});

  /// Sem estilo, usa o texto pequeno da barra.
  final TextStyle? estilo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (:versao, :comArte) = ref.watch(rotuloVersaoProvider);
    if (versao.isEmpty) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    return Text(
      comArte ? l.versaoAppComArte(versao) : l.versaoApp(versao),
      key: const ValueKey('versao-app'),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: estilo ?? Theme.of(context).textTheme.labelSmall?.copyWith(color: Cores.textoSecundario),
    );
  }
}
