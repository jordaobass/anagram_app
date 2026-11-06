// Ações do preset aberto: salvar, salvar como, descartar, importar e exportar.
// Os botões ficam sempre no mesmo lugar (Descartar só se desabilita).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/casos_de_uso/transferir_preset.dart';
import '../../aplicacao/estado/controlador_editor.dart';
import '../../aplicacao/provedores.dart';
import '../../dados/arquivos_preset.dart';
import '../../nucleo/modelo/documento_preset.dart';
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
    // lendo: salvar gravaria o anterior no slot novo; gravando: já há uma gravação
    final ocupado = ref.watch(editorProvider.select((e) => e.ocupado));
    return Wrap(
      spacing: Espacos.s,
      runSpacing: Espacos.s,
      alignment: compactas ? WrapAlignment.start : WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: _botoes(context, ref, naoSalvo: naoSalvo, ocupado: ocupado),
    );
  }

  List<Widget> _botoes(BuildContext context, WidgetRef ref, {required bool naoSalvo, required bool ocupado}) => [
        FilledButton.icon(
          key: const ValueKey('botao-salvar'),
          onPressed: ocupado ? null : () => executarSalvar(context, ref, listaEmOutraTela: listaEmOutraTela),
          icon: const Icon(Icons.save_outlined),
          label: const Text('SALVAR'),
        ),
        OutlinedButton(
          key: const ValueKey('botao-salvar-como'),
          onPressed: ocupado ? null : () => abrirEscolhaDeDestino(context, ref, listaEmOutraTela: listaEmOutraTela),
          child: const Text('SALVAR COMO…'),
        ),
        OutlinedButton(
          key: const ValueKey('botao-descartar'),
          onPressed: naoSalvo && !ocupado ? ref.read(editorProvider.notifier).descartarEdicoes : null,
          child: const Text('DESCARTAR'),
        ),
        _MenuArquivo(),
      ];
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

  TransferirPreset _transferir(WidgetRef ref) => TransferirPreset(ref.read(arquivosPresetProvider));

  Future<void> _importar(BuildContext context, WidgetRef ref) async {
    final mensageiro = ScaffoldMessenger.of(context);
    final texto = switch (await _transferir(ref).importar()) {
      PresetImportado(:final documento) => await _carregar(ref, documento),
      ImportacaoRecusada(:final motivo) => motivo,
      ImportacaoCancelada() => null,
    };
    if (texto != null) mensageiro.showSnackBar(SnackBar(content: Text(texto)));
  }

  static Future<String> _carregar(WidgetRef ref, DocumentoPreset documento) async {
    await ref.read(editorProvider.notifier).carregarDocumento(documento);
    return '"${documento.nome}" importado. Salve no slot para gravar.';
  }

  Future<void> _exportar(BuildContext context, WidgetRef ref) async {
    final documento = ref.read(editorProvider).atual;
    if (documento == null) return;
    final mensageiro = ScaffoldMessenger.of(context);
    final texto = switch (await _transferir(ref).exportar(documento)) {
      PresetExportado(destino: DestinoExportacao.arquivo) => 'Preset exportado.',
      PresetExportado(destino: DestinoExportacao.areaDeTransferencia) =>
        'JSON do preset copiado para a área de transferência.',
      PresetExportado(destino: DestinoExportacao.cancelado) => null,
      ExportacaoFalhou(:final motivo) => motivo,
    };
    if (texto != null) mensageiro.showSnackBar(SnackBar(content: Text(texto)));
  }
}
