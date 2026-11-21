// No diálogo do controle, o atalho para quem não tem botão direito: o
// footswitch liga e desliga o bloco aberto; o pot e o pedal escolhem um
// parâmetro dele (o liga/desliga também vale, como nos presets reais).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../../aplicacao/provedores.dart';
import '../../l10n/app_localizations.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../../nucleo/modelo/controles_pedaleira.dart';
import '../../nucleo/modelo/edicao_controles.dart';
import '../tema/tokens.dart';
import '../textos.dart';
import 'painel_parametros.dart' show parametrosVisiveis;

class AtribuirDoBloco extends ConsumerWidget {
  const AtribuirDoBloco({super.key, required this.id});

  final IdControle id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final bloco = ref.watch(editorProvider.select((e) => e.blocoSelecionado));
    if (bloco == null) {
      return Text(l.ctlSemBlocoAberto,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Cores.textoSecundario));
    }
    final definicao = ref.watch(definicaoBlocoProvider(bloco.uri));
    final footswitch = id.tipo == TipoControle.footswitch;
    return Align(
      alignment: Alignment.centerLeft,
      child: OutlinedButton.icon(
        key: const ValueKey('atribuir-do-bloco'),
        icon: const Icon(Icons.add_link),
        label: Text(footswitch ? l.ctlFootswitchLigaBloco(id.numero).toUpperCase() : l.ctlAtribuirDoBloco),
        onPressed: () => footswitch
            ? ref.read(editorProvider.notifier).atribuirFootswitch(id, bloco.posicao, definicao.nome)
            : _escolher(context, ref, bloco, definicao),
      ),
    );
  }

  Future<void> _escolher(BuildContext context, WidgetRef ref, BlocoPreset bloco, DefinicaoBloco definicao) async {
    final l = AppLocalizations.of(context);
    final parametro = await showDialog<DefinicaoParametro>(
      context: context,
      builder: (contexto) => SimpleDialog(
        title: Text(l.ctlEscolherParametro(l.nomeDoBloco(definicao))),
        children: [
          _opcao(contexto, parametroBypass, l.ctlLigaDesliga),
          for (final p in parametrosVisiveis(definicao, bloco, nomeEstimado: l.faixaEstimada)) _opcao(contexto, p, p.nome),
        ],
      ),
    );
    if (parametro == null) return;
    final editor = ref.read(editorProvider.notifier);
    await (parametro.simbolo == simboloBypass
        ? editor.atribuirFootswitch(id, bloco.posicao, definicao.nome)
        : editor.atribuirParametro(id, bloco.posicao, parametro));
  }

  static Widget _opcao(BuildContext contexto, DefinicaoParametro parametro, String nome) => SimpleDialogOption(
        key: ValueKey('escolher-param-${parametro.simbolo}'),
        onPressed: () => Navigator.pop(contexto, parametro),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Medidas.alvoMinimo),
          child: Align(alignment: Alignment.centerLeft, child: Text(nome)),
        ),
      );
}
