// A opção marcada de um parâmetro de escolha não pode parecer desabilitada:
// com cor de família neutra (utilitário, gabinete) o preenchimento cinza era
// igual ao de um botão apagado. Aí a marcada ganha contorno âmbar e um check.
import 'package:anagram_app/apresentacao/componentes/botao_opcao.dart';
import 'package:anagram_app/apresentacao/tema/tokens.dart';
import 'package:anagram_app/nucleo/catalogo/familia_bloco.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../apoio/demonstracao_na_tela.dart';

const _metro = 'https://cognate.audio/plugins/cognate-metro';

Finder _opcao(String simbolo, int indice) =>
    find.descendant(of: find.byKey(ValueKey('opcao-$simbolo-$indice')), matching: find.byType(BotaoOpcao));

/// O contorno que o botão de fato desenha (o Material de dentro dele).
BorderSide _contorno(WidgetTester tester, Finder botao) {
  final material = tester.widget<Material>(find.descendant(of: botao, matching: find.byType(Material)).first);
  return (material.shape! as OutlinedBorder).side;
}

void main() {
  testWidgets('should_mark_the_chosen_compass_with_an_amber_outline_and_a_check_when_the_family_color_is_neutral',
      (tester) async {
    await abrirComBloco(tester, _metro);
    final marcada = _opcao('time_signature', 2);
    final outra = _opcao('time_signature', 0);
    await tester.ensureVisible(marcada);
    await tester.pumpAndSettle();
    expect(tester.widget<BotaoOpcao>(marcada).marcada, isTrue, reason: '4/4 é o padrão do metrônomo');

    expect(_contorno(tester, marcada), const BorderSide(color: Cores.tally, width: Medidas.contornoSelecao));
    expect(find.descendant(of: marcada, matching: find.byIcon(Icons.check)), findsOneWidget);
    expect(find.descendant(of: outra, matching: find.byIcon(Icons.check)), findsNothing);
    expect(_contorno(tester, outra).color, isNot(Cores.tally));
  });

  test('should_put_the_neural_amp_with_the_amplifiers_not_the_utilities', () {
    final familia = FamiliaBloco.de(uri: 'urn:darkglass:neural:amp', nome: 'Neural Amp', categoria: 'Utilities');

    expect(familia, FamiliaBloco.amplificador);
  });
}
