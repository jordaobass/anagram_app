import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:anagram_app/nucleo/modelo/documento_preset.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/conexao_demo.dart';
import '../apoio/fixtures.dart';

void main() {
  test('should_not_mark_unsaved_when_only_switching_scene', () async {
    final (container, _) = await conectarDemonstracao();
    final editor = container.read(editorProvider.notifier);
    await editor.abrirSlot(SlotPreset(4));

    await editor.escolherCena(2);

    expect(container.read(editorProvider).naoSalvo, isFalse);
    expect(container.read(editorProvider).atual!.cenaAtiva, 2, reason: 'a cena vai junto ao salvar');
  });

  test('should_keep_base_and_other_scenes_when_bypassing_in_the_active_scene', () {
    const posicao = PosicaoBloco(1, 1);
    final base = DocumentoPreset.doJson(lerPresetsDemonstracao()[3]!);
    final semCenas = DocumentoPreset.doJson(lerExemplo('13'));

    final na2 = base.comCena(2).comBlocoHabilitado(posicao, false);
    final bloco = na2.bloco(posicao)!;
    expect(bloco.habilitado, isTrue, reason: 'base intocada');
    expect([bloco.habilitadoNaCena(1), bloco.habilitadoNaCena(2), bloco.habilitadoNaCena(3)], [true, false, true]);
    expect(bloco.bypassSoNaCena(2), isTrue);

    final criada = semCenas.comCena(3).comBlocoHabilitado(posicao, false).bloco(posicao)!;
    expect(criada.habilitadoNaCena(3), isFalse);
    expect(criada.habilitadoNaCena(1), isTrue);
  });
}
