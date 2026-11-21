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

  testWidgets('should_pick_the_entropia_drive_by_type_and_mode_keeping_one_parameter', (tester) async {
    final c = await _comBloco(tester, 'urn:darkglass:entropia');
    final tipo = find.byKey(const ValueKey('abrir-tipo-mid_drive_typemode'));
    await _rolarAte(tester, tipo);
    expect(find.text('VMT'), findsWidgets, reason: 'o padrão é VMT Midboost 2');

    await tester.tap(tipo);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('tipo-mid_drive_typemode-B3K Turbo')));
    await tester.pumpAndSettle();
    expect(_valor(c, 'mid_drive_typemode'), 21, reason: 'B3K Turbo não tem Midboost 2: fica o primeiro modo (Flat)');

    await tester.tap(find.byKey(const ValueKey('abrir-modo-mid_drive_typemode')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('modo-mid_drive_typemode-Grunt')));
    await tester.pumpAndSettle();
    expect(_valor(c, 'mid_drive_typemode'), 22, reason: 'B3K Turbo Grunt');
  });

  testWidgets('should_apply_a_template_to_every_parameter_live_show_its_name_and_undo_all_of_it', (tester) async {
    final c = await _comBloco(tester, 'urn:darkglass:ignissor');
    expect(find.textContaining('Neutral Ground'), findsOneWidget, reason: 'o bloco novo está nos padrões');

    await tester.tap(find.byKey(const ValueKey('abrir-templates')));
    await tester.pumpAndSettle();
    expect(tester.widget<ListTile>(find.byKey(const ValueKey('template-dg-studio-glue'))).enabled, isFalse,
        reason: 'template oficial sem valores lidos não se aplica');
    await tester.tap(find.byKey(const ValueKey('template-app-grave-travado')));
    await tester.pumpAndSettle();

    expect([_valor(c, 'lo_threshold'), _valor(c, 'lo_ratio'), _valor(c, 'hi_comp_enabled')], [-36, 8, 0]);
    expect(_tocando(c, 'lo_threshold'), -36, reason: 'soou ao vivo');
    expect(find.textContaining('Grave travado'), findsWidgets);
    expect(c.read(editorProvider).naoSalvo, isTrue);

    final mudo = find.byKey(const ValueKey('mudo-mid_mute'));
    await _rolarAte(tester, mudo);
    await tester.tap(mudo);
    await tester.pumpAndSettle();
    expect(find.textContaining('Personalizado'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('abrir-templates')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('template-app-paralelo')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('DESFAZER'));
    await tester.pumpAndSettle();
    expect([_valor(c, 'lo_threshold'), _valor(c, 'clean_level'), _valor(c, 'mid_mute')], [-36, -24, 1],
        reason: 'o desfazer volta TODOS os valores de antes do template');
  });

  testWidgets('should_solo_a_band_by_muting_the_others_and_undo_it', (tester) async {
    final c = await _comBloco(tester, 'urn:darkglass:ignissor');
    final solo = find.byKey(const ValueKey('solo-medios'));
    await _rolarAte(tester, solo);

    await tester.tap(solo);
    await tester.pumpAndSettle();
    expect([_valor(c, 'lo_mute'), _valor(c, 'mid_mute'), _valor(c, 'hi_mute')], [1, 0, 1]);

    await tester.tap(find.text('DESFAZER'));
    await tester.pumpAndSettle();
    expect([_valor(c, 'lo_mute'), _valor(c, 'mid_mute'), _valor(c, 'hi_mute')], [0, 0, 0]);
  });

  testWidgets('should_drag_a_band_threshold_line_on_the_frequency_view', (tester) async {
    final c = await _comBloco(tester, 'urn:darkglass:ignissor');
    final linha = find.byKey(const ValueKey('traco-lo_threshold'));
    await _rolarAte(tester, linha);

    await tester.drag(linha, const Offset(0, -30));
    await tester.pumpAndSettle();

    expect(_valor(c, 'lo_threshold'), greaterThan(-30));
    expect(_valor(c, 'mid_threshold'), -30);
  });
}
