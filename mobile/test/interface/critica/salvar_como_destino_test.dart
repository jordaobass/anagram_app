// "Salvar como": na lista, cada destino diz o que acontece ao tocar nele. O
// slot vazio mostra o ícone de gravar; o ocupado, o de substituir em
// alumínio claro e "substitui <nome>", para ninguém sobrescrever às cegas.
import 'package:anagram_app/aplicacao/estado/controlador_biblioteca.dart';
import 'package:anagram_app/apresentacao/tema/tokens.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../apoio/demonstracao_na_tela.dart';
import '../../apoio/textos_pt.dart';

Finder _naLinha(String slot, Finder alvo) => find.descendant(of: find.byKey(ValueKey('slot-$slot')), matching: alvo);

void main() {
  testWidgets('should_tell_an_empty_destination_from_an_occupied_one_while_saving_as', (tester) async {
    final container = await abrirDemonstracao(tester);
    await tocarNoSlot(tester, '01A');
    await tester.tap(find.byKey(const ValueKey('botao-salvar-como')));
    await tester.pumpAndSettle();
    final ocupado = container.read(bibliotecaProvider).resumo(SlotPreset.doRotulo('01B'))!.nome;

    expect(_naLinha('01B', find.text(textosPt.sbSubstitui(ocupado))), findsOneWidget);
    final substituir = tester.widget<Icon>(_naLinha('01B', find.byIcon(Icons.find_replace)));
    expect(substituir.color, Cores.aluminioClaro);
    await tester.scrollUntilVisible(find.byKey(const ValueKey('slot-04A')), 200,
        scrollable: find.descendant(of: find.byKey(const ValueKey('lista-presets')), matching: find.byType(Scrollable)));
    expect(_naLinha('04A', find.byIcon(Icons.save_alt)), findsOneWidget, reason: 'vazio: gravar aqui');
    expect(_naLinha('04A', find.byIcon(Icons.find_replace)), findsNothing);
  });
}
