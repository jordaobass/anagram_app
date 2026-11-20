// Créditos, avisos, diagnóstico e idioma. O crédito das imagens só aparece
// quando as miniaturas de terceiros (pasta opcional, fora do git) estão no app.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/arte/indice_miniaturas.dart';
import '../../aplicacao/provedores.dart';
import '../../l10n/app_localizations.dart';
import '../app_anagram.dart';
import '../componentes/rotulo_versao.dart';
import '../componentes/seletor_idioma.dart';
import '../componentes/seletor_pausa.dart';
import '../tema/tokens.dart';

class TelaCreditos extends ConsumerWidget {
  const TelaCreditos({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final itens = _itens(l, ref.watch(indiceMiniaturasProvider).value);
    final tema = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(l.sobreTitulo)),
      body: ListView(
        padding: const EdgeInsets.all(Espacos.xl),
        children: [
          Text(AppAnagram.titulo, style: tema.titleLarge),
          RotuloVersao(estilo: tema.bodyMedium?.copyWith(color: Cores.textoSecundario)),
          const SizedBox(height: Espacos.xl),
          for (final (titulo, texto) in itens) ..._secao(tema, titulo, Text(texto, style: tema.bodyLarge)),
          Text(l.diagnosticoPausa, style: tema.labelLarge?.copyWith(color: Cores.tally)),
          const SizedBox(height: Espacos.xs),
          Text(l.diagnosticoPausaTexto, style: tema.bodyMedium),
          const SizedBox(height: Espacos.s),
          const Align(alignment: Alignment.centerLeft, child: SeletorPausa()),
          const SizedBox(height: Espacos.xl),
          ..._secao(tema, l.idioma, const Align(alignment: Alignment.centerLeft, child: SeletorIdioma())),
        ],
      ),
    );
  }

  static List<(String, String)> _itens(AppLocalizations l, IndiceMiniaturas? indice) => [
        (l.creditoAutorTitulo, l.creditoAutor),
        (l.creditoProtocoloTitulo, l.creditoProtocolo),
        indice == null || indice.vazio
            ? (l.creditoArteTitulo, l.creditoArtePropria)
            : (l.creditoImagensTitulo, l.creditoImagens(indice.credito)),
        (l.creditoFontesTitulo, l.creditoFontes),
        (l.creditoAvisoTitulo, l.creditoAviso),
      ];

  static List<Widget> _secao(TextTheme tema, String titulo, Widget conteudo) => [
        Text(titulo.toUpperCase(), style: tema.labelLarge?.copyWith(color: Cores.tally)),
        const SizedBox(height: Espacos.xs),
        conteudo,
        const SizedBox(height: Espacos.l),
      ];
}
