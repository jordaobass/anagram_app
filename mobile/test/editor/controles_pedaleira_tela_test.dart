// O painel "Controles da pedaleira" no toque: atribuir pelo cartão (sem botão
// direito), ajustar a faixa e o nome no diálogo, e pôr um footswitch no bloco
// pelo menu dele. Cada mudança vai pelo editor e fica "não salva".
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:anagram_app/nucleo/modelo/controles_pedaleira.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';

Map<IdControle, ControlePedaleira> controles(ProviderContainer container) =>
    container.read(editorProvider).atual!.controles;

Future<void> tocar(WidgetTester tester, String chave) async {
  final alvo = find.byKey(ValueKey(chave));
  // os cartões ficam no fim do editor (recolhidos no 01C, que não tem
  // controle atribuído); menus e diálogos já estão à vista
  if (chave.startsWith('controle-')) {
    await abrirControlesDaPedaleira(tester);
    await rolarEditorAte(tester, alvo);
  }
  await tester.tap(alvo);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('should_assign_rename_and_narrow_a_pot_from_its_card_when_there_is_no_right_click', (tester) async {
    final container = await abrirDemonstracao(tester);
    await tocarNoSlot(tester, '01C');

    await tocar(tester, 'controle-pot1');
    await tocar(tester, 'atribuir-do-bloco');
    await tocar(tester, 'escolher-param-Threshold');
    final pot = controles(container)[IdControle.pot1]!;
    expect(pot.alvos.single.simbolo, 'Threshold');
    expect(find.byKey(const ValueKey('alvo-0')), findsOneWidget, reason: 'o diálogo mostra o alvo novo');

    await tester.drag(find.descendant(of: find.byKey(const ValueKey('minimo-0')), matching: find.byType(CustomPaint)).first,
        const Offset(0, -60));
    await tester.pumpAndSettle();
    expect(controles(container)[IdControle.pot1]!.alvos.single.minimo, greaterThan(-60),
        reason: 'o knob do mínimo grava a faixa ao soltar');

    await tester.enterText(find.byKey(const ValueKey('campo-nome-controle')), 'Comp');
    await tocar(tester, 'fechar-controle');
    expect(controles(container)[IdControle.pot1]!.nome, 'Comp');
    expect(container.read(editorProvider).naoSalvo, isTrue);

    await tocar(tester, 'controle-pot1');
    await tocar(tester, 'soltar-controle');
    expect(controles(container).containsKey(IdControle.pot1), isFalse);
  });

  testWidgets('should_put_a_footswitch_on_the_block_from_its_menu_and_clear_it_from_the_dialog', (tester) async {
    final container = await abrirDemonstracao(tester);
    await tocarNoSlot(tester, '01C');

    await tocar(tester, 'mais-acoes-bloco');
    await tocar(tester, 'menu-foot2');
    final foot = controles(container)[IdControle.foot2]!;
    expect(foot.alvos.single.ehBypass, isTrue);
    expect(foot.alvos.single.posicao, const PosicaoBloco(1, 1));
    expect(foot.nome, 'Compressor / Limiter', reason: 'o nome do bloco no catálogo, como nos presets gravados');
    expect(foot.valor, 1, reason: 'o bloco está ligado');

    await tocar(tester, 'controle-foot2');
    await tocar(tester, 'remover-alvo-0');
    expect(controles(container).containsKey(IdControle.foot2), isFalse, reason: 'sem alvo, o controle sai');
  });
}
