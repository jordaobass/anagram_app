// O bloco do Marketplace instalado na pedaleira entra na biblioteca de
// "adicionar efeito" como os de fábrica (DECISOES P4). A pedaleira de
// demonstração tem o "Nebula Synth (demo)", fora do catálogo de fábrica.
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/demonstracao/plugins_demonstracao.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';

void main() {
  testWidgets('should_list_the_installed_marketplace_block_in_the_add_effect_library', (tester) async {
    final container = await abrirDemonstracao(tester);
    await tocarNoSlot(tester, '01A');
    expect(container.read(editorProvider).atual!.bloco(const PosicaoBloco(1, 4)), isNull);

    await tester.tap(find.byKey(const ValueKey('casa-1-4')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('busca-efeito')), 'nebula');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('efeito-$uriNebulaDemonstracao')));
    await tester.pumpAndSettle();

    expect(container.read(editorProvider).atual!.bloco(const PosicaoBloco(1, 4))?.uri, uriNebulaDemonstracao);
    expect(find.byKey(const ValueKey('param-cutoff')), findsOneWidget, reason: 'o painel com os parâmetros reais');
  });
}
