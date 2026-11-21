// O nome do preset criado num slot vazio vai gravado para a pedaleira: ele
// nasce no idioma de quem criou, não em português fixo.
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/aplicacao/idioma.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';

void main() {
  testWidgets('should_name_the_new_preset_in_english_when_the_app_is_in_english', (tester) async {
    await montarApp(tester, idioma: IdiomaApp.ingles);
    final container = await entrarNaDemonstracao(tester);
    await tocarNoSlot(tester, '03C');

    await tester.tap(find.byKey(const ValueKey('botao-novo-preset')));
    await tester.pumpAndSettle();

    expect(container.read(editorProvider).atual!.nome, 'New preset');
  });
}
