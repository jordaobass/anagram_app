// Preparo comum dos testes de interface: tela do tamanho pedido, app montado
// e, quando preciso, já conectado à pedaleira de demonstração.
import 'dart:async';

import 'package:anagram_app/aplicacao/arte/indice_miniaturas.dart';
import 'package:anagram_app/aplicacao/idioma.dart';
import 'package:anagram_app/aplicacao/tema.dart';
import 'package:anagram_app/nucleo/modelo/presets_fabrica.dart';
import 'package:anagram_app/plataforma/servidor_mcp.dart';
import 'package:anagram_app/dados/preferencias_pausa.dart';
import 'package:anagram_app/dados/preferencias_versao.dart';
import 'package:anagram_app/dados/preferencias_paineis.dart';
import 'package:anagram_app/dados/preferencias_cenas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';

import 'package:anagram_app/aplicacao/conectar_ao_abrir.dart';
import 'package:anagram_app/dados/preferencias_conexao.dart';
import 'package:anagram_app/plataforma/acesso_entrada_mac.dart';

import 'app_de_teste.dart';
import 'fixtures.dart';
import 'versao_falsa.dart';

/// Tamanho lógico de um notebook comum, o padrão dos testes de interface.
const telaDesktop = Size(1440, 900);

/// Tamanho lógico de um celular em retrato (densidade 2).
const telaCelular = Size(390, 844);

/// Ajusta a tela ao tamanho lógico pedido e monta o app, ainda desconectado.
Future<void> montarApp(WidgetTester tester,
    {Size tamanho = telaDesktop,
    double densidade = 1,
    List<Override> overrides = const [],
    IdiomaApp? idioma = IdiomaApp.portugues,
    EscolhaTema? tema = EscolhaTema.escuro,
    IndiceMiniaturas? indice,
    PresetsDeFabrica? fabrica,
    ServidorMcp? servidorMcp,
    bool mcpDisponivel = true,
    GithubFalso? github,
    PreferenciasVersao? preferenciasVersao,
    PreferenciasPausa? preferenciasPausa,
    PreferenciasPaineis? preferenciasPaineis,
    PreferenciasCenas? preferenciasCenas,
    PlataformaDeAbertura abertura = PlataformaDeAbertura.semTentativa,
    PreferenciasConexao? preferenciasConexao,
    ConsultaAcessoEntrada? acessoEntradaMac}) async {
  tester.view.physicalSize = tamanho * densidade;
  tester.view.devicePixelRatio = densidade;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(appDeTeste(
      overrides: overrides,
      idioma: idioma,
      tema: tema,
      indice: indice,
      fabrica: fabrica,
      servidorMcp: servidorMcp,
      mcpDisponivel: mcpDisponivel,
      github: github,
      preferenciasVersao: preferenciasVersao,
      preferenciasPausa: preferenciasPausa,
      preferenciasPaineis: preferenciasPaineis,
      preferenciasCenas: preferenciasCenas,
      abertura: abertura,
      preferenciasConexao: preferenciasConexao,
      acessoEntradaMac: acessoEntradaMac));
  await tester.pumpAndSettle();
}

/// Monta o app e entra no modo demonstração; devolve o container dos provedores.
Future<ProviderContainer> abrirDemonstracao(WidgetTester tester,
    {Size tamanho = telaDesktop,
    double densidade = 1,
    List<Override> overrides = const [],
    IndiceMiniaturas? indice,
    PresetsDeFabrica? fabrica,
    EscolhaTema tema = EscolhaTema.escuro}) async {
  await montarApp(tester,
      tamanho: tamanho, densidade: densidade, overrides: overrides, indice: indice, fabrica: fabrica, tema: tema);
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

/// Rola o editor de volta ao topo (fita do preset e Salvar): depois de
/// rolar até um knob, a fita sai da lista, que só monta o que está à vista.
Future<void> voltarAoTopoDoEditor(WidgetTester tester) async {
  _rolagemDoEditor(tester).jumpTo(0);
  await tester.pumpAndSettle();
}

/// Rola o editor para baixo até [alvo] estar montado (o painel dos controles
/// da pedaleira fica no fim, fora da tela).
Future<void> rolarEditorAte(WidgetTester tester, Finder alvo) async {
  final posicao = _rolagemDoEditor(tester);
  while (alvo.evaluate().isEmpty && posicao.pixels < posicao.maxScrollExtent) {
    posicao.jumpTo((posicao.pixels + posicao.viewportDimension / 2).clamp(0, posicao.maxScrollExtent));
    await tester.pumpAndSettle();
  }
  await tester.ensureVisible(alvo);
  await tester.pumpAndSettle();
}

ScrollPosition _rolagemDoEditor(WidgetTester tester) => tester
    .state<ScrollableState>(
        find.descendant(of: find.byKey(const ValueKey('rolagem-editor')), matching: find.byType(Scrollable)).first)
    .position;

/// Toca na linha do slot (ex. '02A') na lista de presets.
Future<void> tocarNoSlot(WidgetTester tester, String rotulo) async {
  await tester.tap(find.byKey(ValueKey('slot-$rotulo')));
  await tester.pumpAndSettle();
}

/// Demonstração com o 01A aberto e o bloco [uri] posto em [casa]: o painel
/// dele fica na tela, selecionado.
Future<ProviderContainer> abrirComBloco(WidgetTester tester, String uri,
    {Size tamanho = const Size(1440, 2000), PosicaoBloco casa = const PosicaoBloco(1, 4), String slot = '01A'}) async {
  final container = await abrirDemonstracao(tester, tamanho: tamanho);
  unawaited(container.read(editorProvider.notifier).abrirSlot(SlotPreset.doRotulo(slot)));
  await tester.pumpAndSettle();
  unawaited(container.read(editorProvider.notifier).adicionarBloco(casa, lerCatalogo().definicao(uri)));
  await tester.pumpAndSettle();
  return container;
}

/// Abre "Controles da pedaleira" se estiver recolhido (preset sem controle
/// atribuído começa recolhido) e rola até ele.
Future<void> abrirControlesDaPedaleira(WidgetTester tester) async {
  final cabecalho = find.byKey(const ValueKey('cabecalho-controles'));
  await rolarEditorAte(tester, cabecalho);
  if (find.byKey(const ValueKey('controle-foot1')).evaluate().isNotEmpty) return;
  await tester.tap(cabecalho);
  await tester.pumpAndSettle();
}
