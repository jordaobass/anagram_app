// Menu de um preset da lista (botão direito, toque longo ou o ⋮ da linha):
// mover, clonar ou trocar de banco. Escolhida a operação, a lista passa a
// pedir o slot de destino (faixa âmbar no topo), como no "Salvar como".
// Na fábrica (só leitura) o menu só copia para uma área da pessoa.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/avisos.dart';
import '../../aplicacao/estado/controlador_biblioteca.dart';
import '../../aplicacao/estado/controlador_organizar.dart';
import '../../l10n/app_localizations.dart';
import '../../nucleo/modelo/slot_preset.dart';
import '../textos.dart';
import 'dialogo_confirmar.dart';
import 'fluxo_copiar_fabrica.dart';

/// Abre o menu do preset em [slot], na posição [onde] da tela.
Future<void> abrirMenuPreset(BuildContext context, WidgetRef ref, SlotPreset slot, Offset onde) async {
  if (ref.read(bibliotecaProvider).naFabrica) return _menuDaFabrica(context, ref, slot, onde);
  final l = AppLocalizations.of(context);
  final escolha = await showMenu<OperacaoPreset>(
    context: context,
    position: RelativeRect.fromLTRB(onde.dx, onde.dy, onde.dx, onde.dy),
    items: [
      PopupMenuItem(value: OperacaoPreset.mover, key: const ValueKey('op-mover'), child: Text(l.opMoverPara)),
      PopupMenuItem(value: OperacaoPreset.clonar, key: const ValueKey('op-clonar'), child: Text(l.opClonarPara)),
      PopupMenuItem(value: OperacaoPreset.trocarBanco, key: const ValueKey('op-banco'), child: Text(l.opTrocarBanco)),
    ],
  );
  if (escolha != null) ref.read(organizarProvider.notifier).iniciar(escolha, slot);
}

Future<void> _menuDaFabrica(BuildContext context, WidgetRef ref, SlotPreset slot, Offset onde) async {
  final copiar = await showMenu<bool>(
    context: context,
    position: RelativeRect.fromLTRB(onde.dx, onde.dy, onde.dx, onde.dy),
    items: [
      PopupMenuItem(value: true, key: const ValueKey('op-copiar'), child: Text(AppLocalizations.of(context).fbCopiarPara)),
    ],
  );
  if (copiar == true && context.mounted) await copiarDaFabrica(context, ref, slot);
}

/// Conclui a operação pendente no slot tocado: pergunta quando o destino tem
/// preset (ou ao trocar bancos) e avisa o resultado.
Future<void> concluirOrganizacao(BuildContext context, WidgetRef ref, SlotPreset destino) async {
  final l = AppLocalizations.of(context);
  final mensageiro = ScaffoldMessenger.of(context);
  final organizar = ref.read(organizarProvider.notifier);
  final pendente = ref.read(organizarProvider);
  if (pendente == null) return;
  var resultado = await organizar.concluir(destino);
  if (resultado is DestinoOcupado) {
    if (!context.mounted || !await _confirmar(context, l, pendente, resultado)) return organizar.cancelar();
    resultado = await organizar.concluir(destino, confirmado: true);
  }
  final texto = switch (resultado) {
    Organizado(:final operacao, :final origem, :final destino) => _feito(l, operacao, origem, destino),
    FalhaAoOrganizar(:final erro) => l.aviso(AvisoErro(erro)),
    DestinoOcupado() => null,
  };
  if (texto != null) mensageiro.showSnackBar(SnackBar(content: Text(texto)));
}

Future<bool> _confirmar(BuildContext context, AppLocalizations l, OperacaoPendente pendente, DestinoOcupado ocupado) {
  final (origem, destino) = (pendente.origem, ocupado.destino);
  final (titulo, texto, rotulo) = switch (pendente.operacao) {
    OperacaoPreset.mover => (
        l.opTrocarTitulo,
        l.opTrocarTexto(destino.rotulo, ocupado.nomeAtual, origem.rotulo),
        l.opTrocar
      ),
    OperacaoPreset.clonar => (
        l.opSubstituirTitulo(destino.rotulo),
        l.opSubstituirTexto(ocupado.nomeAtual, origem.rotulo),
        l.opSubstituir
      ),
    OperacaoPreset.trocarBanco => (
        l.opBancosTitulo(_banco(origem), _banco(destino)),
        l.opBancosTexto,
        l.opTrocar
      ),
  };
  return confirmar(context,
      titulo: titulo,
      texto: texto,
      rotuloCancelar: l.cancelar,
      rotuloConfirmar: rotulo,
      chaveConfirmar: const ValueKey('confirmar-organizar'));
}

String _feito(AppLocalizations l, OperacaoPreset operacao, SlotPreset origem, SlotPreset destino) => switch (operacao) {
      OperacaoPreset.mover => l.opMovido(origem.rotulo, destino.rotulo),
      OperacaoPreset.clonar => l.opClonado(origem.rotulo, destino.rotulo),
      OperacaoPreset.trocarBanco => l.opBancosTrocados(_banco(origem), _banco(destino)),
    };

String _banco(SlotPreset slot) => slot.banco.toString().padLeft(2, '0');
