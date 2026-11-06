// Preset criado do zero tem de ter a mesma forma dos arquivos reais.
import 'package:anagram_app/nucleo/modelo/documento_preset.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('should_have_empty_bindings_like_real_files_when_creating_a_new_preset', () {
    expect(DocumentoPreset.vazio('Novo').paraJson()['preset'], containsPair('bindings', <String, dynamic>{}));
  });
}
