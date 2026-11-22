// Item de menu se lê como menu de sistema, não como botão: Barlow 15px/500,
// sem a condensada em negrito do rótulo de botão (que deixava o menu do botão
// direito pesado, relato do dono). Com mouse o item é compacto (40px); no
// toque continua no alvo mínimo de 48dp (DECISOES UI12).
import 'package:anagram_app/apresentacao/componentes/seletor_opcao.dart';
import 'package:anagram_app/apresentacao/tema/tema_app.dart';
import 'package:anagram_app/apresentacao/tema/tokens.dart';
import 'package:anagram_app/nucleo/catalogo/definicao_bloco.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../apoio/demonstracao_na_tela.dart';
import '../../apoio/textos_pt.dart';

final _computador = TargetPlatformVariant.only(TargetPlatform.windows);

Future<void> _tocar(WidgetTester tester, Finder alvo) async {
  await tester.ensureVisible(alvo);
  await tester.pumpAndSettle();
  await tester.tap(alvo);
  await tester.pumpAndSettle();
}

/// O estilo com que o texto do item é de fato desenhado (tema + o do próprio Text).
TextStyle _estiloDesenhado(WidgetTester tester, String rotulo) {
  final elemento = tester.element(find.text(rotulo));
  final proprio = tester.widget<Text>(find.text(rotulo)).style;
  return DefaultTextStyle.of(elemento).style.merge(proprio);
}

void _confereTipoDeMenu(TextStyle estilo) {
  expect(estilo.fontFamily, Fontes.ui, reason: 'menu em Barlow, não na condensada de rótulo');
  expect(estilo.fontSize, Tipos.itemMenu.fontSize);
  expect(estilo.fontWeight, FontWeight.w500, reason: 'peso médio, não o negrito de botão');
  expect(estilo.letterSpacing ?? 0, lessThan(0.5), reason: 'sem o espaçamento largo de rótulo');
}

void main() {
  testWidgets('should_draw_preset_menu_items_in_the_menu_type_compact_with_the_mouse', (tester) async {
    await abrirDemonstracao(tester);
    await _tocar(tester, find.byKey(const ValueKey('menu-preset-01A')));

    _confereTipoDeMenu(_estiloDesenhado(tester, textosPt.opMoverPara));
    expect(tester.getSize(find.byKey(const ValueKey('op-mover'))).height, Medidas.alturaItemMenuComMouse);
    final limpar = _estiloDesenhado(tester, textosPt.mpLimpar);
    _confereTipoDeMenu(limpar);
    expect(limpar.color, Cores.erro);
  }, variant: _computador);

  testWidgets('should_draw_block_menu_items_in_the_menu_type', (tester) async {
    await abrirComBloco(tester, 'urn:darkglass:ignissor');
    await _tocar(tester, find.byKey(const ValueKey('mais-acoes-bloco')));

    _confereTipoDeMenu(_estiloDesenhado(tester, textosPt.copiarBloco));
  }, variant: _computador);

  testWidgets('should_keep_menu_items_at_the_touch_target_on_touch_devices', (tester) async {
    await abrirDemonstracao(tester);
    await _tocar(tester, find.byKey(const ValueKey('menu-preset-01A')));

    expect(tester.getSize(find.byKey(const ValueKey('op-mover'))).height, Medidas.alvoMinimo);
  });

  testWidgets('should_mark_the_current_option_with_an_amber_check_in_a_compact_menu_item', (tester) async {
    const parametro = DefinicaoParametro(
        simbolo: 'modo', nome: 'Modo', minimo: 0, maximo: 2, padrao: 0, inteiro: true, opcoes: ['Leve', 'Médio', 'Pesado']);
    await tester.pumpWidget(MaterialApp(
      theme: TemaApp.escuro(),
      home: Scaffold(
          body: SeletorOpcao(parametro: parametro, valor: 1, cor: Cores.aluminio, largura: 240, aoMudar: (_, {required arrastando}) {})),
    ));
    await _tocar(tester, find.byKey(const ValueKey('abrir-modo')));

    final marcada = find.byKey(const ValueKey('opcao-modo-1'));
    expect(find.descendant(of: marcada, matching: find.byIcon(Icons.check)), findsOneWidget);
    expect(tester.widget<Icon>(find.descendant(of: marcada, matching: find.byIcon(Icons.check))).color, Cores.tally);
    expect(find.descendant(of: find.byKey(const ValueKey('opcao-modo-0')), matching: find.byIcon(Icons.check)), findsNothing);
    expect(tester.getSize(marcada).height, Medidas.alturaItemMenuComMouse, reason: 'sem o ListTile de 56px');
    _confereTipoDeMenu(_estiloDesenhado(tester, 'Pesado'));
  }, variant: _computador);
}
