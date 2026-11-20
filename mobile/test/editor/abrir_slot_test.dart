// Abrir um slot: o preset mostrado tem de ser o daquele slot, e só ele.
import 'package:anagram_app/aplicacao/estado/controlador_biblioteca.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/aplicacao/estado/estado_editor.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/conexao_demo.dart';
import '../apoio/fixtures.dart';

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

  test('should_refuse_the_preset_when_its_uuid_differs_from_the_slot_list', () async {
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
}
