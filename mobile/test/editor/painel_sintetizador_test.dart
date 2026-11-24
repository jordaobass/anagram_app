// Painel do Axioma na tela: girar o Cutoff e trocar a onda do Osc 1 mudam o
// preset e o que a pedaleira toca, e os desenhos acompanham; o arpejador
// liga pela chave do cartão; no celular as seções empilham sem estourar.
import 'dart:async';

import 'package:anagram_app/apresentacao/componentes/cartao_template.dart';
import 'package:anagram_app/apresentacao/componentes/desenhos_sintetizador.dart';
import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/catalogo/desenho_sintetizador.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';
import '../apoio/fixtures.dart';

const _casa = PosicaoBloco(1, 4);
const _axioma = 'urn:darkglass:axioma_synth';

Future<ProviderContainer> _comAxioma(WidgetTester tester, {Size tamanho = const Size(1440, 2600)}) async {
  final container = await abrirDemonstracao(tester, tamanho: tamanho);
  unawaited(container.read(editorProvider.notifier).abrirSlot(SlotPreset.doRotulo('01A')));
  await tester.pumpAndSettle();
  unawaited(container.read(editorProvider.notifier).adicionarBloco(_casa, lerCatalogo().definicao(_axioma)));
  await tester.pumpAndSettle();
  return container;
}

num? _valor(ProviderContainer c, String simbolo) => c.read(editorProvider).atual!.bloco(_casa)!.valorBase(simbolo);

/// O valor que a pedaleira de demonstração está tocando agora.
num? _tocando(ProviderContainer c, String simbolo) {
  final pedaleira = c.read(conexaoProvider.notifier).transporte! as TransporteDemonstracao;
  final blocos = pedaleira.presetTocando!['preset']['chains']['1']['blocks'] as Map;
  final bloco = blocos.values.firstWhere((b) => b['uri'] == _axioma) as Map;
  final parametros = (bloco['parameters'] as Map).values;
  return parametros.firstWhere((p) => p['symbol'] == simbolo)['value'] as num?;
}

T _pintor<T extends CustomPainter>(WidgetTester tester, String chave) =>
    tester.widget<CaixaDesenho>(find.byKey(ValueKey(chave))).pintor as T;

Future<void> _rolarAte(WidgetTester tester, Finder alvo) async {
  await tester.ensureVisible(alvo);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('should_play_a_new_cutoff_and_oscillator_wave_live_and_redraw_the_filter_and_the_wave', (tester) async {
    final c = await _comAxioma(tester);
    final corte = find.byKey(const ValueKey('param-cutoff'));
    await _rolarAte(tester, corte);

    await tester.drag(corte, const Offset(0, -80));
    await tester.pumpAndSettle();
    final novoCorte = _valor(c, 'cutoff')!;
    expect(novoCorte, greaterThan(5.5));
    expect(_tocando(c, 'cutoff'), novoCorte);
    expect(_pintor<PintorFiltro>(tester, 'ax-desenho-filtro').corte, novoCorte, reason: 'a curva acompanha o knob');

    expect(_pintor<PintorOnda>(tester, 'ax-onda-osc1_wave').forma, FormaOnda.serra);
    final onda = find.byKey(const ValueKey('param-osc1_wave'));
    await _rolarAte(tester, onda);
    await tester.tap(onda);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Square').last);
    await tester.pumpAndSettle();
    expect(_valor(c, 'osc1_wave'), 1);
    expect(_tocando(c, 'osc1_wave'), 1);
    expect(_pintor<PintorOnda>(tester, 'ax-onda-osc1_wave').forma, FormaOnda.quadrada);
    expect(c.read(editorProvider).naoSalvo, isTrue);
  });

  testWidgets('should_turn_the_arpeggiator_on_from_the_switch_in_its_card', (tester) async {
    final c = await _comAxioma(tester);
    final chave = find.byKey(const ValueKey('chave-arp_enable'));
    await _rolarAte(tester, chave);
    expect(find.descendant(of: find.byKey(const ValueKey('ax-arpejador')), matching: find.byKey(const ValueKey('param-TempoBPM'))),
        findsOneWidget, reason: 'desligado, o arpejador continua ajustável');

    await tester.tap(chave);
    await tester.pumpAndSettle();

    expect(_valor(c, 'arp_enable'), 1);
    expect(_tocando(c, 'arp_enable'), 1);
  });

  testWidgets('should_stack_the_sections_without_overflow_on_a_phone', (tester) async {
    await _comAxioma(tester, tamanho: const Size(390, 3600));

    for (final secao in ['entrada', 'osciladores', 'filtro', 'envelope', 'arpejador', 'saida']) {
      expect(find.byKey(ValueKey('ax-$secao')), findsOneWidget);
    }
    final filtro = tester.getTopLeft(find.byKey(const ValueKey('ax-filtro')));
    final envelope = tester.getTopLeft(find.byKey(const ValueKey('ax-envelope')));
    expect(envelope.dy, greaterThan(filtro.dy), reason: 'no celular, um cartão embaixo do outro');
    expect(tester.takeException(), isNull);
  });

  testWidgets('should_list_the_axioma_official_templates_disabled_while_their_values_are_not_read', (tester) async {
    await _comAxioma(tester);
    final abrir = find.byKey(const ValueKey('abrir-templates'));
    await _rolarAte(tester, abrir);

    await tester.tap(abrir);
    await tester.pumpAndSettle();

    for (final id in ['dg-filthy-funk', 'dg-burning-bass']) {
      final item = find.byKey(ValueKey('template-$id'));
      await _rolarAte(tester, item);
      expect(tester.widget<CartaoTemplate>(item).habilitado, isFalse, reason: '$id sem valores lidos não se aplica');
    }
  });
}
