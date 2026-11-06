import 'package:anagram_app/aplicacao/casos_de_uso/salvar_no_slot.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:anagram_app/nucleo/protocolo/api_anagram.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/conexao_demo.dart';

void main() {
  test('should_not_take_a_late_reply_of_another_action_as_empty_slot_when_saving', () async {
    final (container, pedaleira) = await conectarDemonstracao();
    final editor = container.read(editorProvider.notifier);
    await editor.abrirSlot(SlotPreset(3));
    pedaleira.enviarRespostaAtrasadaAntes = true;

    final resultado = await editor.salvarComo(SlotPreset(4));

    expect(resultado, isA<SlotOcupado>(), reason: 'a resposta da lista não é a leitura do slot');
    expect(pedaleira.comandosRecebidos.map((c) => c.acao), isNot(contains(AcoesAnagram.salvar)));
  });

  test('should_release_reply_listeners_when_sending_fails', () async {
    final (container, pedaleira) = await conectarDemonstracao();
    final editor = container.read(editorProvider.notifier);
    await editor.abrirSlot(SlotPreset(3));
    pedaleira.falharEnvio = true;

    final resultado = await editor.salvarComo(SlotPreset(3), confirmado: true);

    expect(resultado, isA<FalhaAoSalvar>());

    expect(pedaleira.temOuvintesDeResposta, isFalse);
  });
}
