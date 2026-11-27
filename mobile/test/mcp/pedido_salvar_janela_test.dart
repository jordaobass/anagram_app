// Pedido de gravação da IA (DECISOES IA8): além do diálogo, o app pede ao
// sistema para trazer a janela para a frente, porque quem conversa com a IA
// está noutra janela e o diálogo vencia escondido.
import 'dart:async';

import 'package:anagram_app/aplicacao/mcp/avisos_mcp.dart';
import 'package:anagram_app/apresentacao/componentes/ouvinte_mcp.dart';
import 'package:anagram_app/plataforma/janela_do_app.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';

const _canal = MethodChannel('anagram/janela_teste');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final mensageiro = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() => mensageiro.setMockMethodCallHandler(_canal, null));

  testWidgets('should_bring_the_window_forward_when_the_ai_asks_to_save', (tester) async {
    final chamadas = <String>[];
    mensageiro.setMockMethodCallHandler(_canal, (chamada) async {
      chamadas.add(chamada.method);
      return null;
    });
    final c = await abrirDemonstracao(
      tester,
      overrides: [janelaDoAppProvider.overrideWithValue(const JanelaDoApp(canal: _canal))],
    );

    expect(chamadas, isEmpty, reason: 'só quando a IA pede');
    unawaited(c.read(pedidoSalvarProvider.notifier).pedir('Sujo de Ensaio', '02A', const Duration(minutes: 1)));
    await tester.pumpAndSettle();

    expect(chamadas, ['pedirAtencao']);
    expect(find.byKey(const ValueKey('dialogo-pedido-salvar')), findsOneWidget);
    await _responderAgoraNao(tester);
  });

  testWidgets('should_still_show_the_dialog_when_the_system_refuses_to_bring_the_window_forward', (tester) async {
    mensageiro.setMockMethodCallHandler(_canal, (_) async => throw PlatformException(code: 'nao'));
    final c = await abrirDemonstracao(
      tester,
      overrides: [janelaDoAppProvider.overrideWithValue(const JanelaDoApp(canal: _canal))],
    );

    unawaited(c.read(pedidoSalvarProvider.notifier).pedir('Sujo de Ensaio', '02A', const Duration(minutes: 1)));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('dialogo-pedido-salvar')), findsOneWidget);
    await _responderAgoraNao(tester);
  });
}

/// Fecha o diálogo sem gravar: o pedido termina e o prazo dele não fica pendente.
Future<void> _responderAgoraNao(WidgetTester tester) async {
  await tester.tap(find.text('AGORA NÃO'));
  await tester.pumpAndSettle();
}
