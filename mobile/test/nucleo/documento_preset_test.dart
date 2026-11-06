import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:anagram_app/nucleo/modelo/documento_preset.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';

void main() {
  test('should_keep_every_field_of_real_presets_when_round_tripping', () {
    for (final nome in ['1', '2', '13', '41']) {
      final original = lerExemplo(nome);
      expect(DocumentoPreset.doJson(original).paraJson(), original, reason: '$nome.json');
    }
  });

  test('should_change_only_the_edited_value_and_keep_unknown_fields', () {
    final original = lerExemplo('1');
    const posicao = PosicaoBloco(1, 3);
    final editado = DocumentoPreset.doJson(original).comParametro(posicao, 'Gain', 9.5).paraJson();

    final blocoEditado = editado['preset']['chains']['1']['blocks']['3'] as Map<String, dynamic>;
    expect(blocoEditado['parameters']['4'], {'name': 'Gain', 'symbol': 'Gain', 'value': 9.5});
    (blocoEditado['parameters']['4'] as Map<String, dynamic>)['value'] =
        original['preset']['chains']['1']['blocks']['3']['parameters']['4']['value'];
    expect(editado, original, reason: 'nada além do valor pode mudar');
  });

  test('should_write_into_the_active_scene_when_it_overrides_the_parameter', () {
    final demo = lerPresetsDemonstracao()[4]!;
    const posicao = PosicaoBloco(1, 3);
    final na3 = DocumentoPreset.doJson(demo).comCena(3).comParametro(posicao, 'high_drive', 2);

    final bloco = na3.bloco(posicao)!;
    expect(bloco.valorNaCena('high_drive', 3), 2);
    expect(bloco.valorBase('high_drive'), 5, reason: 'base intocada');
    expect(na3.comCena(1).comParametro(posicao, 'high_drive', 7).bloco(posicao)!.valorNaCena('high_drive', 3), 2);
  });

  test('should_accept_a_newer_format_version_keeping_it_and_flagging_it', () {
    final futuro = {...lerExemplo('13'), 'version': 2};
    final documento = DocumentoPreset.doJson(futuro);
    expect(documento.versaoMaisNova, isTrue);
    expect(documento.paraJson()['version'], 2);
  });
}
