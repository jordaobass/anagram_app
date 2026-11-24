// O tema da tela da pedaleira na área de configuração (DECISOES PT), ponta a
// ponta na demonstração e no tema CLARO (os outros testes de tela rodam no
// escuro): o painel do Ignissor e o do Entropia saem em alumínio, o do Axioma
// em synthwave, e os controles dentro dele pintam com a paleta do tema e
// continuam mandando o valor à pedaleira. Os outros blocos ficam no case.
import 'dart:async';

import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/aplicacao/tema.dart';
import 'package:anagram_app/apresentacao/tema/paleta.dart';
import 'package:anagram_app/apresentacao/tema/tema_painel.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';
import '../apoio/fixtures.dart';

const _casa = PosicaoBloco(1, 4);

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

/// A paleta com que o controle [chave] é pintado.
Paleta _paletaDo(WidgetTester tester, String chave) =>
    Theme.of(tester.element(find.byKey(ValueKey(chave)))).extension<Paleta>()!;

Future<void> _rolarAte(WidgetTester tester, Finder alvo) async {
  await tester.ensureVisible(alvo);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('should_dress_the_axioma_panel_in_synthwave_and_still_send_a_new_cutoff_to_the_pedal', (tester) async {
    const uri = 'urn:darkglass:axioma_synth';
    final c = await _comBloco(tester, uri);
    expect(find.byKey(const ValueKey('tema-painel-neon')), findsOneWidget);
    final neon = TemaPainel.neon(Brightness.light);
    expect([_paletaDo(tester, 'param-cutoff').painel, _paletaDo(tester, 'param-cutoff').daFamilia(lerCatalogo().definicao(uri).familia)],
        [neon.paleta.painel, neon.destaque],
        reason: 'o knob se pinta com a paleta do painel, não com a do app');

    final corte = find.byKey(const ValueKey('param-cutoff'));
    await _rolarAte(tester, corte);
    await tester.drag(corte, const Offset(0, -80));
    await tester.pumpAndSettle();
    final novo = _valor(c, 'cutoff')!;
    expect(novo, greaterThan(5.5));
    expect(_tocando(c, uri, 'cutoff'), novo, reason: 'o tema não muda o que vai para a pedaleira');
  });

  testWidgets('should_dress_the_ignissor_panel_in_brushed_metal_and_keep_the_band_solo', (tester) async {
    final c = await _comBloco(tester, 'urn:darkglass:ignissor');
    expect(find.byKey(const ValueKey('tema-painel-metal')), findsOneWidget);
    final solo = find.byKey(const ValueKey('solo-medios'));
    await _rolarAte(tester, solo);
    expect(Theme.of(tester.element(solo)).extension<TemaPainel>()?.estilo, EstiloPainel.metal);

    await tester.tap(solo);
    await tester.pumpAndSettle();
    expect([_valor(c, 'lo_mute'), _valor(c, 'mid_mute'), _valor(c, 'hi_mute')], [1, 0, 1]);
  });

  testWidgets('should_dress_the_entropia_panel_in_brushed_metal_and_open_its_templates', (tester) async {
    await _comBloco(tester, 'urn:darkglass:entropia');
    expect(find.byKey(const ValueKey('tema-painel-metal')), findsOneWidget);
    final templates = find.byKey(const ValueKey('abrir-templates'));
    await _rolarAte(tester, templates);
    await tester.tap(templates);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('should_keep_any_other_block_on_the_app_case', (tester) async {
    final c = await _comBloco(tester, 'urn:darkglass:axioma_synth');
    // o 01A já traz outros blocos: o primeiro deles fica no case de sempre
    final atual = c.read(editorProvider).atual!;
    final outro = [for (var casa = 1; casa <= 12; casa++) PosicaoBloco(1, casa)]
        .firstWhere((p) => p != _casa && atual.bloco(p) != null);
    c.read(editorProvider.notifier).selecionarBloco(outro);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('tema-painel-neon')), findsNothing);
    expect(find.byKey(const ValueKey('tema-painel-metal')), findsNothing);
  });
}
