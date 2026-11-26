// Arquivos que chegam de fora viram coleções da biblioteca (DECISOES BB5):
// arrastados para a janela, ou abertos com o app ("Abrir com", ícone no Dock,
// argumento da linha de comando). Cada `.json` é importado como no menu
// "Importar coleção…", com o mesmo aviso; deu certo ao menos um, o modo
// Biblioteca liga para a pessoa ver o que entrou. Enquanto algo é arrastado
// sobre a janela, uma moldura diz o que soltar ali faz.
import 'dart:async';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_selector/file_selector.dart' show XFile;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/biblioteca_presets.dart';
import '../../aplicacao/estado/modo_biblioteca.dart';
import '../../l10n/app_localizations.dart';
import '../../nucleo/registro.dart';
import '../../plataforma/arquivos_abertos.dart';
import '../tema/tokens.dart';

/// Os arquivos abertos com o app; o `main` passa os da plataforma.
final arquivosAbertosProvider = Provider<ArquivosAbertos>((ref) => const ArquivosAbertos.nenhum());

class RecebedorDeArquivos extends ConsumerStatefulWidget {
  const RecebedorDeArquivos({super.key, required this.child});

  final Widget child;

  /// Arrastar arquivos para a janela só existe no computador.
  static bool get aceitaArrastar =>
      !kIsWeb &&
      const [TargetPlatform.macOS, TargetPlatform.windows, TargetPlatform.linux].contains(defaultTargetPlatform);

  @override
  ConsumerState<RecebedorDeArquivos> createState() => _RecebedorDeArquivosState();
}

class _RecebedorDeArquivosState extends ConsumerState<RecebedorDeArquivos> {
  StreamSubscription<List<String>>? _abertos;
  bool _arrastando = false;

  @override
  void initState() {
    super.initState();
    _abertos = ref
        .read(arquivosAbertosProvider)
        .ouvir()
        .listen((caminhos) => receber([for (final c in caminhos) XFile(c)]));
  }

  @override
  void dispose() {
    unawaited(_abertos?.cancel());
    super.dispose();
  }

  /// Importa cada arquivo e junta os avisos num só.
  Future<void> receber(List<XFile> arquivos) async {
    if (arquivos.isEmpty) return;
    final mensageiro = ScaffoldMessenger.maybeOf(context);
    final l = AppLocalizations.of(context);
    final controlador = ref.read(fonteBibliotecaProvider.notifier);
    final avisos = <String>[];
    var entrou = false;
    for (final arquivo in arquivos) {
      final nome = _semExtensao(arquivo.name);
      if (!ArquivosAbertos.ehColecao(arquivo.name)) {
        avisos.add(l.bbArquivoRecusado(arquivo.name));
        continue;
      }
      final String texto;
      try {
        texto = await arquivo.readAsString();
      } on Exception catch (erro) {
        registro.w('biblioteca: ${arquivo.path} não foi lido', error: erro);
        avisos.add(l.bbArquivoRecusado(arquivo.name));
        continue;
      }
      switch (await controlador.importarTexto(texto, nomeDoArquivo: nome)) {
        case BibliotecaImportada(:final colecoes, :final adicionados, :final ignorados):
          entrou = true;
          avisos.add(l.bbColecaoImportada(colecoes.join(', '), adicionados));
          if (ignorados > 0) avisos.add(l.bbIgnorados(ignorados));
        case ImportacaoBibliotecaRecusada() || ImportacaoBibliotecaCancelada():
          avisos.add(l.bbArquivoRecusado(arquivo.name));
      }
    }
    if (entrou) ref.read(modoBibliotecaProvider.notifier).definir(true);
    mensageiro?.showSnackBar(SnackBar(content: Text(avisos.join(' '))));
  }

  static String _semExtensao(String nome) => nome.replaceFirst(RegExp(r'\.json$', caseSensitive: false), '');

  @override
  Widget build(BuildContext context) {
    if (!RecebedorDeArquivos.aceitaArrastar) return widget.child;
    return DropTarget(
      onDragEntered: (_) => setState(() => _arrastando = true),
      onDragExited: (_) => setState(() => _arrastando = false),
      onDragDone: (detalhes) {
        setState(() => _arrastando = false);
        unawaited(receber(detalhes.files));
      },
      child: Stack(
        children: [
          widget.child,
          if (_arrastando) const Positioned.fill(child: IgnorePointer(child: _MolduraSoltar())),
        ],
      ),
    );
  }
}

class _MolduraSoltar extends StatelessWidget {
  const _MolduraSoltar();

  @override
  Widget build(BuildContext context) => Container(
    key: const ValueKey('moldura-soltar'),
    margin: const EdgeInsets.all(Espacos.s),
    decoration: BoxDecoration(
      color: context.cores.painel.withValues(alpha: 0.85),
      border: Border.all(color: context.cores.tally, width: Medidas.contornoSelecao),
      borderRadius: BorderRadius.circular(Raios.painel),
    ),
    alignment: Alignment.center,
    padding: const EdgeInsets.all(Espacos.xl),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.library_add_outlined, size: Espacos.xxxl, color: context.cores.tallyTinta),
        const SizedBox(height: Espacos.m),
        Text(
          AppLocalizations.of(context).bbSoltarAqui,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: context.cores.texto),
        ),
      ],
    ),
  );
}
