// A opção marcada de um parâmetro de escolha não pode parecer desabilitada:
// com cor de família neutra (utilitário, gabinete) o preenchimento cinza era
// igual ao de um botão apagado. Aí a marcada da lista ganha contorno âmbar e
// um check; as vizinhas ficam só no texto.
import 'package:anagram_app/apresentacao/componentes/botao_opcao.dart';
import 'package:anagram_app/apresentacao/tema/tokens.dart';
import 'package:anagram_app/nucleo/catalogo/familia_bloco.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../apoio/contraste.dart';
import '../../apoio/demonstracao_na_tela.dart';

const _metro = 'https://cognate.audio/plugins/cognate-metro';

void main() {
  testWidgets('should_mark_the_chosen_sound_with_an_amber_outline_and_a_check_when_the_family_color_is_neutral',
      (tester) async {
    await abrirComBloco(tester, _metro);
    final marcada = find.byKey(const ValueKey('abrir-sound'));
    final vizinha = find.byKey(const ValueKey('vizinha-sound-1'));
    await tester.ensureVisible(marcada);
    await tester.pumpAndSettle();
    expect(tester.widget<BotaoOpcao>(marcada).marcada, isTrue, reason: 'Click é o padrão do metrônomo');

    expect(contornoDoBotao(tester, marcada), const BorderSide(color: Cores.tally, width: Medidas.contornoSelecao));
    expect(find.descendant(of: marcada, matching: find.byIcon(Icons.check)), findsOneWidget);
    expect(find.descendant(of: vizinha, matching: find.byIcon(Icons.check)), findsNothing);
  });

  test('should_put_the_neural_amp_with_the_amplifiers_not_the_utilities', () {
    final familia = FamiliaBloco.de(uri: 'urn:darkglass:neural:amp', nome: 'Neural Amp', categoria: 'Utilities');

    expect(familia, FamiliaBloco.amplificador);
  });
}
