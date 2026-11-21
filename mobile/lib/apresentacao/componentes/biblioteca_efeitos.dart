// Biblioteca de efeitos: abre ao tocar no "+" de uma casa vazia. Os blocos do
// catálogo vêm por família (drive, modulação, delay…), com a arte de cada um,
// busca por nome e filtro por família. Split e Merge estão nos utilitários
// como qualquer efeito; o que não pode entrar nesta casa aparece apagado,
// com o motivo, em vez de sumir.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../../aplicacao/provedores.dart';
import '../../nucleo/catalogo/biblioteca_blocos.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/catalogo/familia_bloco.dart';
import '../../nucleo/catalogo/linha_paralela.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../tema/tokens.dart';
import 'acoes_roteamento.dart';
import 'arte_bloco.dart';
import '../../l10n/app_localizations.dart';
import '../textos.dart';

/// Escolhe um efeito e põe na casa [posicao]. Fechar sem escolher não muda nada.
Future<void> adicionarEfeitoNaCasa(BuildContext context, WidgetRef ref, PosicaoBloco posicao) async {
  final escolhido = await showDialog<DefinicaoBloco>(
    context: context,
    builder: (_) => _BibliotecaEfeitos(posicao: posicao),
  );
  if (escolhido == null || !context.mounted) return;
  final mensageiro = ScaffoldMessenger.of(context);
  final l = AppLocalizations.of(context);
  final recusa = await ref.read(editorProvider.notifier).adicionarBloco(posicao, escolhido);
  if (recusa != null) mensageiro.showSnackBar(SnackBar(content: Text(textoDaRecusa(l, recusa))));
}

class _BibliotecaEfeitos extends ConsumerStatefulWidget {
  const _BibliotecaEfeitos({required this.posicao});

  final PosicaoBloco posicao;

  @override
  ConsumerState<_BibliotecaEfeitos> createState() => _EstadoBiblioteca();
}

class _EstadoBiblioteca extends ConsumerState<_BibliotecaEfeitos> {
  String _busca = '';
  FamiliaBloco? _familia;

  @override
  Widget build(BuildContext context) {
    final catalogo = ref.watch(catalogoProvider).value;
    final grupos =
        catalogo == null ? const <GrupoBiblioteca>[] : blocosDaBiblioteca(catalogo, busca: _busca, familia: _familia);
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Medidas.larguraBiblioteca, maxHeight: Medidas.alturaBiblioteca),
        child: Padding(
          padding: const EdgeInsets.all(Espacos.l),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _cabecalho(context),
            const SizedBox(height: Espacos.m),
            _campoBusca(),
            const SizedBox(height: Espacos.s),
            if (catalogo != null) _filtros(familiasDaBiblioteca(catalogo)),
            const SizedBox(height: Espacos.s),
            Expanded(child: catalogo == null ? const Center(child: CircularProgressIndicator()) : _lista(context, grupos)),
          ]),
        ),
      ),
    );
  }

  Widget _cabecalho(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final l = AppLocalizations.of(context);
    // o X fecha sem escolher: tocar fora e o Esc não se descobrem
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.adicionarEfeito, style: tema.titleLarge),
          Text(l.linhaCasa(widget.posicao.linha, widget.posicao.casa), style: tema.bodySmall),
          if (_linha2SemSplit)
            Text(l.smLinha2SemSplit,
                key: const ValueKey('aviso-linha2-sem-split'),
                style: tema.bodySmall?.copyWith(color: Cores.textoSecundario)),
        ]),
      ),
      IconButton(
        key: const ValueKey('fechar-biblioteca'),
        tooltip: l.uiFecharBiblioteca,
        icon: const Icon(Icons.close),
        onPressed: () => Navigator.pop(context),
      ),
    ]);
  }

  /// Na linha 2 sem Split o bloco entra, mas só toca depois que houver um
  /// Split na linha 1: a pessoa pode montar a linha 2 antes.
  bool get _linha2SemSplit {
    final documento = ref.watch(editorProvider.select((e) => e.atual));
    return widget.posicao.linha == 2 && documento != null && !temLinhaParalela(documento);
  }

  Widget _campoBusca() => TextField(
        key: const ValueKey('busca-efeito'),
        autofocus: true,
        decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search), hintText: AppLocalizations.of(context).buscarPeloNome),
        onChanged: (texto) => setState(() => _busca = texto),
      );

  /// "Todos" e uma pílula por família com efeitos; tocar de novo na escolhida
  /// volta a "Todos".
  Widget _filtros(List<FamiliaBloco> familias) {
    final l = AppLocalizations.of(context);
    return Wrap(spacing: Espacos.xs, runSpacing: Espacos.xs, children: [
        _filtro('todos', l.todos, selecionado: _familia == null, aoTocar: () => setState(() => _familia = null)),
        for (final f in familias)
          _filtro(f.name, l.familia(f),
              selecionado: _familia == f, aoTocar: () => setState(() => _familia = _familia == f ? null : f)),
      ]);
  }

  Widget _filtro(String chave, String rotulo, {required bool selecionado, required VoidCallback aoTocar}) => ChoiceChip(
        key: ValueKey('filtro-$chave'),
        label: Text(rotulo),
        selected: selecionado,
        onSelected: (_) => aoTocar(),
      );

  Widget _lista(BuildContext context, List<GrupoBiblioteca> grupos) {
    final l = AppLocalizations.of(context);
    if (grupos.isEmpty) {
      final familia = _familia;
      final texto = familia == null ? l.nenhumEfeito(_busca) : l.nenhumEfeitoNaFamilia(_busca, l.familia(familia));
      return Center(child: Text(texto, style: Theme.of(context).textTheme.bodyMedium));
    }
    final documento = ref.watch(editorProvider.select((e) => e.atual));
    RecusaAdicionar? recusa(DefinicaoBloco bloco) =>
        documento == null ? null : recusaAoAdicionar(documento, widget.posicao, bloco.uri);
    return ListView(children: [
      for (final grupo in grupos) ...[
        _tituloCategoria(context, l.familia(grupo.familia)),
        for (final bloco in grupo.blocos) _ItemEfeito(definicao: bloco, recusa: recusa(bloco)),
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
  const _ItemEfeito({required this.definicao, this.recusa});

  final DefinicaoBloco definicao;

  /// Por que o bloco não pode entrar nesta casa (Split e Merge); nulo, pode.
  final RecusaAdicionar? recusa;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final motivo = recusa;
    return ListTile(
      key: ValueKey('efeito-${definicao.uri}'),
      enabled: motivo == null,
      contentPadding: EdgeInsets.zero,
      // sem a arte de bypass: o selo OFF diria "desligado", não "não cabe aqui"
      leading: Opacity(
          opacity: motivo == null ? 1 : Opacidades.itemIndisponivel,
          child: ArteBlocoWidget(definicao: definicao, tamanho: Medidas.arteBiblioteca)),
      title: Text(l.nomeDoBloco(definicao)),
      subtitle: Text(motivo == null ? l.familia(definicao.familia) : textoDaRecusa(l, motivo)),
      trailing: Container(width: Medidas.fitaCategoria, height: Medidas.alvoMinimo, color: Cores.daFita(definicao.uri, definicao.familia)),
      onTap: () => Navigator.pop(context, definicao),
    );
  }
}
