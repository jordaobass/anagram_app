// Abrir e gravar levam segundos na pedaleira real: o que a pessoa faz nesse
// meio-tempo não pode deixar a tela presa nem mostrar o preset errado.
import 'dart:async';

import 'package:anagram_app/aplicacao/casos_de_uso/salvar_no_slot.dart';
import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/midi/saida_midi.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:anagram_app/nucleo/protocolo/api_anagram.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/conexao_demo.dart';
import '../apoio/fixtures.dart';

/// MIDI que só conclui cada envio quando o teste manda: fixa a janela em que
/// a troca de slot ainda não terminou.
class _MidiSegurado implements SaidaMidiAnagram {
  final pendentes = <Completer<void>>[];

  @override
  String get descricao => 'MIDI segurado';
  @override
  bool get aberta => true;
  @override
  Future<void> abrir() async {}
  @override
  Future<void> fechar() async {}
  @override
  Future<void> enviar(List<int> mensagem) {
    final concluido = Completer<void>();
    pendentes.add(concluido);
    return concluido.future;
  }
}

Future<void> _esperarAte(bool Function() condicao) async {
  while (!condicao()) {
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
}

/// A gravação já foi aceita e a releitura do slot está a caminho.
bool _relendoDepoisDeGravar(TransporteDemonstracao pedaleira) {
  final comandos = pedaleira.comandosRecebidos.map((m) => m.acao).toList();
  final gravou = comandos.lastIndexOf(AcoesAnagram.salvar);
  return gravou >= 0 && comandos.lastIndexOf(AcoesAnagram.lerPreset) > gravou;
}

void main() {
  test('should_keep_the_saved_preset_and_not_hang_loading_when_another_slot_is_opened_during_a_save', () async {
    final (container, pedaleira) = await conectarDemonstracao();
    final editor = container.read(editorProvider.notifier);
    await editor.abrirSlot(SlotPreset(3));
    await editor.renomear('Editado durante a gravação');

    final gravacao = editor.salvar();
    await _esperarAte(() => _relendoDepoisDeGravar(pedaleira));
    final abertura = editor.abrirSlot(SlotPreset(1));
    await gravacao;
    await abertura;

    final estado = container.read(editorProvider);
    expect(estado.carregando, isFalse, reason: 'a tela não pode ficar presa em "carregando"');
    expect(estado.slot, SlotPreset(3));
    expect(estado.atual!.nome, 'Editado durante a gravação');
  });

  test('should_refuse_a_second_save_when_one_is_still_in_progress', () async {
    final (container, _) = await conectarDemonstracao();
    final editor = container.read(editorProvider.notifier);
    await editor.abrirSlot(SlotPreset(3));

    final primeira = editor.salvar();
    final segunda = await editor.salvar();
    await primeira;

    expect(segunda, isA<FalhaAoSalvar>());
    expect(container.read(editorProvider).salvando, isFalse);
  });

  test('should_not_show_the_older_preset_when_a_newer_slot_was_opened_while_midi_switched', () async {
    final midi = _MidiSegurado();
    final container = ProviderContainer(overrides: [
      presetsDemonstracaoProvider.overrideWith((ref) async => lerPresetsDemonstracao()),
      midiDemonstracaoProvider.overrideWithValue(() => midi),
    ]);
    await container.read(conexaoProvider.notifier).conectarDemonstracao();
    final editor = container.read(editorProvider.notifier);

    final primeira = editor.abrirSlot(SlotPreset(1));
    await _esperarAte(() => midi.pendentes.length == 1);
    final segunda = editor.abrirSlot(SlotPreset(2));
    await _esperarAte(() => midi.pendentes.length == 2);
    midi.pendentes.first.complete();
    await primeira;

    final enquantoAbre = container.read(editorProvider);
    expect(enquantoAbre.slot, SlotPreset(2));
    expect(enquantoAbre.atual, isNull, reason: 'o preset do slot 1 não pode aparecer sob o slot 2');
    expect(enquantoAbre.carregando, isTrue);

    midi.pendentes.last.complete();
    await segunda;
    expect(container.read(editorProvider).atual!.nome, lerPresetsDemonstracao()[2]!['preset']['name']);
  });
}
