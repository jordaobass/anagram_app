// Créditos e avisos. O crédito das imagens só aparece quando as miniaturas
// de terceiros (pasta opcional, fora do git) estão no app.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/provedores.dart';
import '../app_anagram.dart';
import '../componentes/seletor_pausa.dart';
import '../tema/tokens.dart';

class TelaCreditos extends ConsumerWidget {
  const TelaCreditos({super.key});

  static const autoria = ('Autor', 'jordao_bass · software livre, licença MIT. Gratuito, sem anúncios, '
      'sem compras no app e sem coleta de dados.');
  static const protocolo = ('Protocolo USB e catálogo de blocos',
      'Portado do projeto anagram-tone-maker, de basster6 — licença MIT (github.com/basster6/anagram-tone-maker).');
  static const artepropria = ('Arte dos blocos', 'Arte própria do app, por categoria de bloco.');
  static const fontes = ('Fontes', 'Barlow e Saira Stencil (SIL Open Font License) · Permanent Marker (Apache 2.0).');
  static const marca = ('Aviso', 'App não oficial, sem vínculo com a Darkglass Electronics. Anagram é marca do fabricante.');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final indice = ref.watch(indiceMiniaturasProvider).value;
    final imagens = indice == null || indice.vazio
        ? artepropria
        : ('Imagens dos blocos', '${indice.credito}. Blocos sem imagem usam arte própria, por categoria.');
    final itens = [autoria, protocolo, imagens, fontes, marca];
    final tema = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre e diagnóstico')),
      body: ListView(
        padding: const EdgeInsets.all(Espacos.xl),
        children: [
          Text(AppAnagram.titulo, style: tema.titleLarge),
          const SizedBox(height: Espacos.xl),
          for (final (titulo, texto) in itens) ...[
            Text(titulo.toUpperCase(), style: tema.labelLarge?.copyWith(color: Cores.tally)),
            const SizedBox(height: Espacos.xs),
            Text(texto, style: tema.bodyLarge),
            const SizedBox(height: Espacos.l),
          ],
          Text('DIAGNÓSTICO · PAUSA ENTRE RELATÓRIOS USB', style: tema.labelLarge?.copyWith(color: Cores.tally)),
          const SizedBox(height: Espacos.xs),
          Text('Compare 0, 2 e 10 ms e veja a "ida e volta" na barra e no log.', style: tema.bodyMedium),
          const SizedBox(height: Espacos.s),
          const Align(alignment: Alignment.centerLeft, child: SeletorPausa()),
        ],
      ),
    );
  }
}
