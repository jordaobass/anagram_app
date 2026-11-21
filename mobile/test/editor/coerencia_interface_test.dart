// Coerência da interface: o que a revisão de UI achou que confundia quem usa
// (lista escondida no celular, buracos da cadeia sumindo, SALVAR sempre em
// destaque, botões ativos enquanto o Salvar como espera o destino).
import 'dart:async';

import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';
import 'celular_test.dart' show abrirNoCelular;

void main() {
  testWidgets('should_show_a_presets_affordance_next_to_the_slot_when_the_list_is_in_another_screen', (tester) async {
    await abrirNoCelular(tester, '02A');

    final slot = find.byKey(const ValueKey('abrir-lista'));
    expect(find.descendant(of: slot, matching: find.text('PRESETS')), findsOneWidget,
        reason: 'um número sozinho não diz que abre a lista');

    await tester.tap(slot);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('slot-01A')), findsOneWidget);
  });

  testWidgets('should_keep_the_real_slot_positions_with_empty_gaps_when_the_chain_is_shown_on_a_phone', (tester) async {
    // 02A tem blocos nas casas 1, 2, 3, 5 e 7
    await abrirNoCelular(tester, '02A');

    for (final buraco in [4, 6]) {
      expect(find.byKey(ValueKey('casa-1-$buraco')), findsOneWidget, reason: 'a casa $buraco vazia aparece com "+"');
    }
    final container = containerDaTela(tester);
    await tester.tap(find.byKey(const ValueKey('casa-1-7')));
    await tester.pumpAndSettle();
    expect(container.read(editorProvider).selecionado, const PosicaoBloco(1, 7));
  });

  testWidgets('should_make_save_prominent_only_when_there_are_unsaved_edits', (tester) async {
    final container = await abrirDemonstracao(tester);
    await tocarNoSlot(tester, '01A');
    expect(tester.widget(find.byKey(const ValueKey('botao-salvar'))), isNot(isA<FilledButton>()),
        reason: 'sem edição, nada pede para ser salvo');

    // sem await: o envio ao vivo só anda no pump (relógio falso)
    unawaited(container.read(editorProvider.notifier).renomear('Editado'));
    await tester.pumpAndSettle();
    expect(tester.widget(find.byKey(const ValueKey('botao-salvar'))), isA<FilledButton>());
  });

  testWidgets('should_disable_the_top_save_buttons_when_the_list_is_choosing_the_save_as_target', (tester) async {
    await abrirDemonstracao(tester);
    await tocarNoSlot(tester, '01A');

    await tester.tap(find.byKey(const ValueKey('botao-salvar-como')));
    await tester.pumpAndSettle();

    for (final chave in ['botao-salvar', 'botao-salvar-como', 'botao-descartar']) {
      final botao = tester.widget<ButtonStyleButton>(find.byKey(ValueKey(chave)));
      expect(botao.onPressed, isNull, reason: '$chave parado: a ação agora está na lista');
    }
  });

  bool ligado(ProviderContainer container, PosicaoBloco posicao) {
    final estado = container.read(editorProvider);
    return estado.atual!.bloco(posicao)!.habilitadoNaCena(estado.atual!.cenaAtiva);
  }

  testWidgets('should_select_the_block_right_away_and_not_toggle_it_when_it_is_clicked_once', (tester) async {
    final container = await abrirDemonstracao(tester);
    await tocarNoSlot(tester, '02A');
    const posicao = PosicaoBloco(1, 2);
    final antes = ligado(container, posicao);

    await tester.tap(find.byKey(const ValueKey('casa-1-2')));
    await tester.pump(const Duration(milliseconds: 50));

    expect(container.read(editorProvider).selecionado, posicao, reason: 'sem esperar o tempo do toque duplo');
    await tester.pumpAndSettle(const Duration(milliseconds: 100), EnginePhase.sendSemanticsUpdate, const Duration(seconds: 1));
    expect(ligado(container, posicao), antes, reason: 'um clique só seleciona');
  });

  testWidgets('should_toggle_the_block_when_the_pedal_icon_in_the_panel_is_double_clicked', (tester) async {
    final container = await abrirDemonstracao(tester);
    await tocarNoSlot(tester, '02A');
    final posicao = container.read(editorProvider).selecionado!;
    final antes = ligado(container, posicao);
    final icone = find.byKey(const ValueKey('icone-pedal-painel'));

    await tester.tap(icone);
    await tester.pump(const Duration(milliseconds: 80));
    await tester.tap(icone);
    await tester.pumpAndSettle();

    expect(ligado(container, posicao), !antes, reason: 'duplo clique no pedal = o mesmo que o botão LIGADO');
  });
}
