// A tela da pedaleira na área de configuração (DECISOES PT), ponta a ponta
// na demonstração, com o app no tema CLARO em volta (a tela do aparelho não
// muda, PT9): o Axioma é o aparelho em neon e a barra dele faz o que diz; o
// Ignissor e o Entropia têm a barra de metal com o Templates compacto ao lado
// do nome; a janela "Select Block Template" aplica pelo cartão, não aplica o
// desabilitado e fecha com Esc. Os outros blocos ficam no case.
import 'dart:async';

import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/aplicacao/estado/escopo_cenas.dart';
import 'package:anagram_app/aplicacao/tema.dart';
import 'package:anagram_app/apresentacao/tema/paleta.dart';
import 'package:anagram_app/apresentacao/tema/tema_painel.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:anagram_app/nucleo/modelo/cenas_do_bloco.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';
import '../apoio/fixtures.dart';

const _casa = PosicaoBloco(1, 4);
const _axioma = 'urn:darkglass:axioma_synth';
const _ignissor = 'urn:darkglass:ignissor';

Future<ProviderContainer> _comBloco(WidgetTester tester, String uri) async {
  final c = await abrirDemonstracao(tester, tamanho: const Size(1440, 2600), tema: EscolhaTema.claro);
  unawaited(c.read(editorProvider.notifier).abrirSlot(SlotPreset.doRotulo('01A')));
  await tester.pumpAndSettle();
  unawaited(c.read(editorProvider.notifier).adicionarBloco(_casa, lerCatalogo().definicao(uri)));
  await tester.pumpAndSettle();
  return c;
}

num? _valor(ProviderContainer c, String simbolo) => c.read(editorProvider).atual!.bloco(_casa)!.valorBase(simbolo);

num? _tocando(ProviderContainer c, String uri, String simbolo) {
  final pedaleira = c.read(conexaoProvider.notifier).transporte! as TransporteDemonstracao;
  final blocos = pedaleira.presetTocando!['preset']['chains']['1']['blocks'] as Map;
  final bloco = blocos.values.firstWhere((b) => b['uri'] == uri) as Map;
  return (bloco['parameters'] as Map).values.firstWhere((p) => p['symbol'] == simbolo)['value'] as num?;
}

Paleta _paletaDo(WidgetTester tester, String chave) =>
    Theme.of(tester.element(find.byKey(ValueKey(chave)))).extension<Paleta>()!;

Future<void> _tocar(WidgetTester tester, Finder alvo) async {
  await tester.ensureVisible(alvo);
  await tester.pumpAndSettle();
  await tester.tap(alvo);
  await tester.pumpAndSettle();
}

