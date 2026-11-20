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
import '../../l10n/app_localizations.dart';
import '../textos.dart';

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

  List<Widget> _botoes(BuildContext context, WidgetRef ref, {required bool naoSalvo, required bool ocupado}) {
    final l = AppLocalizations.of(context);
    return [
        FilledButton.icon(
          key: const ValueKey('botao-salvar'),
          onPressed: ocupado ? null : () => executarSalvar(context, ref, listaEmOutraTela: listaEmOutraTela),
          icon: const Icon(Icons.save_outlined),
          label: Text(l.salvar),
        ),
        OutlinedButton(
          key: const ValueKey('botao-salvar-como'),
          onPressed: ocupado ? null : () => abrirEscolhaDeDestino(context, ref, listaEmOutraTela: listaEmOutraTela),
          child: Text(l.salvarComo),
        ),
        OutlinedButton(
          key: const ValueKey('botao-descartar'),
          onPressed: naoSalvo && !ocupado ? ref.read(editorProvider.notifier).descartarEdicoes : null,
          child: Text(l.descartar),
        ),
        _MenuArquivo(ocupado: ocupado),
      ];
  }
}

class _MenuArquivo extends ConsumerWidget {
  const _MenuArquivo({required this.ocupado});

  /// Carregando ou gravando: importar agora disputaria o preset aberto.
  final bool ocupado;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return PopupMenuButton<bool>(
        tooltip: l.menuArquivo,
        enabled: !ocupado,
        icon: const Icon(Icons.more_vert, color: Cores.texto),
        onSelected: (importar) => importar ? _importar(context, ref) : _exportar(context, ref),
        itemBuilder: (_) => [
          PopupMenuItem(value: true, child: Text(l.importarPreset)),
          PopupMenuItem(value: false, child: Text(l.exportarPreset)),
        ],
      );
  }

  TransferirPreset _transferir(WidgetRef ref) => TransferirPreset(ref.read(arquivosPresetProvider));

  Future<void> _importar(BuildContext context, WidgetRef ref) async {
    final mensageiro = ScaffoldMessenger.of(context);
    final l = AppLocalizations.of(context);
    final texto = switch (await _transferir(ref).importar()) {
      PresetImportado(:final documento) => await _carregar(ref, l, documento),
      final ImportacaoRecusada recusa => l.importacaoRecusada(recusa),
      ImportacaoCancelada() => null,
    };
    if (texto != null) mensageiro.showSnackBar(SnackBar(content: Text(texto)));
  }

  static Future<String> _carregar(WidgetRef ref, AppLocalizations l, DocumentoPreset documento) async {
    await ref.read(editorProvider.notifier).carregarDocumento(documento);
    return l.presetImportado(documento.nome);
  }

  Future<void> _exportar(BuildContext context, WidgetRef ref) async {
    final documento = ref.read(editorProvider).atual;
    if (documento == null) return;
    final mensageiro = ScaffoldMessenger.of(context);
    final l = AppLocalizations.of(context);
    final texto = switch (await _transferir(ref).exportar(documento)) {
      PresetExportado(destino: DestinoExportacao.arquivo) => l.presetExportado,
      PresetExportado(destino: DestinoExportacao.areaDeTransferencia) => l.presetCopiado,
      PresetExportado(destino: DestinoExportacao.cancelado) => null,
      ExportacaoFalhou() => l.exportacaoFalhou,
    };
    if (texto != null) mensageiro.showSnackBar(SnackBar(content: Text(texto)));
  }
}
