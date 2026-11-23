// "CONTROLAR: TODAS AS CENAS / SÓ A CENA ATIVA", sob as cenas: o botão que a
// Anagram mostra no modo Scene (manual KosmOS 1.17, "Controlling All Scenes"
// / "Controlling Active Scene"; DECISOES CE1). Decide quais cenas o knob, o
// campo de valor, o voltar ao padrão e o liga/desliga do bloco mudam. Mesmo
// desenho dos botões de cena (BotaoTally), mais baixo; a escolha fica guardada.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/escopo_cenas.dart';
import '../../l10n/app_localizations.dart';
import '../../nucleo/modelo/cenas_do_bloco.dart';
import '../tema/tokens.dart';
import 'botao_tally.dart';

class ChaveControlarCenas extends ConsumerWidget {
  const ChaveControlarCenas({super.key});

  static const _ordem = [EscopoCenas.todasAsCenas, EscopoCenas.soNaCena];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final escolhido = ref.watch(escopoCenasProvider);
    final rotulo = ExcludeSemantics(
      child: Text(l.ceControlar,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Cores.textoSecundario)),
    );
    _Opcao opcao(EscopoCenas escopo) => _Opcao(
          escopo: escopo,
          ativa: escopo == escolhido,
          aoTocar: () => ref.read(escopoCenasProvider.notifier).definir(escopo),
        );
    return LayoutBuilder(builder: (context, restricoes) {
      if (restricoes.maxWidth >= Medidas.larguraChaveControlarEmLinha) {
        return Row(mainAxisSize: MainAxisSize.min, children: [
          rotulo,
          // Flexible: em espanhol as opções são longas e quebram em vez de vazar
          for (final escopo in _ordem) ...[const SizedBox(width: Espacos.s), Flexible(child: opcao(escopo))],
        ]);
      }
      // estreito (celular, janela pequena): as opções dividem a linha inteira
      return SizedBox(
        width: restricoes.maxWidth,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          rotulo,
          const SizedBox(height: Espacos.xxs),
          Row(children: [
            for (final escopo in _ordem) ...[
              if (escopo != _ordem.first) const SizedBox(width: Espacos.s),
              Expanded(child: opcao(escopo)),
            ],
          ]),
        ]),
      );
    });
  }
}

class _Opcao extends StatelessWidget {
  const _Opcao({required this.escopo, required this.ativa, required this.aoTocar});

  final EscopoCenas escopo;
  final bool ativa;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final (nome, dica) = switch (escopo) {
      EscopoCenas.todasAsCenas => (l.ceTodas, l.ceTodasDica),
      EscopoCenas.soNaCena => (l.ceAtiva, l.ceAtivaDica),
    };
    final estilo = Theme.of(context).textTheme.labelMedium?.copyWith(color: BotaoTally.corDoTexto(ativo: ativa));
    return Tooltip(
      message: dica,
      child: BotaoTally(
        chave: ValueKey('controlar-${escopo.name}'),
        ativo: ativa,
        rotuloSemantico: '${l.ceControlar}: $nome. $dica',
        aoTocar: aoTocar,
        alturaMinima: Medidas.alvoMinimo,
        filho: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Espacos.m),
          child: Center(widthFactor: 1, child: Text(nome, textAlign: TextAlign.center, style: estilo)),
        ),
      ),
    );
  }
}
