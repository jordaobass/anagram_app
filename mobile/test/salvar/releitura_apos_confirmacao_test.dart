// A pedaleira confirmou a gravação, mas o slot relido ainda é o de antes:
// "salvo" só quando a releitura tem o que se mandou (RN1 também no caminho
// com confirmação, DECISOES RV2).
import 'package:anagram_app/aplicacao/casos_de_uso/salvar_no_slot.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:anagram_app/nucleo/protocolo/erros_anagram.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/conexao_demo.dart';

void main() {
  test('should_keep_unsaved_and_warn_when_the_slot_reread_after_the_ack_is_not_what_was_sent', () async {
    final (container, pedaleira) = await conectarDemonstracao();
    final editor = container.read(editorProvider.notifier);
    await editor.abrirSlot(SlotPreset(3));
    await editor.renomear('Grave de Igreja');
    pedaleira.gravacaoAtrasada.releituras = 2;

    final resultado = await editor.salvar();

    expect(resultado, isA<FalhaAoSalvar>().having((f) => f.erro, 'erro', isA<ErroReleituraDiferente>()));
    final estado = container.read(editorProvider);
    expect(estado.naoSalvo, isTrue, reason: 'o slot relido não tem a edição');
    expect(estado.atual!.nome, 'Grave de Igreja', reason: 'a edição fica na tela');
  });

  test('should_save_when_the_second_reread_after_the_ack_shows_what_was_sent', () async {
    final (container, pedaleira) = await conectarDemonstracao();
    final editor = container.read(editorProvider.notifier);
    await editor.abrirSlot(SlotPreset(3));
    await editor.renomear('Grave de Igreja');
    pedaleira.gravacaoAtrasada.releituras = 1;

    expect(await editor.salvar(), isA<PresetSalvo>());
    final estado = container.read(editorProvider);
    expect(estado.atual!.nome, 'Grave de Igreja', reason: 'a tela fica com a releitura que confere, não com a antiga');
    expect(estado.naoSalvo, isFalse);
  });
}
