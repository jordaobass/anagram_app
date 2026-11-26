// Menus do arquivo da biblioteca (DECISOES BB2, BB3). No cabeçalho da lista:
// importar uma coleção (arquivo de biblioteca ou export do Anagram App),
// exportar a biblioteca inteira e mostrar a pasta das coleções (BB4). Em cada coleção: exportar só ela e, se foi
// importada, apagar (com confirmação; a do build não sai).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/copias/copia_automatica.dart';
import '../../aplicacao/estado/biblioteca_presets.dart';
import '../../dados/arquivos_preset.dart';
import '../../l10n/app_localizations.dart';
import '../tema/tokens.dart';
import 'dialogo_confirmar.dart';
import 'item_de_menu.dart';

enum _AcaoBiblioteca { importar, exportar, mostrarPasta }

class MenuBiblioteca extends ConsumerWidget {
  const MenuBiblioteca({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    // na web e onde o sistema não deu pasta, não há o que mostrar
    final caminho = ref.watch(pastaBibliotecaProvider).caminho;
    return PopupMenuButton<_AcaoBiblioteca>(
      key: const ValueKey('menu-biblioteca'),
      tooltip: l.bbMenu,
      icon: Icon(Icons.folder_open_outlined, color: context.cores.textoSecundario),
      onSelected: (acao) => switch (acao) {
        _AcaoBiblioteca.importar => _importar(context, ref),
        _AcaoBiblioteca.exportar => exportarBiblioteca(context, ref),
        _AcaoBiblioteca.mostrarPasta => _mostrarPasta(context, ref, caminho),
      },
      itemBuilder: (_) => [
        itemDeMenu(
          _AcaoBiblioteca.importar,
          key: const ValueKey('biblioteca-importar'),
          icone: Icons.file_open_outlined,
          rotulo: l.bbImportar,
        ),
        itemDeMenu(
          _AcaoBiblioteca.exportar,
          key: const ValueKey('biblioteca-exportar'),
          icone: Icons.output,
          rotulo: l.bbExportar,
        ),
        if (caminho.isNotEmpty)
          itemDeMenu(
            _AcaoBiblioteca.mostrarPasta,
            key: const ValueKey('biblioteca-mostrar-pasta'),
            icone: Icons.folder_outlined,
            rotulo: l.bbMostrarPasta,
          ),
      ],
    );
  }

  /// A pasta pode ainda não existir (nada importado): é criada antes de abrir.
  Future<void> _mostrarPasta(BuildContext context, WidgetRef ref, String caminho) async {
    final mensageiro = ScaffoldMessenger.of(context);
    final l = AppLocalizations.of(context);
    await ref.read(pastaBibliotecaProvider).preparar();
    if (!await ref.read(abridorDePastaProvider)(caminho)) {
      mensageiro.showSnackBar(SnackBar(content: Text(l.bbPastaNaoAbriu(caminho))));
    }
  }

  Future<void> _importar(BuildContext context, WidgetRef ref) async {
    final mensageiro = ScaffoldMessenger.of(context);
    final l = AppLocalizations.of(context);
    final texto = switch (await ref.read(fonteBibliotecaProvider.notifier).importar()) {
      BibliotecaImportada(:final colecoes, :final adicionados, :final ignorados) => [
        l.bbColecaoImportada(colecoes.join(', '), adicionados),
        if (ignorados > 0) l.bbIgnorados(ignorados),
      ].join(' '),
      ImportacaoBibliotecaRecusada() => l.bbImportacaoRecusada,
      ImportacaoBibliotecaCancelada() => null,
    };
    if (texto != null) mensageiro.showSnackBar(SnackBar(content: Text(texto)));
  }
}

/// A biblioteca inteira, ou só a [colecao], num arquivo (no celular, copiada).
Future<void> exportarBiblioteca(BuildContext context, WidgetRef ref, {String? colecao}) async {
  final mensageiro = ScaffoldMessenger.of(context);
  final l = AppLocalizations.of(context);
  final texto = switch (await ref.read(fonteBibliotecaProvider.notifier).exportar(colecao: colecao)) {
    DestinoExportacao.arquivo => l.bbExportada,
    DestinoExportacao.areaDeTransferencia => l.bbCopiada,
    DestinoExportacao.cancelado => null,
    null => l.exportacaoFalhou,
  };
  if (texto != null) mensageiro.showSnackBar(SnackBar(content: Text(texto)));
}

enum _AcaoColecao { exportar, apagar }

class MenuColecao extends ConsumerWidget {
  const MenuColecao({super.key, required this.nome, required this.embutida});

  final String nome;
  final bool embutida;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return PopupMenuButton<_AcaoColecao>(
      key: ValueKey('menu-colecao-$nome'),
      tooltip: l.bbAcoesColecao,
      icon: Icon(Icons.more_vert, color: context.cores.textoSecundario),
      onSelected: (acao) => switch (acao) {
        _AcaoColecao.exportar => exportarBiblioteca(context, ref, colecao: nome),
        _AcaoColecao.apagar => _apagar(context, ref),
      },
      itemBuilder: (_) => [
        itemDeMenu(
          _AcaoColecao.exportar,
          key: const ValueKey('colecao-exportar'),
          icone: Icons.output,
          rotulo: l.bbExportarColecao,
        ),
        if (!embutida)
          itemDeMenu(
            _AcaoColecao.apagar,
            key: const ValueKey('colecao-apagar'),
            icone: Icons.delete_outline,
            rotulo: l.bbApagarColecao,
            destrutivo: true,
          ),
      ],
    );
  }

  Future<void> _apagar(BuildContext context, WidgetRef ref) async {
    final mensageiro = ScaffoldMessenger.of(context);
    final l = AppLocalizations.of(context);
    final sim = await confirmar(
      context,
      titulo: l.bbApagarTitulo(nome),
      texto: l.bbApagarTexto,
      rotuloCancelar: l.cancelar,
      rotuloConfirmar: l.bbApagarConfirmar,
      chaveConfirmar: const ValueKey('confirmar-apagar-colecao'),
    );
    if (!sim) return;
    final tirou = await ref.read(fonteBibliotecaProvider.notifier).removerColecao(nome);
    mensageiro.showSnackBar(SnackBar(content: Text(tirou ? l.bbApagada(nome) : l.bbApagarFalhou(nome))));
  }
}
