// Painel do multibanda na tela: arrastar o corte na faixa e o fader de uma
// banda muda o preset e o que a pedaleira toca; voltar ao padrão oferece
// desfazer; no celular as bandas viram abas; os 37 drives se acham buscando.
import 'dart:async';

import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';
import '../apoio/fixtures.dart';

const _casa = PosicaoBloco(1, 4);

Future<ProviderContainer> _comBloco(WidgetTester tester, String uri, {Size tamanho = const Size(1440, 2400)}) async {
  final container = await abrirDemonstracao(tester, tamanho: tamanho);
  unawaited(container.read(editorProvider.notifier).abrirSlot(SlotPreset.doRotulo('01A')));
  await tester.pumpAndSettle();
  unawaited(container.read(editorProvider.notifier).adicionarBloco(_casa, lerCatalogo().definicao(uri)));
  await tester.pumpAndSettle();
  return container;
}

num? _valor(ProviderContainer c, String simbolo) => c.read(editorProvider).atual!.bloco(_casa)!.valorBase(simbolo);

/// O valor que a pedaleira de demonstração está tocando agora.
num? _tocando(ProviderContainer c, String simbolo) {
  final pedaleira = c.read(conexaoProvider.notifier).transporte! as TransporteDemonstracao;
  final blocos = pedaleira.presetTocando!['preset']['chains']['1']['blocks'] as Map;
  final bloco = blocos.values.firstWhere((b) => b['uri'] == 'urn:darkglass:ignissor') as Map;
  final parametros = (bloco['parameters'] as Map).values;
  return parametros.firstWhere((p) => p['symbol'] == simbolo)['value'] as num?;
}

Future<void> _rolarAte(WidgetTester tester, Finder alvo) async {
  await tester.ensureVisible(alvo);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('should_move_the_crossover_and_a_band_threshold_live_and_undo_a_reset_when_editing_the_ignissor',
      (tester) async {
    final c = await _comBloco(tester, 'urn:darkglass:ignissor');
    final alca = find.byKey(const ValueKey('alca-lomid_xo_freq'));
    await _rolarAte(tester, alca);

    await tester.drag(alca, const Offset(120, 0));
    await tester.pumpAndSettle();
    final corte = _valor(c, 'lomid_xo_freq')!;
    expect(corte, greaterThan(250));
    expect(_tocando(c, 'lomid_xo_freq'), corte);

    final limiar = find.byKey(const ValueKey('param-mid_threshold'));
    await _rolarAte(tester, limiar);
    await tester.drag(limiar, const Offset(0, -60));
    await tester.pumpAndSettle();
    final arrastado = _valor(c, 'mid_threshold')!;
    expect(arrastado, greaterThan(-30));
    expect(_valor(c, 'lo_threshold'), -30, reason: 'só a banda do meio mudou');
    expect(_tocando(c, 'mid_threshold'), arrastado);

    await tester.longPress(limiar);
    await tester.pumpAndSettle();
    expect(_valor(c, 'mid_threshold'), -30);
    await tester.tap(find.text('DESFAZER'));
    await tester.pumpAndSettle();
    expect(_valor(c, 'mid_threshold'), arrastado);
    expect(c.read(editorProvider).naoSalvo, isTrue);
  });

  testWidgets('should_mute_a_band_when_its_mute_button_is_tapped', (tester) async {
    final c = await _comBloco(tester, 'urn:darkglass:ignissor');
    final mudo = find.byKey(const ValueKey('mudo-hi_mute'));
    await _rolarAte(tester, mudo);

    await tester.tap(mudo);
    await tester.pumpAndSettle();

    expect(_valor(c, 'hi_mute'), 1);
  });

  testWidgets('should_show_one_band_at_a_time_in_tabs_when_the_screen_is_narrow', (tester) async {
    await _comBloco(tester, 'urn:darkglass:ignissor', tamanho: const Size(390, 1800));
    expect(find.byKey(const ValueKey('coluna-graves')), findsOneWidget);
    expect(find.byKey(const ValueKey('coluna-medios')), findsNothing);

    await tester.tap(find.text('MÉDIOS'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('coluna-medios')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('should_find_and_pick_an_entropia_drive_type_by_searching_its_words', (tester) async {
    final c = await _comBloco(tester, 'urn:darkglass:entropia');
    final abrir = find.byKey(const ValueKey('abrir-mid_drive_typemode'));
    await _rolarAte(tester, abrir);

    await tester.tap(abrir);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('buscar-opcao')), 'turbo grunt');
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('opcao-mid_drive_typemode-1')), findsNothing, reason: '"B3K Flat" não casa');
    await tester.tap(find.text('B3K Turbo Grunt'));
    await tester.pumpAndSettle();

    expect(_valor(c, 'mid_drive_typemode'), 22);
  });
}
