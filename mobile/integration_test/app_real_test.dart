// Roda o app de verdade na plataforma (ex.: `flutter test integration_test -d macos`):
// assets pelo rootBundle real, canal nativo real. Sem pedaleira plugada, o
// "Conectar" tem de voltar a mensagem do lado nativo; depois o caminho
// quente roda na demonstração.
import 'package:anagram_app/apresentacao/app_anagram.dart';
import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/protocolo/erros_anagram.dart';
import 'package:anagram_app/plataforma/saida_midi_nativa.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('should_run_real_app_report_missing_pedal_and_edit_in_demo', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AppAnagram()));
    await tester.pumpAndSettle();

    final conectar = find.byKey(const ValueKey('botao-conectar'));
    if (tester.widget<ButtonStyleButton>(conectar).enabled) {
      await tester.tap(conectar);
      await tester.pumpAndSettle(const Duration(milliseconds: 100), EnginePhase.sendSemanticsUpdate, const Duration(seconds: 15));
      final aviso = tester.widget<Text>(find.byKey(const ValueKey('aviso-conexao')));
      debugPrint('aviso do canal nativo sem pedaleira: ${aviso.data}');
      expect(aviso.data, isNotEmpty);
    }

    await tester.tap(find.byKey(const ValueKey('botao-demonstracao')));
    await tester.pumpAndSettle();
    // janela pequena = layout compacto: a lista é outra rota
    if (find.byKey(const ValueKey('slot-01C')).evaluate().isEmpty) {
      await tester.tap(find.text('VER PRESETS'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.byKey(const ValueKey('slot-01C')));
    await tester.pumpAndSettle();
    final knob = find.byKey(const ValueKey('param-Threshold'));
    final rolagem = find.descendant(of: find.byKey(const ValueKey('rolagem-editor')), matching: find.byType(Scrollable));
    // janela de 800×600: rola até o fim para o knob inteiro aparecer
    await tester.drag(rolagem.first, const Offset(0, -2000));
    await tester.pumpAndSettle();
    await tester.drag(knob, const Offset(0, -80));
    await tester.pumpAndSettle();

    final contexto = tester.element(find.byType(AppAnagram));
    final pedaleira = ProviderScope.containerOf(contexto).read(conexaoProvider.notifier).transporte!
        as TransporteDemonstracao;
    final bloco = pedaleira.presetTocando!['preset']['chains']['1']['blocks']['1'] as Map<String, dynamic>;
    final limiar = (bloco['parameters'] as Map<String, dynamic>).values.firstWhere((p) => p['symbol'] == 'Threshold');
    debugPrint('try_anagram_preset levou Threshold = ${limiar['value']}');
    expect(limiar['value'] as num, greaterThan(-30));
  });

  testWidgets('should_reach_the_native_midi_channel_and_report_missing_anagram_port', (tester) async {
    Object? erro;
    try {
      await SaidaMidiNativa().abrir();
    } on ErroAnagram catch (e) {
      erro = e;
    }
    debugPrint('MIDI nativo sem pedaleira: $erro');
    expect(erro, isA<ErroDesconectado>(), reason: 'CoreMIDI respondeu (não MissingPlugin)');
  });
}
