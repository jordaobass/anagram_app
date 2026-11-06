import 'package:anagram_app/aplicacao/casos_de_uso/salvar_no_slot.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:anagram_app/nucleo/protocolo/api_anagram.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/conexao_demo.dart';

void main() {
  test('should_not_write_when_the_slot_is_occupied_and_not_confirmed', () async {
    final (container, pedaleira) = await conectarDemonstracao();
    final editor = container.read(editorProvider.notifier);
    await editor.abrirSlot(SlotPreset(3));
    editor.alterarParametro('Threshold', -12, arrastando: false);
    final antes = pedaleira.conteudoDoSlot(4);

    final resultado = await editor.salvarComo(SlotPreset(4));

    expect(resultado, isA<SlotOcupado>());
    expect((resultado as SlotOcupado).nomeAtual, 'Sujo de Ensaio');
    expect(pedaleira.comandosRecebidos.map((c) => c.acao), isNot(contains(AcoesAnagram.salvar)));
    expect(pedaleira.conteudoDoSlot(4), antes);
  });
}
