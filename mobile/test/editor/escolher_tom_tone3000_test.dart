// Os casos de borda da escolha de tom do TONE3000 no painel do bloco: o
// arquivo do bloco que não está na pedaleira, o tom enviado pela pessoa
// (só consulta), o gabinete TONE3000 (só IR) e o firmware sem `t3k`.
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';
import '../apoio/preset_tone3000.dart';

Future<ProviderContainer> _abrirBloco(WidgetTester tester, Override pedaleira) async {
  final container = await abrirDemonstracao(tester, overrides: [pedaleira]);
  await tocarNoSlot(tester, '01C');
  container.read(editorProvider.notifier).selecionarBloco(posicaoTone3000);
  await tester.pumpAndSettle();
  return container;
}

String? _valorNoBloco(ProviderContainer c) => c.read(editorProvider).atual!.bloco(posicaoTone3000)!.arquivoDeIr;

String? _nomeNoCartao(WidgetTester tester, String cartao) =>
    tester.widget<Text>(find.byKey(ValueKey('$cartao-nome'))).data;

IconButton _seta(WidgetTester tester, String chave) => tester.widget<IconButton>(find.byKey(ValueKey(chave)));

void main() {
  testWidgets('should_show_a_path_missing_from_the_pedal_as_not_found_without_switching_it', (tester) async {
    const sumido = '/factory-data/neural-models-t3k/99999/123.nam';
    final container = await _abrirBloco(tester, pedaleiraComTone3000(valor: sumido));

    expect(find.text('Não encontrado na pedaleira: 123'), findsOneWidget);
    expect(_nomeNoCartao(tester, 'tom'), 'Escolher');
    expect(find.byKey(const ValueKey('cartao-modelo-tom')), findsNothing);
    expect(_valorNoBloco(container), sumido, reason: 'o app não troca sozinho');
    expect(container.read(editorProvider).naoSalvo, isFalse);
  });

  testWidgets('should_show_the_users_own_tone_read_only', (tester) async {
    const doUsuario = '/data/user-files/neural-models-t3k/990001/SVT ensaio DI.nam';
    final container = await _abrirBloco(tester, pedaleiraComTone3000(valor: doUsuario));

    expect(find.byKey(const ValueKey('t3k-so-consulta')), findsOneWidget);
    expect(_nomeNoCartao(tester, 'tom'), 'Meu SVT do ensaio');
    expect(_nomeNoCartao(tester, 'modelo-tom'), 'SVT ensaio DI');
    expect(_seta(tester, 'modelo-tom-proximo').onPressed, isNull, reason: 'sem caminho para gravar (T3K4)');
    expect(_seta(tester, 'tom-proximo').onPressed, isNull, reason: 'é o último e as setas pulam os de consulta');

    await tester.tap(find.byKey(const ValueKey('tom-abrir')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('opcao-Meu SVT do ensaio')));
    await tester.pumpAndSettle();
    expect(_valorNoBloco(container), doUsuario);
    expect(container.read(editorProvider).naoSalvo, isFalse);
  });

  testWidgets('should_offer_only_ir_tones_in_the_tone3000_cabinet_and_write_the_factory_ir_path', (tester) async {
    final container = await _abrirBloco(
        tester, pedaleiraComTone3000(uri: uriGabineteTone3000, valor: '/factory-data/irs-t3k/1612/81565.wav'));

    expect(_nomeNoCartao(tester, 'tom'), 'Mesa OS 4x12 IR');
    expect(find.byKey(const ValueKey('t3k-ir-nao-conferido')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('tom-proximo')));
    await tester.tap(find.byKey(const ValueKey('tom-proximo')));
    await tester.pumpAndSettle();

    expect(_valorNoBloco(container), '/factory-data/irs-t3k/27465/220918.wav');
    final propriedade = container.read(editorProvider).atual!.bloco(posicaoTone3000)!.bruto['properties']['1'];
    expect(propriedade['name'], 'Cabinet File');
  });

  testWidgets('should_leave_the_panel_as_before_when_the_firmware_has_no_tone3000_list', (tester) async {
    await _abrirBloco(tester, pedaleiraComTone3000(ajuste: (p) => p.semTone3000 = true));

    expect(find.byKey(const ValueKey('cartao-tom')), findsNothing);
    expect(find.byKey(const ValueKey('t3k-falhou')), findsNothing, reason: 'sem t3k não é falha: só não há lista');
  });
}
