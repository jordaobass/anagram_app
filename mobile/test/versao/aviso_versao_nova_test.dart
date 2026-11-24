// O caminho inteiro do aviso de versão nova: o app abre, pergunta ao GitHub
// (falso), a engrenagem da barra ganha um ponto (DECISOES BS1), e nas
// Configurações "Baixar" abre a página da release e "Lembrar depois" apaga o
// ponto e guarda a versão dispensada. Lá a pessoa também vê em que pé está e
// pode desligar a consulta.
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

/// Abre as Configurações já rolada até a seção de versão nova.
Future<void> _abrirConfiguracoes(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('botao-configuracoes')));
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(find.byKey(const ValueKey('versao-nova-verificar')), 200,
      scrollable: find.byType(Scrollable).first);
  await tester.pumpAndSettle();
}

bool _pontoNaEngrenagem(WidgetTester tester) =>
    tester.widget<Badge>(find.byKey(const ValueKey('selo-versao-nova'))).isLabelVisible;

void main() {
  setUp(_abertos.clear);

  testWidgets('should_mark_the_gear_open_the_release_page_and_clear_the_mark_when_dismissed', (tester) async {
    final preferencias = PreferenciasVersaoEmMemoria();
    await montarApp(tester, github: GithubFalso(tag: 'v9.9.9'), preferenciasVersao: preferencias, overrides: [_abridorFalso]);

    expect(_pontoNaEngrenagem(tester), isTrue);
    expect(find.byTooltip('Configurações · v9.9.9 disponível'), findsOneWidget);
    expect(find.text('v9.9.9 disponível'), findsNothing, reason: 'a barra não tem mais o aviso por extenso');

    await _abrirConfiguracoes(tester);
    final baixar = find.byKey(const ValueKey('versao-nova-baixar-configuracoes'));
    await tester.ensureVisible(baixar);
    await tester.pumpAndSettle();
    await tester.tap(baixar);
    await tester.pumpAndSettle();
    expect(_abertos, [Uri.parse(GithubFalso.paginaDa('v9.9.9'))]);

    await tester.tap(find.byKey(const ValueKey('versao-nova-dispensar')));
    await tester.pumpAndSettle();
    expect(preferencias.salvo.dispensada, '9.9.9');
    expect(find.byKey(const ValueKey('versao-nova-dispensar')), findsNothing);
    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    expect(_pontoNaEngrenagem(tester), isFalse);
  });

  testWidgets('should_keep_the_gear_mark_on_a_narrow_window', (tester) async {
    await montarApp(tester, tamanho: const Size(480, 800), github: GithubFalso(tag: 'v9.9.9'), overrides: [_abridorFalso]);

    expect(_pontoNaEngrenagem(tester), isTrue);
  });

  testWidgets('should_show_in_settings_the_available_version_even_after_it_was_dismissed', (tester) async {
    final preferencias = PreferenciasVersaoEmMemoria(const ConfiguracaoVersao(dispensada: '9.9.9'));
    await montarApp(tester, github: GithubFalso(tag: 'v9.9.9'), preferenciasVersao: preferencias, overrides: [_abridorFalso]);
    expect(_pontoNaEngrenagem(tester), isFalse, reason: 'dispensada não volta à barra');

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
    expect(find.textContaining('A consulta envia apenas a versão do app (no cabeçalho User-Agent)'), findsOneWidget);

    await tester.tap(interruptor);
    await tester.pumpAndSettle();
    expect(preferencias.salvo.verificarAoAbrir, isFalse);
    expect(find.text('Você está na versão mais recente.'), findsNothing);
    expect(github.pedidos, hasLength(1), reason: 'só a consulta da abertura, antes de desligar');
  });
}
