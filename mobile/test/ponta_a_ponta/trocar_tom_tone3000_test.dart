// Caminho quente da troca de tom do TONE3000, na demonstração e pela tela:
// abrir o preset com o bloco → ver o tom e o modelo carregados → escolher
// outro tom na galeria e outro modelo pelas setas → a pedaleira toca o
// caminho novo em properties["1"].value → salvar e ver o caminho no slot.
import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/protocolo/api_anagram.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';
import '../apoio/preset_tone3000.dart';

Future<void> _tocar(WidgetTester tester, String chave) async {
  await tester.ensureVisible(find.byKey(ValueKey(chave)));
  await tester.pump();
  await tester.tap(find.byKey(ValueKey(chave)));
  await tester.pumpAndSettle();
}

String? _nomeNoCartao(WidgetTester tester, String cartao) =>
    tester.widget<Text>(find.byKey(ValueKey('$cartao-nome'))).data;

void main() {
  testWidgets('should_switch_the_tone3000_tone_and_model_play_the_new_path_live_and_save_it', (tester) async {
    final container = await abrirDemonstracao(tester, overrides: [pedaleiraComTone3000()]);
    final pedaleira = container.read(conexaoProvider.notifier).transporte! as TransporteDemonstracao;
    await tocarNoSlot(tester, '01C');
    container.read(editorProvider.notifier).selecionarBloco(posicaoTone3000);
    await tester.pumpAndSettle();

    expect(_nomeNoCartao(tester, 'tom'), 'Ampeg SVT Classic with 6x10');
    expect(_nomeNoCartao(tester, 'modelo-tom'), 'Ampeg SVT - Gain 10 Ultra Lo and Hi MD 421');

    await _tocar(tester, 'tom-abrir');
    expect(find.byKey(const ValueKey('opcao-Mesa OS 4x12 IR')), findsNothing, reason: 'IR não vai no NAM Loader');
    expect(find.byKey(const ValueKey('detalhe-Meu SVT do ensaio')), findsOneWidget,
        reason: 'o tom da pessoa aparece na lista, com autor e licença');
    await tester.enterText(find.byKey(const ValueKey('galeria-busca')), 'svt-cl');
    await tester.pumpAndSettle();
    await _tocar(tester, 'opcao-AMPEG SVT-CL BASS HEAD');
    expect(propriedadeDoTone3000(pedaleira.presetTocando)?['value'], '/factory-data/neural-models-t3k/45809/382800.nam',
        reason: 'tom novo começa no primeiro modelo e toca na hora');

    await _tocar(tester, 'modelo-tom-proximo');
    const escolhido = '/factory-data/neural-models-t3k/45809/382799.nam';
    expect(propriedadeDoTone3000(pedaleira.presetTocando),
        {'name': 'Neural Model', 'uri': '$uriTone3000#model', 'value': escolhido},
        reason: 'nome e uri da property ficam como estavam');
    expect(_nomeNoCartao(tester, 'modelo-tom'), 'SVT DIRTY');
    expect(container.read(editorProvider).naoSalvo, isTrue);

    await voltarAoTopoDoEditor(tester);
    await tester.tap(find.byKey(const ValueKey('botao-salvar')));
    await tester.pumpAndSettle();
    expect(propriedadeDoTone3000(pedaleira.conteudoDoSlot(slotComTone3000))?['value'], escolhido);
    expect(pedaleira.comandosRecebidos.where((c) => c.acao == AcoesAnagram.tonsDeFabrica), hasLength(1),
        reason: 'a lista é lida uma vez por conexão');
  });
}
