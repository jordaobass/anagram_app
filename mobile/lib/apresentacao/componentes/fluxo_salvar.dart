// Salvar (no slot aberto) e Salvar como (destino escolhido na lista de
// presets). Só pergunta quando o destino está ocupado e não é a origem.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/casos_de_uso/salvar_no_slot.dart';
import '../../aplicacao/estado/controlador_editor.dart';
import '../../nucleo/modelo/slot_preset.dart';
import '../rotas.dart';

Future<void> executarSalvar(BuildContext context, WidgetRef ref, {bool listaEmOutraTela = false}) async {
  final mensageiro = ScaffoldMessenger.of(context);
  final controlador = ref.read(editorProvider.notifier);
  final resultado = await controlador.salvar();
  if (resultado == null) {
    if (context.mounted) abrirEscolhaDeDestino(context, ref, listaEmOutraTela: listaEmOutraTela);
    return;
  }
  if (resultado case SlotOcupado(:final slot, :final nomeAtual)) {
    // preset importado sobre um slot ocupado: confirma antes
    if (!context.mounted || !await _confirmarSubstituicao(context, slot, nomeAtual)) return;
    _avisar(mensageiro, await controlador.salvarComo(slot, confirmado: true));
    return;
  }
  _avisar(mensageiro, resultado);
}

/// Põe a lista em modo "escolher destino"; no celular a lista é outra tela.
void abrirEscolhaDeDestino(BuildContext context, WidgetRef ref, {bool listaEmOutraTela = false}) {
  ref.read(editorProvider.notifier).iniciarSalvarComo();
  if (listaEmOutraTela) const RotaPresets().push<void>(context);
}

/// Chamado pela lista quando o destino é tocado. Devolve se gravou.
Future<bool> salvarComoNoDestino(BuildContext context, WidgetRef ref, SlotPreset slot) async {
  final mensageiro = ScaffoldMessenger.of(context);
  final controlador = ref.read(editorProvider.notifier);
  var resultado = await controlador.salvarComo(slot);
  if (resultado case SlotOcupado(:final nomeAtual)) {
    if (!context.mounted) return false;
    if (!await _confirmarSubstituicao(context, slot, nomeAtual)) return false;
    resultado = await controlador.salvarComo(slot, confirmado: true);
  }
  _avisar(mensageiro, resultado);
  return resultado is PresetSalvo;
}

void _avisar(ScaffoldMessengerState mensageiro, ResultadoSalvar resultado) {
  final texto = switch (resultado) {
    PresetSalvo(:final relido, :final slot) => '"${relido.nome}" salvo em ${slot.rotulo}.',
    FalhaAoSalvar(:final erro) => 'Não salvou: ${erro.mensagem}',
    SlotOcupado() => null,
  };
  if (texto != null) mensageiro.showSnackBar(SnackBar(content: Text(texto)));
}

Future<bool> _confirmarSubstituicao(BuildContext context, SlotPreset slot, String nomeAtual) async {
  final resposta = await showDialog<bool>(
    context: context,
    builder: (contexto) => AlertDialog(
      title: Text('Substituir ${slot.rotulo}?'),
      content: Text('O slot ${slot.rotulo} guarda "$nomeAtual". Ele será substituído pelo preset editado.'),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(onPressed: () => Navigator.pop(contexto, false), child: const Text('CANCELAR')),
        FilledButton(
          key: const ValueKey('confirmar-substituicao'),
          onPressed: () => Navigator.pop(contexto, true),
          child: const Text('SUBSTITUIR'),
        ),
      ],
    ),
  );
  return resposta ?? false;
}
