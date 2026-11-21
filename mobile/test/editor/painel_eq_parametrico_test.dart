// O bloco Parametric EQ tem a tela do Global EQ (é o mesmo equalizador): no
// modo Frequency o knob da banda 2 muda a frequência dela no preset e no que
// a pedaleira toca; a chave de uma seção tira a banda da curva; ligar o
// passa-altas desenha o corte; o Reset volta ao padrão e se desfaz.
import 'dart:async';

import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/apresentacao/componentes/pintor_global_eq.dart';
import 'package:anagram_app/nucleo/ajustes/curva_global_eq.dart';
import 'package:anagram_app/nucleo/ajustes/mapa_ajustes.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';
import '../apoio/fixtures.dart';

const _casa = PosicaoBloco(1, 4);
const _uri = 'urn:darkglass:fil4#mono';

Future<ProviderContainer> _comBloco(WidgetTester tester) async {
  final container = await abrirDemonstracao(tester, tamanho: const Size(1440, 2400));
  unawaited(container.read(editorProvider.notifier).abrirSlot(SlotPreset.doRotulo('01A')));
  await tester.pumpAndSettle();
  unawaited(container.read(editorProvider.notifier).adicionarBloco(_casa, lerCatalogo().definicao(_uri)));
  await tester.pumpAndSettle();
  return container;
}

num? _valor(ProviderContainer c, String simbolo) => c.read(editorProvider).atual!.bloco(_casa)!.valorBase(simbolo);

num? _tocando(ProviderContainer c, String simbolo) {
  final pedaleira = c.read(conexaoProvider.notifier).transporte! as TransporteDemonstracao;
  final blocos = pedaleira.presetTocando!['preset']['chains']['1']['blocks'] as Map;
  final bloco = blocos.values.firstWhere((b) => b['uri'] == _uri) as Map;
  final parametros = (bloco['parameters'] as Map).values;
  return parametros.firstWhere((p) => p['symbol'] == simbolo)['value'] as num?;
}

/// As bandas que a curva do bloco está desenhando agora.
List<BandaGlobalEq> _curva(WidgetTester tester) {
  final pintura = tester.widget<CustomPaint>(
      find.descendant(of: find.byKey(const ValueKey('curva-eq-bloco')), matching: find.byType(CustomPaint)).first);
  return (pintura.painter! as PintorGlobalEq).bandas;
}

Future<void> _tocar(WidgetTester tester, String chave) async {
  final alvo = find.byKey(ValueKey(chave));
  await tester.ensureVisible(alvo);
  await tester.pumpAndSettle();
  await tester.tap(alvo);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('should_change_band_two_frequency_live_when_the_frequency_mode_knob_is_turned', (tester) async {
    final c = await _comBloco(tester);
    await _tocar(tester, 'modo-eq-freq');

    final knob = find.byKey(const ValueKey('param-freq2'));
    await tester.ensureVisible(knob);
    await tester.drag(knob, const Offset(0, -60));
    await tester.pumpAndSettle();

    final frequencia = _valor(c, 'freq2')!;
    expect(frequencia, greaterThan(397));
    expect(_tocando(c, 'freq2'), frequencia, reason: 'a pedaleira toca a mudança ao vivo');
    expect(_valor(c, 'gain2') ?? 0, 0, reason: 'o modo Frequency só mexe na frequência');
    expect(c.read(editorProvider).naoSalvo, isTrue);
  });

  testWidgets('should_drop_a_band_from_the_curve_when_its_section_switch_is_turned_off', (tester) async {
    final c = await _comBloco(tester);
    expect(_curva(tester).where((b) => b.tipo == TipoBandaEq.peak).every((b) => b.ligada), isTrue);

    await _tocar(tester, 'chave-sec3');

    expect(_valor(c, 'sec3'), 0);
    final terceira = _curva(tester).where((b) => b.tipo == TipoBandaEq.peak).elementAt(2);
    expect(terceira.ligada, isFalse);
  });

  testWidgets('should_draw_the_low_cut_when_the_high_pass_is_turned_on', (tester) async {
    final c = await _comBloco(tester);
    BandaGlobalEq corte() => _curva(tester).firstWhere((b) => b.tipo == TipoBandaEq.highPass);
    expect(corte().ligada, isFalse);

    await _tocar(tester, 'chave-HighPass');

    expect(_valor(c, 'HighPass'), 1);
    expect(corte().ligada, isTrue);
    expect(respostaEmDb(_curva(tester), 8), lessThan(-6), reason: 'abaixo do corte o grave cai');
  });

  testWidgets('should_reset_every_parameter_to_the_block_default_and_undo_it', (tester) async {
    final c = await _comBloco(tester);
    await _tocar(tester, 'chave-sec3');
    expect(_valor(c, 'sec3'), 0);

    await _tocar(tester, 'eq-bloco-reset');
    await tester.tap(find.byKey(const ValueKey('confirmar-reset-eq-bloco')));
    await tester.pumpAndSettle();
    expect(_valor(c, 'sec3'), 1);
    expect(_valor(c, 'freq2'), 397);

    await tester.tap(find.text('DESFAZER'));
    await tester.pumpAndSettle();
    expect(_valor(c, 'sec3'), 0);
  });

  testWidgets('should_send_the_final_value_right_away_when_the_curve_point_is_released', (tester) async {
    final c = await _comBloco(tester);
    final curva = find.byKey(const ValueKey('curva-eq-bloco'));
    await tester.ensureVisible(curva);
    await tester.pumpAndSettle();
    final caixa = tester.getRect(curva);
    final banda2 = _curva(tester).firstWhere((b) => b.frequencia == 397);
    final ponto = caixa.topLeft + GeometriaGlobalEq(caixa.size).ponto(banda2);

    final gesto = await tester.startGesture(ponto);
    for (var i = 0; i < 4; i++) {
      await gesto.moveBy(const Offset(0, -10));
      await tester.pump();
    }
    await gesto.up();
    // menos que a janela de 100 ms do arraste: só o envio do soltar chega
    await tester.pump(const Duration(milliseconds: 30));

    final ganho = _valor(c, 'gain2')!;
    expect(ganho, greaterThan(0));
    expect(_tocando(c, 'gain2'), ganho, reason: 'ao soltar vai o valor final na hora (L1)');
    await tester.pumpAndSettle();
  });
}

