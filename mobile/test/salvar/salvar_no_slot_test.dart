// Gravar no slot: o que vai para a pedaleira, com que uuid e em que momento.
import 'package:anagram_app/aplicacao/casos_de_uso/salvar_no_slot.dart';
import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/midi/saida_midi.dart';
import 'package:anagram_app/nucleo/modelo/documento_preset.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/conexao_demo.dart';
import '../apoio/fixtures.dart';

void main() {
  test('should_ask_and_give_a_new_uuid_when_saving_an_imported_preset', () async {
    final (container, pedaleira) = await conectarDemonstracao();
    final editor = container.read(editorProvider.notifier);
    await editor.abrirSlot(SlotPreset(3));
    final importado = DocumentoPreset.doJson(lerExemplo('13'));
    await editor.carregarDocumento(importado);

    expect(await editor.salvar(), isA<SlotOcupado>(), reason: 'o importado não é o que está no slot');
    await editor.salvarComo(SlotPreset(3), confirmado: true);
    final gravado = pedaleira.conteudoDoSlot(3)!['preset'] as Map<String, dynamic>;
    expect(gravado['name'], importado.nome);
    expect(gravado['uuid'], isNot(importado.uuid), reason: 'dois slots com o mesmo uuid confundem a pedaleira');
  });

  test('should_switch_the_pedal_to_the_destination_when_saving_as', () async {
    final (container, _) = await conectarDemonstracao();
    final midi = container.read(conexaoProvider.notifier).midi! as SaidaMidiDemonstracao;
    final editor = container.read(editorProvider.notifier);
    await editor.abrirSlot(SlotPreset(3));

    await editor.salvarComo(SlotPreset(9));

    expect(midi.mensagens.last, [0xC0, 9]);
    expect(container.read(editorProvider).slotNaPedaleira, isTrue);
  });

  test('should_not_keep_or_save_the_previous_preset_under_the_new_slot_when_reading_fails', () async {
    final (container, pedaleira) = await conectarDemonstracao();
    final editor = container.read(editorProvider.notifier);
    await editor.abrirSlot(SlotPreset(3));
    final nomeDo3 = container.read(editorProvider).atual!.nome;
    final slot4Antes = (pedaleira.conteudoDoSlot(4)!['preset'] as Map)['name'];
    pedaleira.falharEnvio = true;
    await editor.abrirSlot(SlotPreset(4));
    pedaleira.falharEnvio = false;
    final estado = container.read(editorProvider);
    expect(estado.atual?.nome, isNot(nomeDo3), reason: 'o preset do 3 não pode ficar sob o slot 4');

    final resultado = await editor.salvar();
    final slot4Depois = (pedaleira.conteudoDoSlot(4)!['preset'] as Map)['name'];
    expect(resultado, isNot(isA<PresetSalvo>()), reason: 'não há o que salvar em 04 sem ter lido 04');
    expect(slot4Depois, slot4Antes, reason: 'slot 4 não pode receber o preset do slot 3 sem perguntar');
  });

  test('should_not_write_the_previous_preset_into_the_new_slot_when_saving_while_loading', () async {
    final (container, pedaleira) = await conectarDemonstracao();
    final editor = container.read(editorProvider.notifier);
    await editor.abrirSlot(SlotPreset(3));
    final uuidDo3 = container.read(editorProvider).atual!.uuid;
    final slot4Antes = (pedaleira.conteudoDoSlot(4)!['preset'] as Map)['name'];

    final abrindo = editor.abrirSlot(SlotPreset(4)); // não aguardado: carregando
    final resultado = await editor.salvar(); // o Cmd+S chama isto direto (AtalhosEditor), sem passar pelo botão
    await abrindo;

    final gravado = pedaleira.conteudoDoSlot(4)!['preset'] as Map;
    expect(resultado, isNot(isA<PresetSalvo>()), reason: 'salvar enquanto carrega grava o preset anterior no slot novo');
    expect(gravado['name'], slot4Antes);
    expect(gravado['uuid'], isNot(uuidDo3));
  });
}
