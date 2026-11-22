// Versão, créditos e avisos; o idioma e a pausa USB ficam em Configurações.
// A versão fica só aqui (a barra de cima já tem o essencial) e diz se o
// build traz a arte da pedaleira.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/arte/indice_miniaturas.dart';
import '../../aplicacao/provedores.dart';
import '../../l10n/app_localizations.dart';
import '../app_anagram.dart';
import '../componentes/rotulo_versao.dart';
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
        ],
      ),
    );
  }

  static List<(String, String)> _itens(AppLocalizations l, IndiceMiniaturas? indice) => [
        (l.creditoAutorTitulo, l.creditoAutor),
        (l.creditoProtocoloTitulo, l.creditoProtocolo),
        indice == null || indice.vazio
            ? (l.creditoArteTitulo, l.creditoArtePropria)
            : (l.creditoImagensTitulo, [l.creditoImagens(indice.credito), ...indice.creditosAdicionais].join('\n')),
        (l.creditoFontesTitulo, l.creditoFontes),
        (l.creditoAvisoTitulo, l.creditoAviso),
      ];

  static List<Widget> _secao(TextTheme tema, String titulo, Widget conteudo) => [
        Text(titulo.toUpperCase(), style: _estiloTitulo(tema)),
        const SizedBox(height: Espacos.xs),
        conteudo,
        const SizedBox(height: Espacos.l),
      ];

  /// Título de seção em alumínio: o âmbar é só de seleção e ação (DESIGN.md).
  static TextStyle? _estiloTitulo(TextTheme tema) => tema.labelLarge?.copyWith(color: Cores.aluminioClaro);
}
