// Capturas das Configurações: no computador com o MCP ligado (escutando e
// porta ocupada) e no celular, onde só há idioma e o caminho para o Sobre.
// Gerar/atualizar: flutter test test/capturas --update-goldens
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/app_de_teste.dart';
import '../apoio/capturas_apoio.dart';
import '../apoio/demonstracao_na_tela.dart';

Future<void> _abrirComMcp(WidgetTester tester, Tamanho t, {bool ocupada = false, bool disponivel = true}) async {
  debugDefaultTargetPlatformOverride = t.plataforma;
  await montarApp(tester,
      tamanho: Size(t.largura, t.altura),
      densidade: t.densidade,
      servidorMcp: ServidorMcpFalso(ocupada: ocupada),
      mcpDisponivel: disponivel);
  await tester.tap(find.byKey(const ValueKey('botao-configuracoes')));
  await tester.pumpAndSettle();
  if (!disponivel) return;
  await tester.tap(find.byKey(const ValueKey('mcp-permitir')));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(carregarFontes);

  testWidgets('captura desktop: configurações com a IA local escutando', (tester) async {
    await _abrirComMcp(tester, desktopWindows);
    await capturar(tester, '$pasta/mcp-01-desktop-configuracoes.png');
  });

  testWidgets('captura desktop: configurações com a porta do MCP ocupada', (tester) async {
    await _abrirComMcp(tester, desktopWindows, ocupada: true);
    await capturar(tester, '$pasta/mcp-02-desktop-porta-ocupada.png');
  });

  testWidgets('captura celular: configurações sem MCP', (tester) async {
    await _abrirComMcp(tester, const Tamanho('celular-retrato', 390, 844, 2), disponivel: false);
    await capturar(tester, '$pasta/mcp-03-celular-configuracoes.png');
  });

  testWidgets('captura desktop: ajustes globais da pedaleira (saídas)', (tester) async {
    await _abrirPedaleira(tester, desktopWindows);
    await capturar(tester, '$pasta/pd-01-desktop-saidas.png');
  });

  for (final (modo, numero) in [('gain', '02'), ('freq', '03'), ('width', '04')]) {
    testWidgets('captura desktop: Global EQ no modo $modo', (tester) async {
      await _abrirPedaleira(tester, desktopWindows);
      await _modoEq(tester, modo);
      await capturar(tester, '$pasta/pd-$numero-desktop-global-eq-$modo.png');
    });
  }

  for (final (modo, numero) in [('gain', '90'), ('freq', '91'), ('width', '92')]) {
    testWidgets('captura celular: Global EQ no modo $modo', (tester) async {
      await _abrirPedaleira(tester, const Tamanho('celular-retrato', 390, 844, 2));
      await _modoEq(tester, modo);
      await capturar(tester, '$pasta/pd-$numero-celular-global-eq-$modo.png');
    });
  }
}

/// Rola até o Global EQ e escolhe o modo (o cartão inteiro na tela).
Future<void> _modoEq(WidgetTester tester, String modo) async {
  await tester.ensureVisible(find.byKey(ValueKey('modo-eq-$modo')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(ValueKey('modo-eq-$modo')));
  await tester.pumpAndSettle();
  // o cartão no topo da tela: seletor, curva e as 6 bandas juntos
  await Scrollable.ensureVisible(tester.element(find.byKey(const ValueKey('cartao-global-eq'))));
  await tester.pumpAndSettle();
}

/// Configurações conectado à demonstração: a seção "Pedaleira" aparece.
Future<void> _abrirPedaleira(WidgetTester tester, Tamanho t) async {
  debugDefaultTargetPlatformOverride = t.plataforma;
  await abrirDemonstracao(tester, tamanho: Size(t.largura, t.altura), densidade: t.densidade);
  await tester.tap(find.byKey(const ValueKey('botao-configuracoes')));
  await tester.pumpAndSettle();
}
