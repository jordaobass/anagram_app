// Tela de conectar com a cara do app e espera sem ambiguidade: o "01A" em
// estêncil e a fita gaffer com o nome; ao abrir a demonstração, o progresso
// aparece dentro do botão tocado, com a frase do que está acontecendo, e o
// outro botão fica desabilitado. Diálogos na largura do token (440) e todo
// diálogo de escolha com CANCELAR.
import 'package:anagram_app/aplicacao/estado/controlador_biblioteca.dart';
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/apresentacao/tema/tokens.dart';
import 'package:anagram_app/nucleo/modelo/presets_fabrica.dart';
import 'package:anagram_app/nucleo/protocolo/api_anagram.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../apoio/demonstracao_na_tela.dart';
import '../../apoio/fixtures.dart';
import '../../apoio/textos_pt.dart';

Future<void> _tocar(WidgetTester tester, Finder alvo) async {
  await tester.tap(alvo);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('should_open_the_connect_screen_with_the_stencil_slot_and_the_gaffer_tape_name', (tester) async {
    await montarApp(tester);

    expect(tester.widget<Text>(find.text('01A')).style?.fontFamily, Fontes.estencil);
    expect(tester.widget<Text>(find.text('Anagram App')).style?.fontFamily, Fontes.marcador);
  });

  testWidgets('should_show_progress_inside_the_pressed_button_and_disable_the_other_while_opening_the_demo',
      (tester) async {
    await montarApp(tester, overrides: [
      ajusteDemonstracaoProvider.overrideWithValue((p) => p.naoResponder = AcoesAnagram.firmware),
    ]);
    final demonstracao = find.byKey(const ValueKey('botao-demonstracao'));
    await tester.tap(demonstracao);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.descendant(of: demonstracao, matching: find.byType(CircularProgressIndicator)), findsOneWidget);
    expect(find.descendant(of: demonstracao, matching: find.text(textosPt.txEstadoAbrindoDemonstracao)), findsOneWidget);
    expect(tester.widget<ButtonStyleButton>(find.byKey(const ValueKey('botao-conectar'))).onPressed, isNull);
    expect(find.byType(LinearProgressIndicator), findsNothing, reason: 'nada de barra solta longe do botão');

    await tester.tap(find.byKey(const ValueKey('botao-cancelar-conexao')));
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('should_keep_the_clear_preset_dialog_within_the_dialog_width_token', (tester) async {
    await abrirDemonstracao(tester);
    await _tocar(tester, find.byKey(const ValueKey('menu-preset-01A')));
    await _tocar(tester, find.byKey(const ValueKey('op-limpar')));

    // a superfície do diálogo (o AlertDialog em si ocupa a tela toda)
    final superficie = find.descendant(of: find.byKey(const ValueKey('dialogo-limpar-preset')), matching: find.byType(Material));
    expect(tester.getSize(superficie.first).width, lessThanOrEqualTo(Medidas.larguraDialogo));
  });

  testWidgets('should_offer_cancel_when_asking_which_area_to_copy_a_factory_preset_to', (tester) async {
    final container = await abrirDemonstracao(tester, fabrica: PresetsDeFabrica.doTexto(textoFabricaDeTeste()));
    await _tocar(tester, find.byKey(const ValueKey('seletor-area')));
    await _tocar(tester, find.byKey(const ValueKey('area-${PresetsDeFabrica.idArea}')).last);
    await tocarNoSlot(tester, '01B');
    await _tocar(tester, find.byKey(const ValueKey('botao-salvar')));

    await _tocar(tester, find.widgetWithText(TextButton, textosPt.cancelar));

    expect(find.byKey(const ValueKey('copiar-para-user-2')), findsNothing, reason: 'o diálogo fechou');
    expect(container.read(bibliotecaProvider).areaSelecionada, PresetsDeFabrica.idArea);
  });
}
