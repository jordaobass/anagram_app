// Biblioteca de efeitos: abre ao tocar no "+" de uma casa vazia. Os blocos do
// catálogo vêm por categoria, com a arte de cada um e busca por nome.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../../aplicacao/provedores.dart';
import '../../nucleo/catalogo/biblioteca_blocos.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../tema/tokens.dart';
import 'arte_bloco.dart';

/// Escolhe um efeito e põe na casa [posicao]. Fechar sem escolher não muda nada.
Future<void> adicionarEfeitoNaCasa(BuildContext context, WidgetRef ref, PosicaoBloco posicao) async {
  final escolhido = await showDialog<DefinicaoBloco>(
    context: context,
    builder: (_) => _BibliotecaEfeitos(posicao: posicao),
  );
  if (escolhido != null) await ref.read(editorProvider.notifier).adicionarBloco(posicao, escolhido);
}

class _BibliotecaEfeitos extends ConsumerStatefulWidget {
  const _BibliotecaEfeitos({required this.posicao});

  final PosicaoBloco posicao;

  @override
  ConsumerState<_BibliotecaEfeitos> createState() => _EstadoBiblioteca();
}

class _EstadoBiblioteca extends ConsumerState<_BibliotecaEfeitos> {
  String _busca = '';

  @override
  Widget build(BuildContext context) {
    final catalogo = ref.watch(catalogoProvider).value;
    final grupos = catalogo == null ? const <GrupoBiblioteca>[] : blocosDaBiblioteca(catalogo, busca: _busca);
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Medidas.larguraBiblioteca, maxHeight: Medidas.alturaBiblioteca),
        child: Padding(
          padding: const EdgeInsets.all(Espacos.l),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _cabecalho(context),
            const SizedBox(height: Espacos.m),
            _campoBusca(),
            const SizedBox(height: Espacos.m),
            Expanded(child: catalogo == null ? const Center(child: CircularProgressIndicator()) : _lista(context, grupos)),
          ]),
        ),
      ),
    );
  }

  Widget _cabecalho(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Adicionar efeito', style: tema.titleLarge),
      Text('Linha ${widget.posicao.linha}, casa ${widget.posicao.casa}', style: tema.bodySmall),
    ]);
  }

  Widget _campoBusca() => TextField(
        key: const ValueKey('busca-efeito'),
        autofocus: true,
        decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Buscar pelo nome'),
        onChanged: (texto) => setState(() => _busca = texto),
      );

  Widget _lista(BuildContext context, List<GrupoBiblioteca> grupos) {
    if (grupos.isEmpty) {
      return Center(child: Text('Nenhum efeito com "$_busca".', style: Theme.of(context).textTheme.bodyMedium));
    }
    return ListView(children: [
      for (final grupo in grupos) ...[
        _tituloCategoria(context, grupo.categoria),
        for (final bloco in grupo.blocos) _ItemEfeito(definicao: bloco),
      ],
    ]);
  }

  Widget _tituloCategoria(BuildContext context, String categoria) => Padding(
        padding: const EdgeInsets.only(top: Espacos.m, bottom: Espacos.xs),
        child: Text(categoria.toUpperCase(),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Cores.textoSecundario)),
      );
}

class _ItemEfeito extends StatelessWidget {
  const _ItemEfeito({required this.definicao});

  final DefinicaoBloco definicao;

  @override
  Widget build(BuildContext context) => ListTile(
        key: ValueKey('efeito-${definicao.uri}'),
        contentPadding: EdgeInsets.zero,
        leading: ArteBlocoWidget(definicao: definicao, tamanho: Medidas.alvoMinimo),
        title: Text(definicao.nome),
        subtitle: Text(definicao.familia.rotulo),
        trailing: Container(width: Medidas.fitaCategoria, height: Medidas.alvoMinimo, color: Cores.daFamilia(definicao.familia)),
        onTap: () => Navigator.pop(context, definicao),
      );
}