/// Clique de mouse de verdade (passa por cima antes), como no computador.
Future<void> _clicarComMouse(WidgetTester tester, Finder alvo) async {
  await tester.ensureVisible(alvo);
  await tester.pumpAndSettle();
  final ponto = tester.getCenter(alvo);
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await mouse.addPointer(location: ponto);
  await mouse.moveTo(ponto);
  await tester.pumpAndSettle();
  await mouse.down(ponto);
  await tester.pump(const Duration(milliseconds: 60));
  await mouse.up();
  await mouse.removePointer();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('should_show_the_axioma_as_the_neon_device_even_with_the_light_app_and_send_a_new_cutoff', (tester) async {
    final c = await _comBloco(tester, _axioma);
    expect(find.byKey(const ValueKey('tema-painel-neon')), findsOneWidget);
    final neon = TemaPainel.neon();
    expect([_paletaDo(tester, 'param-cutoff').painel, _paletaDo(tester, 'param-cutoff').daFamilia(lerCatalogo().definicao(_axioma).familia)],
        [neon.paleta.painel, neon.destaque],
        reason: 'o knob se pinta com a paleta fixa do aparelho, não com a do app claro');

    final corte = find.byKey(const ValueKey('param-cutoff'));
    await tester.ensureVisible(corte);
    await tester.pumpAndSettle();
    await tester.drag(corte, const Offset(0, -80));
    await tester.pumpAndSettle();
    final novo = _valor(c, 'cutoff')!;
    expect(novo, greaterThan(5.5));
    expect(_tocando(c, _axioma, 'cutoff'), novo, reason: 'o tema não muda o que vai para a pedaleira');
  });

  testWidgets('should_switch_the_block_and_the_scene_scope_and_close_the_panel_from_the_axioma_bar', (tester) async {
    final c = await _comBloco(tester, _axioma);
    final ligado = c.read(editorProvider).atual!.bloco(_casa)!.habilitadoNaCena(c.read(editorProvider).atual!.cenaAtiva);

    await _tocar(tester, find.byKey(const ValueKey('ax-liga')));
    final agora = c.read(editorProvider).atual!.bloco(_casa)!.habilitadoNaCena(c.read(editorProvider).atual!.cenaAtiva);
    expect(agora, !ligado, reason: 'a pílula é o liga/desliga do bloco');

    final escopo = c.read(escopoCenasProvider);
    await _tocar(tester, find.byKey(const ValueKey('ax-controlar')));
    expect(c.read(escopoCenasProvider), isNot(escopo));
    expect(c.read(escopoCenasProvider), isIn(EscopoCenas.values));

    expect(find.text(c.read(editorProvider).slot!.rotulo), findsWidgets, reason: 'o LCD mostra o slot aberto');

    await _tocar(tester, find.byKey(const ValueKey('ax-fechar')));
    expect(c.read(editorProvider).selecionado, isNull);
    expect(find.byKey(const ValueKey('tema-painel-neon')), findsNothing, reason: 'o X fecha o painel');
  });

  testWidgets('should_put_a_compact_templates_button_beside_the_block_name_in_the_metal_bar', (tester) async {
    await _comBloco(tester, _ignissor);
    expect(find.byKey(const ValueKey('tema-painel-metal')), findsOneWidget);
    final barra = tester.getRect(find.byKey(const ValueKey('barra-painel')));
    final botao = tester.getRect(find.byKey(const ValueKey('abrir-templates')));
    final nome = tester.getRect(find.byKey(const ValueKey('letreiro-painel')));
    final faixa = tester.getRect(find.byKey(const ValueKey('faixa-frequencias')));
    expect(barra.contains(botao.center), isTrue, reason: 'o botão mora na barra');
    expect((botao.center.dy - nome.center.dy).abs(), lessThan(8), reason: 'na mesma linha do nome');
    expect(botao.left, greaterThan(nome.right), reason: 'logo depois do nome');
    expect(botao.bottom, lessThan(faixa.top), reason: 'acima do gráfico, sem linha própria');
    expect(botao.height, lessThanOrEqualTo(48));
  });

  testWidgets('should_apply_an_official_template_from_its_card_in_the_template_window', (tester) async {
    final c = await _comBloco(tester, _ignissor);
    final pickMetal = lerTemplates().de(_ignissor).firstWhere((t) => t.id == 'dg-pick-metal');
    await _tocar(tester, find.byKey(const ValueKey('abrir-templates')));
    expect(find.byKey(const ValueKey('janela-templates')), findsOneWidget);

    await _tocar(tester, find.byKey(const ValueKey('template-dg-pick-metal')));
    final bloco = c.read(editorProvider).atual!.bloco(_casa)!;
    expect({for (final s in pickMetal.valores!.keys) s: bloco.valorBase(s)}, pickMetal.valores);
    expect(find.byKey(const ValueKey('janela-templates')), findsNothing);
  });

  testWidgets('should_apply_an_available_template_with_a_mouse_click_on_windows', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final c = await _comBloco(tester, _ignissor);
    final pickMetal = lerTemplates().de(_ignissor).firstWhere((t) => t.id == 'dg-pick-metal');

    await _clicarComMouse(tester, find.byKey(const ValueKey('abrir-templates')));
    await _clicarComMouse(tester, find.byKey(const ValueKey('template-dg-pick-metal')));

    final bloco = c.read(editorProvider).atual!.bloco(_casa)!;
    expect({for (final s in pickMetal.valores!.keys) s: bloco.valorBase(s)}, pickMetal.valores);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('should_not_apply_a_template_without_values_and_close_the_window_with_escape', (tester) async {
    final c = await _comBloco(tester, _axioma);
    Map<String, num?> valores() {
      final bloco = c.read(editorProvider).atual!.bloco(_casa)!;
      return {for (final s in bloco.simbolosGuardados) s: bloco.valorBase(s)};
    }

    final antes = valores();
    await _tocar(tester, find.byKey(const ValueKey('abrir-templates')));
    await _tocar(tester, find.byKey(const ValueKey('template-dg-filthy-funk')));
    expect(valores(), antes, reason: 'sem valores lidos não aplica');
    expect(find.byKey(const ValueKey('janela-templates')), findsOneWidget);
    expect(find.descendant(of: find.byKey(const ValueKey('template-dg-filthy-funk')), matching: find.byKey(const ValueKey('selo-sem-valores'))),
        findsOneWidget, reason: 'o motivo fica à vista, sem precisar de hover');

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('janela-templates')), findsNothing);
  });

  testWidgets('should_keep_any_other_block_on_the_app_case', (tester) async {
    final c = await _comBloco(tester, _axioma);
    final atual = c.read(editorProvider).atual!;
    final outro = [for (var casa = 1; casa <= 12; casa++) PosicaoBloco(1, casa)]
        .firstWhere((p) => p != _casa && atual.bloco(p) != null);
    c.read(editorProvider.notifier).selecionarBloco(outro);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('tema-painel-neon')), findsNothing);
    expect(find.byKey(const ValueKey('tema-painel-metal')), findsNothing);
  });
}
