// O nome do preset viaja dentro do quadro HID: com "DSTART" ou "DEND" nele,
// a remontagem da resposta corta a mensagem e a leitura do slot falha.
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/conexao_demo.dart';

void main() {
  test('should_keep_the_old_name_when_the_new_one_contains_a_frame_marker', () async {
    final (container, _) = await conectarDemonstracao();
    final editor = container.read(editorProvider.notifier);
    await editor.abrirSlot(SlotPreset(3));
    final antes = container.read(editorProvider).atual!.nome;

    await editor.renomear('Grave DEND');
    await editor.renomear('DSTART limpo');

    expect(container.read(editorProvider).atual!.nome, antes);
  });

  test('should_accept_a_name_that_only_resembles_a_marker_in_other_case', () async {
    final (container, _) = await conectarDemonstracao();
    final editor = container.read(editorProvider.notifier);
    await editor.abrirSlot(SlotPreset(3));

    await editor.renomear('Dendê');

    expect(container.read(editorProvider).atual!.nome, 'Dendê');
  });
}
