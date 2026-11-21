// No painel do Bass Cabinet a pessoa escolhe o gabinete como na pedaleira:
// três cartões iguais (modelo, microfone e posição) com setas ‹ › e, ao tocar
// no meio, a galeria com busca; o IR escolhido vai para o bloco e soa na hora.
import 'dart:async';

import 'package:anagram_app/aplicacao/arte/indice_miniaturas.dart';
import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:anagram_app/nucleo/protocolo/api_anagram.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

/// O nome que o cartão mostra embaixo da foto/ícone.
String? _nomeNoCartao(WidgetTester tester, String cartao) =>
    tester.widget<Text>(find.byKey(ValueKey('$cartao-nome'))).data;

Future<void> _tocar(WidgetTester tester, String chave) async {
  await tester.ensureVisible(find.byKey(ValueKey(chave)));
  // a rolagem só chega à tela no próximo quadro
  await tester.pump();
  await tester.tap(find.byKey(ValueKey(chave)));
  await tester.pumpAndSettle();
}

int _tocadosAoVivo(ProviderContainer c) => (c.read(conexaoProvider.notifier).transporte! as TransporteDemonstracao)
    .comandosRecebidos
    .where((c) => c.acao == AcoesAnagram.tocarAoVivo)
    .length;

String? _irDoBloco(ProviderContainer c) => c.read(editorProvider).atual!.bloco(_gabinete)!.arquivoDeIr;

void main() {
  testWidgets('should_show_model_mic_and_position_of_the_cabinet_ir_in_three_cards_of_the_same_size', (tester) async {
    await _abrirGabinete(tester, indice: _comEscolhas);

    expect(_nomeNoCartao(tester, 'gabinete'), 'Darkglass Neo 2x12');
    expect(_nomeNoCartao(tester, 'microfone'), 'Condenser 103');
    expect(_nomeNoCartao(tester, 'posicao'), 'Cap On Axis');
    final tamanhos = {for (final c in ['gabinete', 'microfone', 'posicao']) tester.getSize(find.byKey(ValueKey('cartao-$c')))};
    expect(tamanhos, hasLength(1), reason: 'os três cartões ficam do mesmo tamanho');
  });

  testWidgets('should_step_the_model_with_the_arrows_and_play_the_new_ir_live', (tester) async {
    final container = await _abrirGabinete(tester, indice: _comEscolhas);
    final antes = _tocadosAoVivo(container);

    await _tocar(tester, 'gabinete-proximo');
    expect(_irDoBloco(container), '/factory-data/cabinets/Markb410_103_1_90-MP.dat',
        reason: 'mesmo microfone e posição, no modelo novo');
    expect(_nomeNoCartao(tester, 'gabinete'), 'Black & Yellow 4x10');
    expect(_tocadosAoVivo(container), greaterThan(antes), reason: 'a troca de gabinete soa ao vivo');
    expect(container.read(editorProvider).naoSalvo, isTrue);

    await _tocar(tester, 'gabinete-anterior');
    expect(_nomeNoCartao(tester, 'gabinete'), 'Darkglass Neo 2x12');
  });

  testWidgets('should_open_the_gallery_filter_by_text_and_write_the_chosen_model_when_tapping_the_photo', (tester) async {
    final container = await _abrirGabinete(tester, indice: _comEscolhas);

    await _tocar(tester, 'gabinete-abrir');
    expect(find.byKey(const ValueKey('opcao-Darkglass Neo 2x12')), findsOneWidget, reason: 'a galeria mostra todos');
    await tester.enterText(find.byKey(const ValueKey('galeria-busca')), 'yell');
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('opcao-Darkglass Neo 2x12')), findsNothing, reason: 'só os que têm "yell"');
    await _tocar(tester, 'opcao-Black & Yellow 4x10');

    expect(find.byKey(const ValueKey('galeria-busca')), findsNothing, reason: 'escolher fecha a galeria');
    expect(_irDoBloco(container), '/factory-data/cabinets/Markb410_103_1_90-MP.dat');
  });

  testWidgets('should_write_the_ir_of_the_mic_and_position_chosen_in_their_cards', (tester) async {
    final container = await _abrirGabinete(tester, indice: _comEscolhas);

    await _tocar(tester, 'posicao-abrir');
    await _tocar(tester, 'opcao-Edge On Axis');
    expect(_irDoBloco(container), '/factory-data/cabinets/212 103 off axis_01-MP.dat');

    await _tocar(tester, 'microfone-proximo');
    expect(_irDoBloco(container), '/factory-data/cabinets/212 D112 on axis_01-MP.dat');
  });

  testWidgets('should_step_the_model_with_the_keyboard_arrows_when_the_card_has_focus', (tester) async {
    final container = await _abrirGabinete(tester, indice: _comEscolhas);

    await tester.ensureVisible(find.byKey(const ValueKey('cartao-gabinete')));
    Focus.of(tester.element(find.byKey(const ValueKey('gabinete-nome')))).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();

    expect(_irDoBloco(container), '/factory-data/cabinets/Markb410_103_1_90-MP.dat');
  });

  testWidgets('should_show_the_file_name_when_the_ir_is_the_users_own', (tester) async {
    final container = await _abrirGabinete(tester, indice: _comEscolhas);

    unawaited(container.read(editorProvider.notifier).escolherIrDoGabinete(_gabinete, '/user-files/cabinets/meu IR.wav'));
    await tester.pumpAndSettle();

    expect(find.textContaining('meu IR.wav'), findsOneWidget);
    expect(find.byKey(const ValueKey('cartao-gabinete')), findsOneWidget, reason: 'o modelo ainda pode ser escolhido');
  });

  testWidgets('should_not_offer_the_cabinet_choice_when_the_build_has_no_suite_table', (tester) async {
    await _abrirGabinete(tester);

    expect(find.byKey(const ValueKey('cartao-gabinete')), findsNothing);
  });
}
