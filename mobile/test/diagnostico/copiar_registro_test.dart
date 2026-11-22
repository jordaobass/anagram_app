// Nas Configurações a pessoa vê onde fica o registro e copia as linhas mais
// novas para colar numa issue, sem procurar pasta escondida.
import 'package:anagram_app/aplicacao/diagnostico.dart';
import 'package:anagram_app/plataforma/registro_em_arquivo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';

class _RegistroFalso implements RegistroEmArquivo {
  @override
  String get caminho => r'C:\Users\jon\AppData\Local\Anagram App\logs\anagram-app.log';

  @override
  Future<String> ultimasLinhas(int quantas) async => 'firmware v1.19.2.24\nsalvar 01C: ok';
}

void main() {
  testWidgets('should_show_the_log_path_and_copy_the_newest_lines_from_settings', (tester) async {
    await montarApp(tester, overrides: [registroEmArquivoProvider.overrideWithValue(_RegistroFalso())]);
    String? copiado;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (chamada) async {
      if (chamada.method == 'Clipboard.setData') copiado = (chamada.arguments as Map)['text'] as String;
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    await tester.tap(find.byKey(const ValueKey('botao-configuracoes')));
    await tester.pumpAndSettle();

    final copiar = find.byKey(const ValueKey('copiar-registro'));
    await tester.scrollUntilVisible(copiar, 200, scrollable: find.byType(Scrollable).first);
    expect(find.textContaining(r'Anagram App\logs\anagram-app.log'), findsOneWidget);
    // a rolagem pode parar com o botão na borda: traz ele inteiro para a tela
    await tester.ensureVisible(copiar);
    await tester.pumpAndSettle();
    await tester.tap(copiar);
    await tester.pumpAndSettle();

    expect(copiado, 'firmware v1.19.2.24\nsalvar 01C: ok');
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('should_hide_the_log_section_when_the_platform_has_no_log_file', (tester) async {
    await montarApp(tester);
    await tester.tap(find.byKey(const ValueKey('botao-configuracoes')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('copiar-registro')), findsNothing);
  });
}
