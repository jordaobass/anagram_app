// Capturas do painel dos blocos de 3 bandas (Ignissor e Entropia): o bloco
// novo na casa 4 do 01A, no computador e no celular, e o Ignissor com uma
// banda mutada e cortes mexidos. Prefixo "mb-". Com COM_MINIATURAS=1 saem com
// a arte, na pasta ignorada pelo git.
import 'dart:async';

import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/capturas_apoio.dart';
import '../apoio/fixtures.dart';

const _computadorAlto = Tamanho('desktop', 1440, 1500, 1, plataforma: TargetPlatform.windows);
const _celular = Tamanho('celular-retrato', 390, 1800, 2);

const _ignissor = 'urn:darkglass:ignissor';
const _entropia = 'urn:darkglass:entropia';

Future<ProviderContainer> _painelDo(WidgetTester tester, Tamanho tamanho, String uri) async {
  await preparar(tester, tamanho);
  final container = await abrirSlot(tester, '01A');
  unawaited(container.read(editorProvider.notifier).adicionarBloco(const PosicaoBloco(1, 4), lerCatalogo().definicao(uri)));
  await tester.pumpAndSettle();
  return container;
}

void main() {
  setUpAll(carregarFontes);

  testWidgets('captura mb: Ignissor no computador', (tester) async {
    await _painelDo(tester, _computadorAlto, _ignissor);
    await capturar(tester, '$pasta/mb-01-desktop-ignissor.png');
  });

  testWidgets('captura mb: Entropia no computador', (tester) async {
    await _painelDo(tester, _computadorAlto, _entropia);
    await capturar(tester, '$pasta/mb-02-desktop-entropia.png');
  });

  testWidgets('captura mb: Ignissor com agudos mutados e cortes mexidos', (tester) async {
    final c = await _painelDo(tester, _computadorAlto, _ignissor);
    c.read(editorProvider.notifier)
      ..alterarParametro('lomid_xo_freq', 120, arrastando: false)
      ..alterarParametro('midhi_xo_freq', 2500, arrastando: false)
      ..alterarParametro('hi_mute', 1, arrastando: false)
      ..alterarParametro('mid_comp_enabled', 0, arrastando: false);
    await tester.pumpAndSettle();
    await capturar(tester, '$pasta/mb-03-desktop-ignissor-mutado.png');
  });

  testWidgets('captura pp: lista de templates do Ignissor', (tester) async {
    await _painelDo(tester, _computadorAlto, _ignissor);
    await tester.tap(find.byKey(const ValueKey('abrir-templates')));
    await tester.pumpAndSettle();
    await capturar(tester, '$pasta/pp-01-desktop-templates-ignissor.png');
  });

  testWidgets('captura pp: Ignissor com o template Grave travado e o médio em solo', (tester) async {
    final c = await _painelDo(tester, _computadorAlto, _ignissor);
    final templates = lerTemplates().de(_ignissor);
    final grave = templates.firstWhere((t) => t.id == 'app-grave-travado');
    // o envio ao vivo da demonstração anda com o relógio do teste: sem await
    unawaited(c.read(editorProvider.notifier).alterarParametros(const PosicaoBloco(1, 4), {...grave.valores!, 'lo_mute': 1, 'hi_mute': 1}));
    await tester.pumpAndSettle();
    await capturar(tester, '$pasta/pp-02-desktop-ignissor-grave-travado.png');
  });

  testWidgets('captura pp: templates do Entropia no celular', (tester) async {
    await _painelDo(tester, _celular, _entropia);
    await tester.tap(find.byKey(const ValueKey('abrir-templates')));
    await tester.pumpAndSettle();
    await capturar(tester, '$pasta/pp-90-celular-templates-entropia.png');
  });

  testWidgets('captura mb: Ignissor no celular', (tester) async {
    await _painelDo(tester, _celular, _ignissor);
    await capturar(tester, '$pasta/mb-90-celular-ignissor.png');
  });

  testWidgets('captura mb: Entropia no celular, banda do meio', (tester) async {
    await _painelDo(tester, _celular, _entropia);
    await tester.tap(find.text('MÉDIOS'));
    await tester.pumpAndSettle();
    await capturar(tester, '$pasta/mb-91-celular-entropia-medios.png');
  });
}
