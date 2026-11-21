// O caminho inteiro do aviso de versão nova: o app abre, pergunta ao GitHub
// (falso), a barra de cima anuncia a versão, "Baixar" abre a página da
// release e "Lembrar depois" some com o aviso e guarda a versão dispensada.
// Nas Configurações, a pessoa vê em que pé está e pode desligar a consulta.
import 'package:anagram_app/aplicacao/versao_nova.dart';
import 'package:anagram_app/dados/preferencias_versao.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';
import '../apoio/versao_falsa.dart';

final _abertos = <Uri>[];

final _abridorFalso = abridorDeLinkProvider.overrideWithValue((endereco) async {
  _abertos.add(endereco);
  return true;
});

Future<void> _abrirConfiguracoes(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('botao-configuracoes')));
  await tester.pumpAndSettle();
}

void main() {
  setUp(_abertos.clear);

  testWidgets('should_announce_in_the_top_bar_open_the_release_page_and_hide_when_dismissed', (tester) async {
    final preferencias = PreferenciasVersaoEmMemoria();
    await montarApp(tester, github: GithubFalso(tag: 'v9.9.9'), preferenciasVersao: preferencias, overrides: [_abridorFalso]);

    expect(find.text('v9.9.9 disponível'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('versao-nova-baixar')));
    await tester.pumpAndSettle();
    expect(_abertos, [Uri.parse(GithubFalso.paginaDa('v9.9.9'))]);

    await tester.tap(find.byKey(const ValueKey('versao-nova-dispensar')));
    await tester.pumpAndSettle();
    expect(find.text('v9.9.9 disponível'), findsNothing);
    expect(preferencias.salvo.dispensada, '9.9.9');
  });

  testWidgets('should_offer_download_and_remind_later_from_a_menu_on_a_narrow_window', (tester) async {
    final preferencias = PreferenciasVersaoEmMemoria();
    await montarApp(tester,
        tamanho: const Size(480, 800),
        github: GithubFalso(tag: 'v9.9.9'),
        preferenciasVersao: preferencias,
        overrides: [_abridorFalso]);

    await tester.tap(find.byKey(const ValueKey('versao-nova-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('BAIXAR'));
    await tester.pumpAndSettle();
    expect(_abertos, hasLength(1));

    await tester.tap(find.byKey(const ValueKey('versao-nova-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lembrar depois'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('versao-nova-menu')), findsNothing);
    expect(preferencias.salvo.dispensada, '9.9.9');
  });

  testWidgets('should_show_in_settings_the_available_version_even_after_it_was_dismissed', (tester) async {
    final preferencias = PreferenciasVersaoEmMemoria(const ConfiguracaoVersao(dispensada: '9.9.9'));
    await montarApp(tester, github: GithubFalso(tag: 'v9.9.9'), preferenciasVersao: preferencias, overrides: [_abridorFalso]);
    expect(find.text('v9.9.9 disponível'), findsNothing, reason: 'dispensada não volta à barra');

    await _abrirConfiguracoes(tester);
    expect(find.text('Versão 9.9.9 disponível.'), findsOneWidget);
    final baixar = find.byKey(const ValueKey('versao-nova-baixar-configuracoes'));
    await tester.ensureVisible(baixar);
    await tester.pumpAndSettle();
    await tester.tap(baixar);
    await tester.pumpAndSettle();

    expect(_abertos, [Uri.parse(GithubFalso.paginaDa('v9.9.9'))]);
  });

  testWidgets('should_say_it_is_up_to_date_and_stop_asking_github_when_turned_off', (tester) async {
    final github = GithubFalso(tag: 'v0.1.3');
    final preferencias = PreferenciasVersaoEmMemoria();
    await montarApp(tester, github: github, preferenciasVersao: preferencias);
    await _abrirConfiguracoes(tester);

    final interruptor = find.byKey(const ValueKey('versao-nova-verificar'));
    await tester.ensureVisible(interruptor);
    expect(find.text('Você está na versão mais recente.'), findsOneWidget);
    expect(find.textContaining('Nenhum dado seu é enviado'), findsOneWidget);

    await tester.tap(interruptor);
    await tester.pumpAndSettle();
    expect(preferencias.salvo.verificarAoAbrir, isFalse);
    expect(find.text('Você está na versão mais recente.'), findsNothing);
    expect(github.pedidos, hasLength(1), reason: 'só a consulta da abertura, antes de desligar');
  });
}
