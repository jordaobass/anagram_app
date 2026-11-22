// O texto fixo do painel saiu da frente: as dicas de gesto do bloco ficam
// atrás de um "?", e "Controles da pedaleira" recolhe — aberto por padrão só
// quando o preset tem controle atribuído, e lembrando a escolha da pessoa.
// O 01C da demonstração não tem controle atribuído; o 01A tem.
import 'package:anagram_app/apresentacao/componentes/casa_arrastavel.dart' show arrastoComMouse;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../apoio/app_de_teste.dart';
import '../../apoio/demonstracao_na_tela.dart';
import '../../apoio/textos_pt.dart';

const _metro = 'https://cognate.audio/plugins/cognate-metro';
final _cartao = find.byKey(const ValueKey('controle-pot1'));
final _cabecalho = find.byKey(const ValueKey('cabecalho-controles'));

Future<void> _tocar(WidgetTester tester, Finder alvo) async {
  await tester.ensureVisible(alvo);
  await tester.pumpAndSettle();
  await tester.tap(alvo);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('should_keep_the_block_gesture_tips_behind_a_help_button_until_it_is_pressed', (tester) async {
    await abrirComBloco(tester, _metro);
    final dica = arrastoComMouse ? textosPt.ttDicaMouse : textosPt.ttDicaToque;
    expect(find.textContaining(dica), findsNothing, reason: 'nada de três linhas fixas em todo bloco');

    await _tocar(tester, find.byKey(const ValueKey('dicas-bloco')));

    expect(find.textContaining(dica), findsOneWidget);
    expect(find.textContaining(arrastoComMouse ? textosPt.uiDicaDuploClique : textosPt.uiDicaToqueDuplo), findsOneWidget);
  });

  testWidgets('should_collapse_the_pedal_controls_of_a_preset_without_assignments_and_remember_opening_them',
      (tester) async {
    final preferencias = PreferenciasPaineisEmMemoria();
    await montarApp(tester, tamanho: const Size(1440, 2000), preferenciasPaineis: preferencias);
    await entrarNaDemonstracao(tester);
    await tocarNoSlot(tester, '01C');
    await rolarEditorAte(tester, _cabecalho);
    expect(_cartao, findsNothing, reason: 'preset sem atribuição: recolhido');

    await _tocar(tester, _cabecalho);
    expect(_cartao, findsOneWidget);
    expect(preferencias.controlesAbertos, isTrue);

    // o app fecha e abre de novo com as mesmas preferências
    await tester.pumpWidget(const SizedBox.shrink());
    await montarApp(tester, tamanho: const Size(1440, 2000), preferenciasPaineis: preferencias);
    await entrarNaDemonstracao(tester);
    await tocarNoSlot(tester, '01C');
    await rolarEditorAte(tester, _cabecalho);
    expect(_cartao, findsOneWidget, reason: 'a escolha de abrir foi lembrada');
  });

  testWidgets('should_open_the_pedal_controls_by_default_once_the_preset_has_an_assignment', (tester) async {
    await abrirComBloco(tester, _metro, slot: '01C');
    await rolarEditorAte(tester, _cabecalho);
    expect(_cartao, findsNothing);

    await voltarAoTopoDoEditor(tester);
    await _tocar(tester, find.byKey(const ValueKey('mais-acoes-bloco')));
    await tester.tap(find.byKey(const ValueKey('menu-foot2')));
    await tester.pumpAndSettle();
    await rolarEditorAte(tester, _cabecalho);

    expect(_cartao, findsOneWidget, reason: 'com o FOOT 2 atribuído o painel abre sozinho');
  });
}
