// O modo dos footswitches vem do `export_settings` (chave `mode`, provada na
// Anagram v1.19.2.24 em 2026-11-22: "stomp", "scene" ou "preset"). Um valor
// que o app não conhece, ou a chave ausente, não pode virar um modo inventado.
import 'package:anagram_app/nucleo/ajustes/ajustes_pedaleira.dart';
import 'package:anagram_app/nucleo/ajustes/modo_footswitches.dart';
import 'package:flutter_test/flutter_test.dart';

AjustesPedaleira _lido(Map<String, Object?> settings) =>
    AjustesPedaleira.daResposta({'settings': settings, 'success': 1});

void main() {
  test('should_read_each_mode_the_pedal_exports', () {
    expect(_lido({'mode': 'stomp'}).modo, ModoFootswitches.stomp);
    expect(_lido({'mode': 'scene'}).modo, ModoFootswitches.scene);
    expect(_lido({'mode': 'preset'}).modo, ModoFootswitches.preset);
    expect(_lido({'mode': 'stomp'}).temModo, isTrue);
  });

  test('should_treat_an_unknown_value_as_unknown_but_still_present', () {
    final lido = _lido({'mode': 'looper', 'scene-mode': 'all'});

    expect(lido.modo, isNull);
    expect(lido.temModo, isTrue, reason: 'a chave existe: trocar para um modo conhecido é seguro');
  });

  test('should_report_no_mode_when_the_firmware_does_not_export_the_key', () {
    final lido = _lido({'mixer.headphones.vol': 6.0});

    expect(lido.modo, isNull);
    expect(lido.temModo, isFalse);
  });
}
