// Capturas da barra de cima reorganizada (DECISOES BS1), com a pedaleira no
// cabo: chip "Anagram · fw", latência, "IA" com o MCP escutando e o ponto de
// versão nova na engrenagem. Prefixo "bs-". Gerar/atualizar:
// flutter test test/capturas --update-goldens
import 'dart:async';

import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/aplicacao/mcp/controlador_mcp.dart';
import 'package:anagram_app/aplicacao/tema.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/app_de_teste.dart' show latenciaNasCapturas;
import '../apoio/capturas_apoio.dart';
import '../apoio/demonstracao_na_tela.dart';
import '../apoio/fixtures.dart';
import '../apoio/pedaleira_no_cabo.dart';
import '../apoio/versao_falsa.dart';

/// Pedaleira no cabo, 02A editado, MCP escutando e versão nova publicada.
Future<void> _conectadoComTudo(WidgetTester tester, EscolhaTema tema, {Duration latencia = latenciaNasCapturas}) async {
  debugDefaultTargetPlatformOverride = TargetPlatform.windows;
  await montarApp(tester,
      overrides: [pedaleiraNoCabo],
      tema: tema,
      indice: lerIndiceDasCapturas(),
      github: GithubFalso(tag: 'v0.2.1'),
      latencia: latencia);
  await conectarPeloCabo(tester);
  final container = containerDaTela(tester);
  unawaited(container.read(editorProvider.notifier).abrirSlot(SlotPreset.doRotulo('02A')));
  await tester.pumpAndSettle();
  unawaited(container.read(editorProvider.notifier).escolherCena(2));
  container.read(editorProvider.notifier).alterarParametro('Threshold', -52, arrastando: false);
  await container.read(controladorMcpProvider.notifier).ativar(true);
  await tester.pumpAndSettle();
  await assentarImagens(tester);
}

void main() {
  setUpAll(carregarFontes);

  testWidgets('captura bs: conectado, escuro', (tester) async {
    await _conectadoComTudo(tester, EscolhaTema.escuro);
    await capturar(tester, '$pasta/bs-01-desktop-conectado-escuro.png');
  });

  testWidgets('captura bs: conectado, claro, latência lenta', (tester) async {
    await _conectadoComTudo(tester, EscolhaTema.claro, latencia: const Duration(milliseconds: 720));
    await capturar(tester, '$pasta/bs-02-desktop-conectado-claro-lento.png');
  });

  testWidgets('captura bs: menu do chip da conexão', (tester) async {
    await _conectadoComTudo(tester, EscolhaTema.escuro);
    await tester.tap(find.byKey(const ValueKey('chip-conexao')));
    await tester.pumpAndSettle();
    await capturar(tester, '$pasta/bs-03-desktop-menu-conexao.png');
  });
}
