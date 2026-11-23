// Capturas das Configurações: a tela inteira com todas as seções nos dois
// temas, no computador com o MCP ligado (escutando e porta ocupada), o backup
// dos presets (escuro e claro) e a lista para restaurar, e no celular, onde só
// há idioma e o caminho para o Sobre.
// Gerar/atualizar: flutter test test/capturas --update-goldens
import 'package:anagram_app/aplicacao/conectar_ao_abrir.dart';
import 'package:anagram_app/aplicacao/copias/copia_automatica.dart';
import 'package:anagram_app/aplicacao/tema.dart';
import 'package:anagram_app/nucleo/modelo/copia_preset.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/app_de_teste.dart';
import '../apoio/capturas_apoio.dart';
import '../apoio/demonstracao_na_tela.dart';
import '../apoio/fixtures.dart' show lerIndiceDasCapturas;
import '../apoio/pasta_copias_falsa.dart';

Future<void> _abrirComMcp(WidgetTester tester, Tamanho t, {bool ocupada = false, bool disponivel = true}) async {
  debugDefaultTargetPlatformOverride = t.plataforma;
  await montarApp(tester,
      tamanho: Size(t.largura, t.altura),
      densidade: t.densidade,
      servidorMcp: ServidorMcpFalso(ocupada: ocupada),
      indice: lerIndiceDasCapturas(),
      mcpDisponivel: disponivel);
  await tester.tap(find.byKey(const ValueKey('botao-configuracoes')));
  await tester.pumpAndSettle();
  if (!disponivel) return;
  await tester.tap(find.byKey(const ValueKey('mcp-permitir')));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(carregarFontes);

  for (final (tema, nome) in [(EscolhaTema.escuro, 'cf-01'), (EscolhaTema.claro, 'tc-10')]) {
    testWidgets('captura desktop: configurações inteiras no tema ${tema.name}', (tester) async {
      await _abrirConfiguracoesCompletas(tester, tema);
      await capturar(tester, '$pasta/$nome-desktop-configuracoes-completas.png');
    });
  }

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

  testWidgets('captura desktop: backup dos presets nas configurações', (tester) async {
    await _abrirBackups(tester);
    await capturar(tester, '$pasta/bk-01-desktop-backup.png');
  });

  testWidgets('captura desktop: backup dos presets no tema claro', (tester) async {
    await _abrirBackups(tester, tema: EscolhaTema.claro);
    await capturar(tester, '$pasta/tc-11-desktop-backup.png');
  });

  testWidgets('captura desktop: restaurar de um backup', (tester) async {
    await _abrirBackups(tester);
    await tester.tap(find.byKey(const ValueKey('backup-restaurar')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('backup-completo-completo_143100')));
    await tester.pumpAndSettle();
    await capturar(tester, '$pasta/bk-02-desktop-restaurar.png');
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

/// Configurações conectado à demonstração, rolado até "Backup dos presets",
/// com dois backups automáticos e um completo de 3 presets na pasta.
Future<void> _abrirBackups(WidgetTester tester, {EscolhaTema tema = EscolhaTema.escuro}) async {
  debugDefaultTargetPlatformOverride = TargetPlatform.windows;
  await abrirDemonstracao(tester,
      tamanho: Size(desktopWindows.largura, desktopWindows.altura),
      indice: lerIndiceDasCapturas(),
      tema: tema,
      overrides: [pastaDeCopiasProvider.overrideWithValue(_pastaComBackups())]);
  await tester.tap(find.byKey(const ValueKey('botao-configuracoes')));
  await tester.pumpAndSettle();
  final secao = find.byKey(const ValueKey('backup-automatico'));
  await tester.scrollUntilVisible(secao, 300, scrollable: find.byType(Scrollable).first);
  await Scrollable.ensureVisible(tester.element(secao));
  await tester.pumpAndSettle();
}

/// Configurações no Windows, conectado à demonstração, numa janela alta o
/// bastante para caber tudo: idioma, aparência, pedaleira (com o conectar ao
/// abrir), backup, IA local e o Sobre.
Future<void> _abrirConfiguracoesCompletas(WidgetTester tester, EscolhaTema tema) async {
  debugDefaultTargetPlatformOverride = TargetPlatform.windows;
  await montarApp(tester,
      tamanho: const Size(1440, 3000),
      tema: tema,
      indice: lerIndiceDasCapturas(),
      abertura: PlataformaDeAbertura.computador,
      preferenciasConexao: PreferenciasConexaoEmMemoria(false),
      overrides: [pastaDeCopiasProvider.overrideWithValue(_pastaComBackups())]);
  await entrarNaDemonstracao(tester);
  await tester.tap(find.byKey(const ValueKey('botao-configuracoes')));
  await tester.pumpAndSettle();
}

PastaDeCopiasFalsa _pastaComBackups() {
  CopiaGuardada copia(String rotulo, String? area, String nome, DateTime quando, {String? completa}) => CopiaGuardada(
      caminho: '$caminhoNasCapturas\\${pastaDoDia(quando)}\\$rotulo-$nome-${completa ?? ''}.json',
      quando: quando,
      origem: OrigemDaCopia(slot: SlotPreset.doRotulo(rotulo), area: area, nome: nome),
      completa: completa);
  final hoje = DateTime(2026, 11, 22, 14, 30, 5);
  final completo = DateTime(2026, 11, 22, 14, 31);
  return PastaDeCopiasFalsa(iniciais: [
    copia('01A', 'user', 'My favorite tone', hoje),
    copia('02B', 'user-2', 'Slap devagar', DateTime(2026, 11, 22, 11, 2, 40)),
    for (final (rotulo, area, nome) in [('01A', 'user', 'My favorite tone'), ('01B', 'user', 'FILTER TONE'), ('01A', 'user-3', 'Show sábado')])
      copia(rotulo, area, nome, completo, completa: 'completo_143100'),
    copia('14C', 'user', 'Ensaio banda', DateTime(2026, 11, 20, 20, 15, 12)),
  ]..sort((a, b) => b.quando.compareTo(a.quando)));
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
