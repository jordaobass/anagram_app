// No painel do Bass Cabinet a pessoa escolhe o gabinete como na pedaleira:
// modelo, microfone e posição; o IR escolhido vai para o bloco e soa na hora.
import 'package:anagram_app/aplicacao/arte/indice_miniaturas.dart';
import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:anagram_app/nucleo/protocolo/api_anagram.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';
import '../nucleo/catalogo_gabinetes_test.dart' show catalogoDeTeste;

// 01B é o exemplo 2 da pedaleira: Bass Cabinet na linha 1, casa 9, com o IR
// "212 103 on axis_01-MP" (Darkglass Neo 2x12, Condenser 103, Cap On Axis)
const _gabinete = PosicaoBloco(1, 9);

final _comEscolhas = IndiceMiniaturas(const {}, const {}, '', escolhasDeGabinete: catalogoDeTeste);

Future<ProviderContainer> _abrirGabinete(WidgetTester tester, {IndiceMiniaturas? indice}) async {
  final container = await abrirDemonstracao(tester, indice: indice);
  await tocarNoSlot(tester, '01B');
  container.read(editorProvider.notifier).selecionarBloco(_gabinete);
  await tester.pumpAndSettle();
  return container;
}

/// O modelo aparece escrito no campo de busca do gabinete.
String? _modeloNaTela(WidgetTester tester) => tester
    .widget<TextField>(find.descendant(of: find.byKey(const ValueKey('gabinete-modelo')), matching: find.byType(TextField)))
    .controller
    ?.text;

bool _marcado(WidgetTester tester, String chave) =>
    tester.widget<Semantics>(find.byKey(ValueKey(chave))).properties.selected == true;

Future<void> _tocar(WidgetTester tester, String chave) async {
  await tester.ensureVisible(find.byKey(ValueKey(chave)));
  await tester.tap(find.byKey(ValueKey(chave)));
  await tester.pumpAndSettle();
}

String? _irDoBloco(ProviderContainer c) => c.read(editorProvider).atual!.bloco(_gabinete)!.arquivoDeIr;

void main() {
  testWidgets('should_show_model_mic_and_position_of_the_cabinet_ir_in_the_block_panel', (tester) async {
    await _abrirGabinete(tester, indice: _comEscolhas);

    expect(_modeloNaTela(tester), 'Darkglass Neo 2x12');
    expect(_marcado(tester, 'microfone-Condenser 103'), isTrue);
    expect(_marcado(tester, 'posicao-Cap On Axis'), isTrue);
    expect(_marcado(tester, 'posicao-Edge On Axis'), isFalse);
  });

  testWidgets('should_filter_the_models_and_write_the_new_ir_live_when_typing_part_of_the_name', (tester) async {
    final container = await _abrirGabinete(tester, indice: _comEscolhas);
    final pedaleira = container.read(conexaoProvider.notifier).transporte! as TransporteDemonstracao;
    final enviosAntes = pedaleira.comandosRecebidos.where((c) => c.acao == AcoesAnagram.tocarAoVivo).length;
    final campo = find.descendant(of: find.byKey(const ValueKey('gabinete-modelo')), matching: find.byType(TextField));

    await tester.tap(campo);
    await tester.enterText(campo, 'yell');
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('sugestao-Darkglass Neo 2x12')), findsNothing, reason: 'só os que têm "yell"');
    await tester.tap(find.byKey(const ValueKey('sugestao-Black & Yellow 4x10')));
    await tester.pumpAndSettle();

    expect(_irDoBloco(container), '/factory-data/cabinets/Markb410_103_1_90-MP.dat',
        reason: 'mesmo microfone e posição, no modelo novo');
    expect(pedaleira.comandosRecebidos.where((c) => c.acao == AcoesAnagram.tocarAoVivo).length, greaterThan(enviosAntes),
        reason: 'a troca de gabinete soa ao vivo');
    expect(container.read(editorProvider).naoSalvo, isTrue);
  });

  testWidgets('should_step_to_the_next_and_previous_model_with_the_arrows', (tester) async {
    final container = await _abrirGabinete(tester, indice: _comEscolhas);

    await _tocar(tester, 'gabinete-proximo');
    expect(_irDoBloco(container), '/factory-data/cabinets/Markb410_103_1_90-MP.dat');
    expect(_modeloNaTela(tester), 'Black & Yellow 4x10');

    await _tocar(tester, 'gabinete-anterior');
    expect(_modeloNaTela(tester), 'Darkglass Neo 2x12');
  });

  testWidgets('should_write_the_ir_of_the_tapped_position_and_mic_chip', (tester) async {
    final container = await _abrirGabinete(tester, indice: _comEscolhas);

    await _tocar(tester, 'posicao-Edge On Axis');
    expect(_irDoBloco(container), '/factory-data/cabinets/212 103 off axis_01-MP.dat');

    await _tocar(tester, 'microfone-Dynamic 112');
    expect(_irDoBloco(container), '/factory-data/cabinets/212 D112 on axis_01-MP.dat');
  });

  testWidgets('should_not_offer_the_cabinet_choice_when_the_build_has_no_suite_table', (tester) async {
    await _abrirGabinete(tester);

    expect(find.byKey(const ValueKey('gabinete-modelo')), findsNothing);
  });
}
