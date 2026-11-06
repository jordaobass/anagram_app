// Ações do preset aberto: salvar, salvar como, descartar, importar e exportar.
// Os botões ficam sempre no mesmo lugar (Descartar só se desabilita).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../../dados/arquivos_preset.dart';
import '../../nucleo/registro.dart';
import '../tema/tokens.dart';
import 'fluxo_salvar.dart';

class AcoesPreset extends ConsumerWidget {
  const AcoesPreset({super.key, required this.compactas, required this.listaEmOutraTela});

  final bool compactas;

  /// A lista de presets não está na tela: Salvar como a abre numa rota.
  final bool listaEmOutraTela;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final naoSalvo = ref.watch(editorProvider.select((e) => e.naoSalvo));
    // enquanto um preset carrega, salvar gravaria o anterior no slot novo
    final carregando = ref.watch(editorProvider.select((e) => e.carregando));
    final controlador = ref.read(editorProvider.notifier);
    final botoes = <Widget>[
      FilledButton.icon(
        key: const ValueKey('botao-salvar'),
        onPressed: carregando ? null : () => executarSalvar(context, ref, listaEmOutraTela: listaEmOutraTela),
        icon: const Icon(Icons.save_outlined),
        label: const Text('SALVAR'),
      ),
      OutlinedButton(
        key: const ValueKey('botao-salvar-como'),
        onPressed: () => abrirEscolhaDeDestino(context, ref, listaEmOutraTela: listaEmOutraTela),
        child: const Text('SALVAR COMO…'),
      ),
      OutlinedButton(
        key: const ValueKey('botao-descartar'),
        onPressed: naoSalvo ? controlador.descartarEdicoes : null,
        child: const Text('DESCARTAR'),
      ),
      _MenuArquivo(),
    ];
    return Wrap(
      spacing: Espacos.s,
      runSpacing: Espacos.s,
      alignment: compactas ? WrapAlignment.start : WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: botoes,
    );
  }
}

class _MenuArquivo extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => PopupMenuButton<bool>(
        tooltip: 'Importar ou exportar JSON',
        icon: const Icon(Icons.more_vert, color: Cores.texto),
        onSelected: (importar) => importar ? _importar(context, ref) : _exportar(context, ref),
        itemBuilder: (_) => const [
          PopupMenuItem(value: true, child: Text('Importar preset (.json)')),
          PopupMenuItem(value: false, child: Text('Exportar preset (.json)')),
        ],
      );

  Future<void> _importar(BuildContext context, WidgetRef ref) async {
    final mensageiro = ScaffoldMessenger.of(context);
    try {
      final documento = await const ArquivosPreset().importar();
      if (documento == null) return;
      await ref.read(editorProvider.notifier).carregarDocumento(documento);
      mensageiro.showSnackBar(SnackBar(content: Text('"${documento.nome}" importado. Salve no slot para gravar.')));
    } on FormatException catch (erro) {
      registro.w('importação recusada', error: erro);
      mensageiro.showSnackBar(SnackBar(content: Text('Arquivo não é um preset da Anagram: ${erro.message}')));
    }
  }

  Future<void> _exportar(BuildContext context, WidgetRef ref) async {
    final documento = ref.read(editorProvider).atual;
    if (documento == null) return;
    final mensageiro = ScaffoldMessenger.of(context);
    final destino = await const ArquivosPreset().exportar(documento);
    final texto = switch (destino) {
      DestinoExportacao.arquivo => 'Preset exportado.',
      DestinoExportacao.areaDeTransferencia => 'JSON do preset copiado para a área de transferência.',
      DestinoExportacao.cancelado => null,
    };
    if (texto != null) mensageiro.showSnackBar(SnackBar(content: Text(texto)));
  }
}
