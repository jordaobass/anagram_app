// Abrir um slot: o preset mostrado tem de ser o daquele slot, e só ele.
import 'package:anagram_app/aplicacao/estado/controlador_biblioteca.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/aplicacao/estado/estado_editor.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:anagram_app/apresentacao/textos.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/conexao_demo.dart';
import '../apoio/fixtures.dart';
import '../apoio/textos_pt.dart';

void main() {
  test('should_never_show_one_slot_with_another_slots_preset_when_switching_quickly', () async {
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

  test('should_reload_the_list_and_open_the_current_preset_when_the_slot_changed_outside_the_app', () async {
    final (container, pedaleira) = await conectarDemonstracao();
    container.read(bibliotecaProvider); // nasce e agenda a leitura da lista
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(container.read(bibliotecaProvider).resumo(SlotPreset(3))?.id, isNotEmpty);
    final novo = lerExemplo('13');
    pedaleira.substituirSlot(3, novo);

    await container.read(editorProvider.notifier).abrirSlot(SlotPreset(3));

    final estado = container.read(editorProvider);
    expect(estado.atual?.uuid, (novo['preset'] as Map<String, dynamic>)['uuid'], reason: 'abre a versão que está na pedaleira');
    expect(container.read(bibliotecaProvider).resumo(SlotPreset(3))?.id, estado.atual?.uuid, reason: 'a lista foi relida');
    expect(textosPt.aviso(estado.aviso!), contains('mudou fora do app'));
  });
}
