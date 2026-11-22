// Cenas 1–3 como os snapshots do HX: trocar de cena soa na hora. À direita
// delas, as pílulas do modo dos footswitches; sem largura, logo abaixo.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../tema/tokens.dart';
import '../../l10n/app_localizations.dart';
import 'botao_tally.dart';
import 'pilulas_modo_footswitches.dart';

class SeletorCenas extends ConsumerWidget {
  const SeletorCenas({super.key});

  static const cenas = [1, 2, 3];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documento = ref.watch(editorProvider.select((e) => e.atual));
    if (documento == null) return const SizedBox.shrink();
    final controlador = ref.read(editorProvider.notifier);
    return LayoutBuilder(builder: (context, restricoes) {
      final aoLado = restricoes.maxWidth >= Medidas.larguraCenasComModo;
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          for (final cena in cenas) ...[
            if (cena > 1) const SizedBox(width: Espacos.s),
            Expanded(
              child: _BotaoCena(
                numero: cena,
                nome: documento.nomeDaCena(cena),
                ativa: documento.cenaAtiva == cena,
                aoTocar: () => controlador.escolherCena(cena),
              ),
            ),
          ],
          if (aoLado) const PilulasModoFootswitches(espacoAntes: Espacos.m),
        ]),
        if (!aoLado) const Align(alignment: Alignment.centerRight, child: PilulasModoFootswitches()),
        const AvisoErroModoFootswitches(),
      ]);
    });
  }
}

class _BotaoCena extends StatelessWidget {
  const _BotaoCena({required this.numero, required this.nome, required this.ativa, required this.aoTocar});

  final int numero;

  /// Nome que o preset deu à cena; sem nome, o botão mostra "1 CENA" em vez
  /// de "1 CENA 1".
  final String? nome;
  final bool ativa;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return BotaoTally(
      chave: ValueKey('cena-$numero'),
      ativo: ativa,
      rotuloSemantico: l.cenaSemantica(numero, nome ?? l.cenaPadrao(numero)),
      aoTocar: aoTocar,
      alturaMinima: Medidas.alvoMinimo + Espacos.s,
      filho: _rotulo(Theme.of(context).textTheme, BotaoTally.corDoTexto(context.cores, ativo: ativa), nome ?? l.uiCena),
    );
  }

  Widget _rotulo(TextTheme tema, Color corTexto, String texto) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: Espacos.m, vertical: Espacos.xs),
        child: Row(children: [
          Text('$numero', style: tema.displaySmall?.copyWith(color: corTexto, fontSize: tema.titleLarge?.fontSize)),
          const SizedBox(width: Espacos.s),
          Expanded(
            child: Text(texto.toUpperCase(),
                maxLines: 1, overflow: TextOverflow.ellipsis, style: tema.labelLarge?.copyWith(color: corTexto)),
          ),
        ]),
      );
}
