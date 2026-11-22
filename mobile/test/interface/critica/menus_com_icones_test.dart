// Menus legíveis de relance: cada item do menu do preset e do bloco tem
// ícone; "Limpar preset…" fica em vermelho de erro, separado por divisor; o
// menu de arquivo do editor é uma pasta (não o ⇅) no computador; e CANCELAR de
// diálogo é texto neutro, nunca âmbar.
import 'package:anagram_app/apresentacao/tema/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../apoio/demonstracao_na_tela.dart';
import '../../apoio/textos_pt.dart';

Future<void> _tocar(WidgetTester tester, Finder alvo) async {
  await tester.ensureVisible(alvo);
  await tester.pumpAndSettle();
  await tester.tap(alvo);
  await tester.pumpAndSettle();
}

/// Todo item do menu aberto tem um ícone.
void _todosComIcone(WidgetTester tester) {
  final itens = find.byWidgetPredicate((w) => w is PopupMenuItem);
  expect(itens, findsWidgets);
  for (final item in itens.evaluate()) {
    expect(find.descendant(of: find.byWidget(item.widget), matching: find.byType(Icon)), findsWidgets,
        reason: 'item ${item.widget.key} sem ícone');
  }
}

void main() {
  testWidgets('should_give_every_preset_menu_item_an_icon_and_set_clear_apart_in_the_error_color', (tester) async {
    await abrirDemonstracao(tester);
    await _tocar(tester, find.byKey(const ValueKey('menu-preset-01A')));

    _todosComIcone(tester);
    final limpar = find.byKey(const ValueKey('op-limpar'));
    final texto = tester.widget<Text>(find.descendant(of: limpar, matching: find.text(textosPt.mpLimpar)));
    expect(texto.style?.color, Paleta.escura.erro);
    final divisores = find.byType(PopupMenuDivider).evaluate().map((e) => tester.getCenter(find.byWidget(e.widget)).dy);
    final exportar = tester.getCenter(find.byKey(const ValueKey('op-exportar'))).dy;
    expect(divisores.any((y) => y > exportar && y < tester.getCenter(limpar).dy), isTrue,
        reason: 'divisor entre exportar e limpar');
  });

  testWidgets('should_give_every_block_menu_item_an_icon', (tester) async {
    await abrirComBloco(tester, 'urn:darkglass:ignissor');
    await _tocar(tester, find.byKey(const ValueKey('mais-acoes-bloco')));

    _todosComIcone(tester);
  });

  testWidgets('should_show_the_editor_file_menu_as_a_file_icon_with_its_name_on_the_desktop', (tester) async {
    await abrirDemonstracao(tester);
    await tocarNoSlot(tester, '01A');
    final menu = find.byKey(const ValueKey('menu-preset'));

    expect(find.descendant(of: menu, matching: find.byIcon(Icons.folder_open_outlined)), findsOneWidget);
    expect(tester.widget<PopupMenuButton<Object?>>(menu).tooltip, textosPt.uiMenuArquivo);
  });

  testWidgets('should_write_cancel_in_neutral_text_in_the_templates_dialog', (tester) async {
    await abrirComBloco(tester, 'urn:darkglass:ignissor', tamanho: const Size(1440, 2400));
    await _tocar(tester, find.byKey(const ValueKey('abrir-templates')));

    final cancelar = find.widgetWithText(TextButton, textosPt.cancelar);
    final estilo = tester.widget<TextButton>(cancelar).style;
    expect(estilo?.foregroundColor?.resolve({}), Paleta.escura.texto);
  });
}
