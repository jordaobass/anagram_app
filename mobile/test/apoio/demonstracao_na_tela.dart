// Preparo comum dos testes de interface: tela do tamanho pedido, app montado
// e, quando preciso, já conectado à pedaleira de demonstração.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'app_de_teste.dart';

/// Tamanho lógico de um notebook comum, o padrão dos testes de interface.
const telaDesktop = Size(1440, 900);

/// Tamanho lógico de um celular em retrato (densidade 2).
const telaCelular = Size(390, 844);

/// Ajusta a tela ao tamanho lógico pedido e monta o app, ainda desconectado.
Future<void> montarApp(WidgetTester tester,
    {Size tamanho = telaDesktop, double densidade = 1, List<Override> overrides = const []}) async {
  tester.view.physicalSize = tamanho * densidade;
  tester.view.devicePixelRatio = densidade;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(appDeTeste(overrides: overrides));
  await tester.pumpAndSettle();
}

/// Monta o app e entra no modo demonstração; devolve o container dos provedores.
Future<ProviderContainer> abrirDemonstracao(WidgetTester tester,
    {Size tamanho = telaDesktop, double densidade = 1, List<Override> overrides = const []}) async {
  await montarApp(tester, tamanho: tamanho, densidade: densidade, overrides: overrides);
  return entrarNaDemonstracao(tester);
}

/// Toca em "Abrir demonstração" num app já montado.
Future<ProviderContainer> entrarNaDemonstracao(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('botao-demonstracao')));
  await tester.pumpAndSettle();
  return containerDaTela(tester);
}

/// Container dos provedores da árvore que está na tela.
ProviderContainer containerDaTela(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));

/// Toca na linha do slot (ex. '02A') na lista de presets.
Future<void> tocarNoSlot(WidgetTester tester, String rotulo) async {
  await tester.tap(find.byKey(ValueKey('slot-$rotulo')));
  await tester.pumpAndSettle();
}
