// Cenas 1–3 como os snapshots do HX: trocar de cena soa na hora.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../tema/tokens.dart';

class SeletorCenas extends ConsumerWidget {
  const SeletorCenas({super.key});

  static const cenas = [1, 2, 3];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documento = ref.watch(editorProvider.select((e) => e.atual));
    if (documento == null) return const SizedBox.shrink();
    final controlador = ref.read(editorProvider.notifier);
    return Row(children: [
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
    ]);
  }
}

class _BotaoCena extends StatelessWidget {
  const _BotaoCena({required this.numero, required this.nome, required this.ativa, required this.aoTocar});

  final int numero;
  final String nome;
  final bool ativa;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final corTexto = ativa ? Cores.sobreTally : Cores.texto;
    return Semantics(
      selected: ativa,
      button: true,
      label: 'Cena $numero, $nome',
      child: Material(
        color: ativa ? Cores.tally : Cores.painelElevado,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Raios.controle),
          side: BorderSide(color: ativa ? Cores.tally : Cores.filete),
        ),
        child: InkWell(
          key: ValueKey('cena-$numero'),
          borderRadius: BorderRadius.circular(Raios.controle),
          onTap: aoTocar,
          child: _rotulo(tema, corTexto),
        ),
      ),
    );
  }

  Widget _rotulo(TextTheme tema, Color corTexto) => ConstrainedBox(
        constraints: const BoxConstraints(minHeight: Medidas.alvoMinimo + Espacos.s),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Espacos.m, vertical: Espacos.xs),
          child: Row(children: [
            Text('$numero', style: tema.displaySmall?.copyWith(color: corTexto, fontSize: tema.titleLarge?.fontSize)),
            const SizedBox(width: Espacos.s),
            Expanded(
              child: Text(nome.toUpperCase(),
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: tema.labelLarge?.copyWith(color: corTexto)),
            ),
          ]),
        ),
      );
}
