// Pelo menu da lista: exportar o JSON do preset GRAVADO no slot e limpar o
// slot. Limpar não tem volta, então o diálogo oferece exportar antes, ali
// mesmo; exportado (ou não), a pergunta volta para a pessoa decidir.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/avisos.dart';
import '../../aplicacao/casos_de_uso/transferir_preset.dart';
import '../../aplicacao/estado/acoes_da_lista.dart';
import '../../aplicacao/estado/controlador_biblioteca.dart';
import '../../aplicacao/estado/controlador_editor.dart';
import '../../aplicacao/provedores.dart';
import '../../dados/arquivos_preset.dart';
import '../../l10n/app_localizations.dart';
import '../../nucleo/modelo/documento_preset.dart';
import '../../nucleo/modelo/slot_preset.dart';
import '../../nucleo/resultado.dart';
import '../textos.dart';
import 'dialogo_confirmar.dart';

/// Exporta o preset como está gravado em [slot] (não a edição aberta).
/// Tudo o que vem do ref é lido antes das esperas: a lista pode fechar no meio.
Future<void> exportarDaLista(BuildContext context, WidgetRef ref, SlotPreset slot) async {
  final l = AppLocalizations.of(context);
  final mensageiro = ScaffoldMessenger.of(context);
  final transferir = TransferirPreset(ref.read(arquivosPresetProvider));
  final editadoSemSalvar = _editadoSemSalvar(ref, slot);
  final texto = switch (await ref.read(acoesDaListaProvider).lerGravado(slot)) {
    Sucesso(valor: final DocumentoPreset documento) =>
      await _gravarArquivo(transferir, l, slot, documento, editadoSemSalvar: editadoSemSalvar),
    Sucesso() => l.mpSlotVazio(slot.rotulo),
    Falha(:final erro) => l.aviso(AvisoErro(erro)),
  };
  if (texto != null) mensageiro.showSnackBar(SnackBar(content: Text(texto)));
}

Future<String?> _gravarArquivo(TransferirPreset transferir, AppLocalizations l, SlotPreset slot, DocumentoPreset documento,
    {required bool editadoSemSalvar}) async {
  final resultado = await transferir.exportar(documento, nome: '${slot.rotulo} ${documento.nome}');
  return switch (resultado) {
    PresetExportado(destino: DestinoExportacao.arquivo) =>
      editadoSemSalvar ? l.mpExportadoGravado(slot.rotulo) : l.presetExportado,
    PresetExportado(destino: DestinoExportacao.areaDeTransferencia) => l.presetCopiado,
    PresetExportado(destino: DestinoExportacao.cancelado) => null,
    ExportacaoFalhou() => l.exportacaoFalhou,
  };
}

/// O slot exportado é o aberto no editor, com edição não salva: o arquivo
/// leva o gravado, e a pessoa precisa saber que a edição ficou de fora.
bool _editadoSemSalvar(WidgetRef ref, SlotPreset slot) {
  final editor = ref.read(editorProvider);
  final area = ref.read(bibliotecaProvider).areaSelecionada;
  return editor.slot == slot && editor.area == area && editor.naoSalvo;
}

enum _EscolhaLimpar { cancelar, exportar, limpar }

/// Pergunta (oferecendo exportar antes) e limpa o slot na pedaleira.
Future<void> limparDaLista(BuildContext context, WidgetRef ref, SlotPreset slot) async {
  final nome = ref.read(bibliotecaProvider).resumo(slot)?.nome ?? '';
  var escolha = await _perguntar(context, slot, nome);
  while (escolha == _EscolhaLimpar.exportar) {
    if (!context.mounted) return;
    await exportarDaLista(context, ref, slot);
    if (!context.mounted) return;
    escolha = await _perguntar(context, slot, nome);
  }
  if (escolha != _EscolhaLimpar.limpar || !context.mounted) return;
  final l = AppLocalizations.of(context);
  final mensageiro = ScaffoldMessenger.of(context);
  final texto = switch (await ref.read(acoesDaListaProvider).limpar(slot)) {
    Sucesso() => l.mpLimpo(slot.rotulo),
    Falha(:final erro) => l.aviso(AvisoErro(erro)),
  };
  mensageiro.showSnackBar(SnackBar(content: Text(texto)));
}

Future<_EscolhaLimpar> _perguntar(BuildContext context, SlotPreset slot, String nome) async {
  final l = AppLocalizations.of(context);
  final escolha = await showDialog<_EscolhaLimpar>(
    context: context,
    builder: (contexto) {
      void responder(_EscolhaLimpar escolha) => Navigator.pop(contexto, escolha);
      return AlertDialog(
        key: const ValueKey('dialogo-limpar-preset'),
        title: Text(l.mpLimparTitulo(slot.rotulo)),
        content: Text(l.mpLimparTexto(nome, slot.rotulo)),
        actions: [
          BotaoCancelarDialogo(
              key: const ValueKey('cancelar-limpar-preset'),
              rotulo: l.cancelar,
              aoTocar: () => responder(_EscolhaLimpar.cancelar)),
          OutlinedButton(
            key: const ValueKey('limpar-exportar-antes'),
            onPressed: () => responder(_EscolhaLimpar.exportar),
            child: Text(l.mpExportarAntes),
          ),
          BotaoConfirmarPerda(
              key: const ValueKey('confirmar-limpar-preset'),
              rotulo: l.mpLimparConfirmar,
              aoTocar: () => responder(_EscolhaLimpar.limpar)),
        ],
      );
    },
  );
  return escolha ?? _EscolhaLimpar.cancelar;
}
