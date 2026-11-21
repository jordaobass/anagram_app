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

String? _textoDo(WidgetTester tester, String chave) =>
    (tester.widget<DropdownButton<String>>(find.byKey(ValueKey(chave)))).value;

Future<void> _escolher(WidgetTester tester, String chave, String opcao) async {
  await tester.tap(find.byKey(ValueKey(chave)));
  await tester.pumpAndSettle();
  await tester.tap(find.text(opcao).last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('should_show_model_mic_and_position_of_the_cabinet_ir_in_the_block_panel', (tester) async {
    await _abrirGabinete(tester, indice: _comEscolhas);

    expect(_textoDo(tester, 'gabinete-modelo'), 'Darkglass Neo 2x12');
    expect(_textoDo(tester, 'gabinete-microfone'), 'Condenser 103');
    expect(_textoDo(tester, 'gabinete-posicao'), 'Cap On Axis');
  });

  testWidgets('should_write_the_new_ir_and_play_it_live_when_another_cabinet_is_chosen', (tester) async {
    final container = await _abrirGabinete(tester, indice: _comEscolhas);
    final pedaleira = container.read(conexaoProvider.notifier).transporte! as TransporteDemonstracao;
    final enviosAntes = pedaleira.comandosRecebidos.where((c) => c.acao == AcoesAnagram.tocarAoVivo).length;

    await _escolher(tester, 'gabinete-modelo', 'Black & Yellow 4x10');

    final bloco = container.read(editorProvider).atual!.bloco(_gabinete)!;
    expect(bloco.arquivoDeIr, '/factory-data/cabinets/Markb410_103_1_90-MP.dat',
        reason: 'mesmo microfone e posição, no modelo novo');
    expect(pedaleira.comandosRecebidos.where((c) => c.acao == AcoesAnagram.tocarAoVivo).length, greaterThan(enviosAntes),
        reason: 'a troca de gabinete soa ao vivo');
    expect(container.read(editorProvider).naoSalvo, isTrue);
  });

  testWidgets('should_not_offer_the_cabinet_choice_when_the_build_has_no_suite_table', (tester) async {
    await _abrirGabinete(tester);

    expect(find.byKey(const ValueKey('gabinete-modelo')), findsNothing);
  });
}
