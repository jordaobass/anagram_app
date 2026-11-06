// Caminho quente inteiro, no modo demonstração e pela interface:
// conectar → abrir preset → girar knob → ver o try_anagram_preset sair com o
// valor que a tela mostra → salvar com confirmação → reler e ver o valor.
import 'package:anagram_app/apresentacao/app_anagram.dart';
import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/nucleo/catalogo/formatador_valor.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/protocolo/api_anagram.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/app_de_teste.dart';
import '../apoio/fixtures.dart';

num? limiarEnviado(Map<String, dynamic>? documento) {
  final parametros = documento?['preset']['chains']['1']['blocks']['1']['parameters'] as Map<String, dynamic>;
  return parametros.values.firstWhere((p) => p['symbol'] == 'Threshold')['value'] as num?;
}

void main() {
  testWidgets('should_play_edit_live_and_save_it_to_the_slot_in_demo_mode', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(appDeTeste());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('botao-demonstracao')));
    await tester.pumpAndSettle();
    final contexto = tester.element(find.byType(AppAnagram));
    final pedaleira = ProviderScope.containerOf(contexto).read(conexaoProvider.notifier).transporte!
        as TransporteDemonstracao;

    final linha01C = find.byKey(const ValueKey('slot-01C'));
    expect(find.descendant(of: linha01C, matching: find.text('Grave Limpo')), findsOneWidget,
        reason: 'a lista mostra o que cada slot guarda');
    await tester.tap(linha01C);
    await tester.pumpAndSettle();
    expect(limiarEnviado(pedaleira.presetTocando), -30, reason: 'abrir o preset já o toca');

    final knob = find.byKey(const ValueKey('param-Threshold'));
    await tester.ensureVisible(knob);
    final enviosAntes = pedaleira.comandosRecebidos.where((c) => c.acao == AcoesAnagram.tocarAoVivo).length;
    await tester.drag(knob, const Offset(0, -80));
    await tester.pumpAndSettle();

    final envios = pedaleira.comandosRecebidos.where((c) => c.acao == AcoesAnagram.tocarAoVivo).length;
    final enviado = limiarEnviado(pedaleira.presetTocando)!;
    final limiar = lerCatalogo().definicao('urn:darkglass:CompLim').parametro('Threshold')!;
    expect(enviado, greaterThan(-30));
    expect(envios - enviosAntes, inInclusiveRange(1, 4), reason: 'arraste com vazão limitada + valor final');
    expect(find.descendant(of: knob, matching: find.text(FormatadorValor.formatar(limiar, enviado))), findsOneWidget);
    expect(find.byKey(const ValueKey('selo-nao-salvo')), findsOneWidget);

    // Salvar grava no slot aberto, sem escolher nem confirmar (é o próprio slot)
    await tester.tap(find.byKey(const ValueKey('botao-salvar')));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(limiarEnviado(pedaleira.conteudoDoSlot(3)), enviado);
    expect(find.byKey(const ValueKey('selo-nao-salvo')), findsNothing);

    // Salvar como: o destino é escolhido na própria lista; slot ocupado e diferente confirma
    await tester.tap(find.byKey(const ValueKey('botao-salvar-como')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('faixa-escolher-destino')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('slot-03C')));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing, reason: 'slot vazio não pede confirmação');
    expect(limiarEnviado(pedaleira.conteudoDoSlot(9)), enviado);
    expect(find.byKey(const ValueKey('faixa-escolher-destino')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('slot-02A')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('slot-01C')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(knob);
    expect(find.descendant(of: knob, matching: find.text(FormatadorValor.formatar(limiar, enviado))), findsOneWidget);
  });
}
