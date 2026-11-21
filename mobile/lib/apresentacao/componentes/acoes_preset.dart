// Ações do preset aberto: salvar, salvar como, descartar, importar e exportar.
// SALVAR só fica em âmbar cheio quando há o que salvar (como o selo NÃO
// SALVO); sem edição, contornado. Enquanto a lista escolhe o destino do
// "Salvar como", os botões de cima ficam parados: a ação está na lista.
// No celular cabem numa linha: SALVAR, SALVAR COMO e um menu com Descartar,
// Importar e Exportar; no computador, Descartar fica à vista.
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
    // lendo: salvar gravaria o anterior no slot novo; gravando: já há uma
    // gravação; escolhendo o destino: a ação está na lista
    final parado = ref.watch(editorProvider.select((e) => e.ocupado || e.escolhendoDestino));
    return Wrap(
      spacing: Espacos.s,
      runSpacing: Espacos.s,
      alignment: compactas ? WrapAlignment.start : WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _salvar(context, ref, naoSalvo: naoSalvo, parado: parado),
        OutlinedButton(
          key: const ValueKey('botao-salvar-como'),
          onPressed: parado ? null : () => abrirEscolhaDeDestino(context, ref, listaEmOutraTela: listaEmOutraTela),
          child: Text(AppLocalizations.of(context).salvarComo),
        ),
        if (!compactas) _descartar(context, ref, naoSalvo: naoSalvo, parado: parado),
        _MenuArquivo(parado: parado, comDescartar: compactas, naoSalvo: naoSalvo),
      ],
    );
  }

  Widget _salvar(BuildContext context, WidgetRef ref, {required bool naoSalvo, required bool parado}) {
    final aoTocar = parado ? null : () => executarSalvar(context, ref, listaEmOutraTela: listaEmOutraTela);
    final rotulo = Text(AppLocalizations.of(context).salvar);
    const icone = Icon(Icons.save_outlined);
    const chave = ValueKey('botao-salvar');
    return naoSalvo
        ? FilledButton.icon(key: chave, onPressed: aoTocar, icon: icone, label: rotulo)
        : OutlinedButton.icon(key: chave, onPressed: aoTocar, icon: icone, label: rotulo);
  }

  static Widget _descartar(BuildContext context, WidgetRef ref, {required bool naoSalvo, required bool parado}) =>
      OutlinedButton(
        key: const ValueKey('botao-descartar'),
        onPressed: naoSalvo && !parado ? ref.read(editorProvider.notifier).descartarEdicoes : null,
        child: Text(AppLocalizations.of(context).descartar),
      );
}

enum _AcaoArquivo { descartar, importar, exportar }

/// Importar e exportar (e, no celular, Descartar). Ícone próprio, para não se
/// confundir com o ⋮ do bloco logo abaixo.
class _MenuArquivo extends ConsumerWidget {
  const _MenuArquivo({required this.parado, required this.comDescartar, required this.naoSalvo});

  /// Carregando, gravando ou escolhendo destino: importar agora disputaria o preset aberto.
  final bool parado;
  final bool comDescartar;
  final bool naoSalvo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return PopupMenuButton<_AcaoArquivo>(
        key: const ValueKey('menu-preset'),
        tooltip: comDescartar ? l.uiMaisAcoesPreset : l.uiMenuArquivo,
        enabled: !parado,
        icon: Icon(comDescartar ? Icons.more_horiz : Icons.import_export, color: Cores.texto),
        onSelected: (acao) => switch (acao) {
          _AcaoArquivo.descartar => ref.read(editorProvider.notifier).descartarEdicoes(),
          _AcaoArquivo.importar => _importar(context, ref),
          _AcaoArquivo.exportar => _exportar(context, ref),
        },
        itemBuilder: (_) => [
          if (comDescartar)
            PopupMenuItem(
                key: const ValueKey('menu-descartar'),
                value: _AcaoArquivo.descartar,
                enabled: naoSalvo,
                child: Text(l.uiDescartarEdicoes)),
          PopupMenuItem(value: _AcaoArquivo.importar, child: Text(l.importarPreset)),
          PopupMenuItem(value: _AcaoArquivo.exportar, child: Text(l.exportarPreset)),
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
