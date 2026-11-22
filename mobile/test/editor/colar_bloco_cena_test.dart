// Colar um bloco copiado noutra cena: o que a pedaleira toca tem de ser o
// que a tela mostra, antes e depois de salvar e reabrir.
import 'package:anagram_app/aplicacao/casos_de_uso/salvar_no_slot.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/conexao_demo.dart';

const _origem = PosicaoBloco(1, 3);
const _destino = PosicaoBloco(1, 3);

/// O liga/desliga e o drive que a pedaleira recebeu no bloco colado.
(bool, num?) _tocado(Map<String, dynamic> documento) {
  final bloco = documento['preset']['chains']['1']['blocks']['3'] as Map<String, dynamic>;
  final parametros = (bloco['parameters'] as Map<String, dynamic>).values;
  final drive = parametros.firstWhere((p) => p['symbol'] == 'high_drive')['value'] as num?;
  return (bloco['enabled'] as bool, drive);
}

/// O que a tela mostra do bloco colado, na cena ativa.
(bool, num?) _mostrado(BlocoPreset bloco, int cena) => (bloco.habilitadoNaCena(cena), bloco.valorNaCena('high_drive', cena));

void main() {
  test('should_play_what_the_screen_shows_when_pasting_a_block_copied_in_another_scene', () async {
    final (container, pedaleira) = await conectarDemonstracao();
    final editor = container.read(editorProvider.notifier);
    await editor.abrirSlot(SlotPreset.doRotulo('02A'));
    expect(container.read(editorProvider).atual!.nome, 'Sujo de Ensaio');
    await editor.escolherCena(3);
    final ouvidoAoCopiar = _tocado(pedaleira.presetTocando!);
    editor.copiarBloco(_origem);

    await editor.abrirSlot(SlotPreset.doRotulo('01C'));
    expect(container.read(editorProvider).atual!.cenaAtiva, 1);
    await editor.colarBloco(_destino);

    final colado = container.read(editorProvider).atual!.bloco(_destino)!;
    expect(_mostrado(colado, 1), _tocado(pedaleira.presetTocando!), reason: 'o que soa é o que se vê');
    expect(_tocado(pedaleira.presetTocando!), ouvidoAoCopiar, reason: 'colar traz o som que se ouvia ao copiar');

    expect(await editor.salvar(), isA<PresetSalvo>());
    await editor.abrirSlot(SlotPreset.doRotulo('02A'));
    await editor.abrirSlot(SlotPreset.doRotulo('01C'));
    final reaberto = container.read(editorProvider).atual!.bloco(_destino)!;
    expect(_mostrado(reaberto, 1), ouvidoAoCopiar, reason: 'salvar e reabrir soa igual');
  });
}
