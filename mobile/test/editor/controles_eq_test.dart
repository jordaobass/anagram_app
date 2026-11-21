// Controles do EQ na tela: a chave da banda do paramétrico liga a banda e o
// fader do GEQ sobe com o arraste para cima.
import 'dart:async';

import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';
import '../apoio/fixtures.dart';

const _casa = PosicaoBloco(1, 4);

Future<ProviderContainer> _comBloco(WidgetTester tester, String uri) async {
  final container = await abrirDemonstracao(tester, tamanho: const Size(1440, 2400));
  await tocarNoSlot(tester, '01A');
  unawaited(container.read(editorProvider.notifier).adicionarBloco(_casa, lerCatalogo().definicao(uri)));
  await tester.pumpAndSettle();
  return container;
}

num? _valor(ProviderContainer c, String simbolo) => c.read(editorProvider).atual!.bloco(_casa)!.valorBase(simbolo);

void main() {
  testWidgets('should_turn_a_parametric_band_on_when_its_switch_is_tapped', (tester) async {
    final container = await _comBloco(tester, 'urn:darkglass:fil4#mono');
    expect(_valor(container, 'HighPass') ?? 0, 0);

    await tester.tap(find.byKey(const ValueKey('chave-HighPass')));
    await tester.pumpAndSettle();
    expect(_valor(container, 'HighPass'), 1);
    expect(container.read(editorProvider).naoSalvo, isTrue);
  });

  testWidgets('should_raise_a_graphic_eq_band_when_its_fader_is_dragged_up', (tester) async {
    final container = await _comBloco(tester, 'urn:darkglass:DarkglassGEQ');

    await tester.drag(find.byKey(const ValueKey('param-S250Hz')), const Offset(0, -50));
    await tester.pumpAndSettle();

    expect(_valor(container, 'S250Hz'), greaterThan(0));
  });
}
