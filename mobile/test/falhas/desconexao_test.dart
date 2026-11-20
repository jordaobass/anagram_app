import 'package:anagram_app/aplicacao/casos_de_uso/salvar_no_slot.dart';
import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/aplicacao/estado/estado_conexao.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:anagram_app/nucleo/protocolo/api_anagram.dart';
import 'package:anagram_app/nucleo/protocolo/erros_anagram.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/conexao_demo.dart';

void main() {
  test('should_report_disconnection_and_keep_unsaved_edit_when_cable_drops_mid_save', () async {
    final (container, pedaleira) = await conectarDemonstracao();
    final editor = container.read(editorProvider.notifier);
    await editor.abrirSlot(SlotPreset(3));
    editor.alterarParametro('Threshold', -12, arrastando: false);
    pedaleira.desconectarAoReceber = AcoesAnagram.salvar;

    final relogio = Stopwatch()..start();
    final resultado = await editor.salvarComo(SlotPreset(3), confirmado: true);

    expect(relogio.elapsed, lessThan(const Duration(seconds: 5)), reason: 'não pode esperar o prazo');
    expect((resultado as FalhaAoSalvar).erro, isA<ErroDesconectado>());
    expect(container.read(conexaoProvider), isA<SemConexao>());
    final estado = container.read(editorProvider);
    expect(estado.naoSalvo, isTrue);
    expect(estado.blocoSelecionado!.valorBase('Threshold'), -12);
    expect((container.read(conexaoProvider) as SemConexao).aviso, contains('desconectada'),
        reason: 'o aviso aparece uma vez, na tela de conectar');
  });
}
