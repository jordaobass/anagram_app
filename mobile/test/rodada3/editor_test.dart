// Correções da rodada 3 no estado do editor e da conexão (c1–c4, c6–c8).
import 'package:anagram_app/aplicacao/casos_de_uso/salvar_no_slot.dart';
import 'package:anagram_app/aplicacao/estado/controlador_biblioteca.dart';
import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/aplicacao/estado/estado_conexao.dart';
import 'package:anagram_app/aplicacao/estado/estado_editor.dart';
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/nucleo/midi/saida_midi.dart';
import 'package:anagram_app/nucleo/modelo/documento_preset.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/conexao_demo.dart';
import '../apoio/fixtures.dart';

void main() {
  test('c1_should_ask_and_give_a_new_uuid_when_saving_an_imported_preset', () async {
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

  test('c2_should_create_new_preset_with_empty_bindings_like_real_files', () {
    expect(DocumentoPreset.vazio('Novo').paraJson()['preset'], containsPair('bindings', <String, dynamic>{}));
  });

  test('c3_should_never_show_one_slot_with_another_slots_preset_while_switching', () async {
    final (container, _) = await conectarDemonstracao();
    final misturas = <String>[];
    container.listen<EstadoEditor>(editorProvider, (_, e) {
      if (e.slot?.numero == 4 && e.atual?.nome == 'Grave Limpo') misturas.add('04 com Grave Limpo');
    });
    final editor = container.read(editorProvider.notifier);

    final primeiro = editor.abrirSlot(SlotPreset(3));
    await editor.abrirSlot(SlotPreset(4));
    await primeiro;

    expect(misturas, isEmpty);
    expect(container.read(editorProvider).atual!.nome, 'Sujo de Ensaio');
  });

  test('c4_should_refuse_a_preset_whose_uuid_differs_from_the_slot_list', () async {
    final (container, pedaleira) = await conectarDemonstracao();
    container.read(bibliotecaProvider); // nasce e agenda a leitura da lista
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(container.read(bibliotecaProvider).resumo(SlotPreset(3))?.id, isNotEmpty);
    pedaleira.substituirSlot(3, lerExemplo('13'));

    await container.read(editorProvider.notifier).abrirSlot(SlotPreset(3));

    final estado = container.read(editorProvider);
    expect(estado.atual, isNull);
    expect(estado.aviso, contains('outro preset'));
  });

  test('c6_should_reset_destination_mode_and_pedal_slot_on_disconnect', () async {
    final (container, _) = await conectarDemonstracao();
    final editor = container.read(editorProvider.notifier);
    await editor.abrirSlot(SlotPreset(3));
    editor.iniciarSalvarComo();

    await container.read(conexaoProvider.notifier).desconectar();

    final estado = container.read(editorProvider);
    expect([estado.escolhendoDestino, estado.slotNaPedaleira], [false, false]);
  });

  test('c7_should_cancel_while_midi_opens_without_crashing', () async {
    final container = ProviderContainer(overrides: [
      presetsDemonstracaoProvider.overrideWith((ref) async => lerPresetsDemonstracao()),
      midiDemonstracaoProvider.overrideWithValue(() => SaidaMidiDemonstracao(atrasoAoAbrir: const Duration(milliseconds: 300))),
    ]);
    final conexao = container.read(conexaoProvider.notifier);
    final tentativa = conexao.conectarDemonstracao();
    await Future<void>.delayed(const Duration(milliseconds: 100));

    await conexao.cancelarConexao();
    await tentativa;

    expect(container.read(conexaoProvider), isA<SemConexao>());
  });

  test('c8_should_switch_pedal_to_destination_after_save_as', () async {
    final (container, _) = await conectarDemonstracao();
    final midi = container.read(conexaoProvider.notifier).midi! as SaidaMidiDemonstracao;
    final editor = container.read(editorProvider.notifier);
    await editor.abrirSlot(SlotPreset(3));

    await editor.salvarComo(SlotPreset(9));

    expect(midi.mensagens.last, [0xC0, 9]);
    expect(container.read(editorProvider).slotNaPedaleira, isTrue);
  });
}
