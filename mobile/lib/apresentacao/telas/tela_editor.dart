// Tela única do editor. Paisagem ampla: lista de presets à esquerda.
// Celular: a lista vira rota própria, aberta pelo slot.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_conexao.dart';
import '../../aplicacao/estado/controlador_editor.dart';
import '../../aplicacao/estado/estado_conexao.dart';
import '../componentes/atalhos_editor.dart';
import '../componentes/barra_conexao.dart';
import '../componentes/editor_principal.dart';
import '../componentes/lista_presets.dart';
import '../componentes/painel_conectar.dart';
import '../rotas.dart';
import '../tema/tokens.dart';

class TelaEditor extends ConsumerWidget {
  const TelaEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conectada = ref.watch(conexaoProvider) is Conectada;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(builder: (context, restricoes) {
          final amplo = restricoes.maxWidth >= Quebras.amplo && restricoes.maxHeight >= Quebras.alturaAmpla;
          final larguraLista =
              restricoes.maxWidth >= Quebras.listaLarga ? Medidas.listaPresetsLargura : Medidas.listaPresetsLarguraEstreita;
          return Column(children: [
            BarraConexao(compacta: !amplo),
            const _Aviso(),
            Expanded(
              child: conectada ? AtalhosEditor(listaEmOutraTela: !amplo, child: _conteudo(context, amplo, larguraLista)) : const PainelConectar(),
            ),
          ]);
        }),
      ),
    );
  }

  Widget _conteudo(BuildContext context, bool amplo, double larguraLista) {
    if (!amplo) {
      return EditorPrincipal(compacto: true, aoAbrirLista: () => const RotaPresets().push<void>(context));
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SizedBox(width: larguraLista, child: const ListaPresets()),
      const VerticalDivider(width: Medidas.filete),
      Expanded(
        child: LayoutBuilder(
          builder: (context, restricoes) =>
              EditorPrincipal(compacto: restricoes.maxWidth < Quebras.editorAmplo),
        ),
      ),
    ]);
  }
}

class _Aviso extends ConsumerWidget {
  const _Aviso();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aviso = ref.watch(editorProvider.select((e) => e.aviso));
    if (aviso == null) return const SizedBox.shrink();
    return Container(
      key: const ValueKey('aviso-editor'),
      color: Cores.fitaAlerta,
      padding: const EdgeInsets.symmetric(horizontal: Espacos.l),
      child: Row(children: [
        Expanded(
          child: Text(aviso, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Cores.sobreAlerta)),
        ),
        IconButton(
          tooltip: 'Fechar aviso',
          color: Cores.sobreAlerta,
          icon: const Icon(Icons.close),
          onPressed: ref.read(editorProvider.notifier).limparAviso,
        ),
      ]),
    );
  }
}
