// Pedido da IA para limpar ou mover slots (DECISOES IA9): o diálogo mostra
// cada linha do lote, na ordem, e uma resposta vale para todas.
import 'dart:async';

import 'package:anagram_app/aplicacao/mcp/avisos_mcp.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';

void main() {
  testWidgets('should_show_every_line_and_answer_for_the_whole_list_when_the_ai_asks_to_move_slots', (tester) async {
    final c = await abrirDemonstracao(tester);
    bool? resposta;
    unawaited(
      c
          .read(pedidoOrganizarProvider.notifier)
          .pedir(TipoOrganizar.mover, ['15A → 14C  PINK FLOYD', '15B → 15A  ROYAL BLOOD'], const Duration(minutes: 1))
          .then((r) => resposta = r),
    );
    await tester.pumpAndSettle();

    expect(find.text('15A → 14C  PINK FLOYD'), findsOneWidget);
    expect(find.text('15B → 15A  ROYAL BLOOD'), findsOneWidget);
    expect(resposta, isNull, reason: 'nada antes da pessoa responder');
    await tester.tap(find.byKey(const ValueKey('mcp-confirmar-organizar')));
    await tester.pumpAndSettle();

    expect(resposta, isTrue);
    expect(find.byKey(const ValueKey('dialogo-pedido-organizar')), findsNothing);
  });

  testWidgets('should_answer_no_when_the_player_taps_not_now', (tester) async {
    final c = await abrirDemonstracao(tester);
    bool? resposta;
    unawaited(
      c
          .read(pedidoOrganizarProvider.notifier)
          .pedir(TipoOrganizar.limpar, ['15C  VICTOR WOOTEN SLAP'], const Duration(minutes: 1))
          .then((r) => resposta = r),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('AGORA NÃO'));
    await tester.pumpAndSettle();

    expect(resposta, isFalse);
  });
}
