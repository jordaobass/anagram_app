// Firmware 1.16+ aceita mais de três cenas por preset (issue #39: "127 Scenes
// per Preset" no 1.19.2). As cenas moram nas mesmas chaves numéricas de
// `scenes` (bloco) e `sceneNames` (preset); o app não pode tratar a 4ª e a 5ª
// como inexistentes: editar "só na cena" numa delas não pode mudar as outras.
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:anagram_app/nucleo/modelo/conferencia_gravacao.dart';
import 'package:anagram_app/nucleo/modelo/documento_preset.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/cinco_cenas.dart';

const _casa = PosicaoBloco(1, 1);

List<num?> _porCena(DocumentoPreset documento, String simbolo) =>
    [for (var cena = 1; cena <= 5; cena++) documento.bloco(_casa)!.valorNaCena(simbolo, cena)];

void main() {
  test('should_count_the_scenes_the_preset_registers_and_never_less_than_three', () {
    expect(DocumentoPreset.doJson(presetCincoCenas()).quantidadeCenas, 5);
    expect(DocumentoPreset.vazio('Novo').quantidadeCenas, 3, reason: 'preset sem registro de cena tem as 3 de sempre');
  });

  test('should_keep_the_other_four_scenes_when_editing_only_scene_4_and_switching_to_scene_5', () {
    final aberto = DocumentoPreset.doJson(presetCincoCenas()).comCena(4);

    final editado = aberto.comParametro(_casa, 'low_level', 9).comCena(5);

    expect(_porCena(editado, 'low_level'), [3, 3, 3, 9, 3], reason: 'só a cena 4 muda');
    expect(_porCena(editado, 'high_drive'), [5, 5, 8.5, 6, 7], reason: 'o que já variava não muda');
  });

  test('should_keep_the_on_off_of_scenes_4_and_5_when_switching_the_block_off_only_in_scene_1', () {
    final json = presetCincoCenas();
    // fotos sem o liga/desliga: as cenas seguem o bloco até alguma ter o seu
    for (final foto in (blocoDoPreset(json)['scenes'] as Map<String, dynamic>).values) {
      (foto as Map<String, dynamic>).remove('enabled');
    }
    final aberto = DocumentoPreset.doJson(json);

    final bloco = aberto.comBlocoHabilitado(_casa, false).comCena(5).bloco(_casa)!;

    expect([for (var cena = 1; cena <= 5; cena++) bloco.habilitadoNaCena(cena)], [false, true, true, true, true]);
  });

  test('should_complete_a_parameter_registered_only_in_scene_5_in_all_five_scenes_when_opening', () {
    final json = presetCincoCenas();
    final bloco = blocoDoPreset(json);
    (bloco['scenes'] as Map<String, dynamic>)['5'] = {
      'parameters': [
        {'symbol': 'high_level', 'value': 2},
      ],
    };

    final documento = DocumentoPreset.doJson(json).comCena(5).comCena(4);

    expect(_porCena(documento, 'high_level'), [4, 4, 4, 4, 2], reason: 'voltar da cena 5 não deixa o 2 na cena 4');
  });

  test('should_refuse_the_reread_preset_when_only_scene_5_differs_from_what_was_sent', () {
    final enviado = DocumentoPreset.doJson(presetCincoCenas());
    final json = presetCincoCenas();
    final foto5 = ((blocoDoPreset(json)['scenes'] as Map<String, dynamic>)['5'] as Map<String, dynamic>);
    (foto5['parameters'] as List<dynamic>).first['value'] = 1;

    expect(gravacaoConfere(DocumentoPreset.doJson(json), enviado), isFalse);
    expect(gravacaoConfere(DocumentoPreset.doJson(presetCincoCenas()), enviado), isTrue);
  });
}
