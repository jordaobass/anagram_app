// Capturas do painel de parâmetros dos blocos de EQ, filtro e amp, no
// computador: o bloco novo (valores padrão) na casa 4 do 01A, selecionado.
// Prefixo "eq-". Com COM_MINIATURAS=1 saem com a arte, na pasta ignorada pelo git.
import 'dart:async';

import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/capturas_apoio.dart';
import '../apoio/fixtures.dart';

const _celular = Tamanho('celular-retrato', 390, 1800, 2);

/// Alto o bastante para o painel inteiro do paramétrico caber na captura.
const _computadorAlto = Tamanho('desktop', 1440, 1500, 1, plataforma: TargetPlatform.windows);

const _blocos = {
  'geq-darkglass': 'urn:darkglass:DarkglassGEQ',
  'geq-generico': 'urn:darkglass:GenericGEQ',
  'amp-eq': 'urn:darkglass:AmpEq',
  'parametrico': 'urn:darkglass:fil4#mono',
  'hpf-lpf': 'urn:darkglass:HPFLPF',
  'peggy-classic': 'urn:darkglass:neural-plugins:peggycl',
  'swe-tc650': 'urn:darkglass:neural-plugins:swe',
  'swirl-900': 'urn:darkglass:neural-plugins:swirl',
  'neural-amp': 'urn:darkglass:neural:amp',
  'microtubes-x': 'urn:darkglass:neural-plugins:microtubes-x',
};

Future<void> _painelDo(WidgetTester tester, Tamanho tamanho, String uri) async {
  await preparar(tester, tamanho);
  final container = await abrirSlot(tester, '01A');
  final definicao = lerCatalogo().definicao(uri);
  unawaited(container.read(editorProvider.notifier).adicionarBloco(const PosicaoBloco(1, 4), definicao));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(carregarFontes);

  var ordem = 0;
  for (final MapEntry(key: nome, value: uri) in _blocos.entries) {
    final numero = (++ordem).toString().padLeft(2, '0');
    testWidgets('captura eq: painel do $nome no computador', (tester) async {
      await _painelDo(tester, _computadorAlto, uri);
      await capturar(tester, '$pasta/eq-$numero-desktop-$nome.png');
    });
  }

  testWidgets('captura eq: painel do paramétrico no celular', (tester) async {
    await _painelDo(tester, _celular, 'urn:darkglass:fil4#mono');
    await capturar(tester, '$pasta/eq-90-celular-parametrico.png');
  });

  testWidgets('captura tt: balão do Threshold do Compressor/Limiter no computador', (tester) async {
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await _painelDo(tester, desktopWindows, 'urn:darkglass:CompLim');
    await mouse.moveTo(tester.getCenter(find.byKey(const ValueKey('explicacao-Threshold'))));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    await capturar(tester, '$pasta/tt-01-desktop-balao-threshold.png');
  });

  testWidgets('captura eq: painel do GEQ no celular', (tester) async {
    await _painelDo(tester, _celular, 'urn:darkglass:DarkglassGEQ');
    await capturar(tester, '$pasta/eq-91-celular-geq.png');
  });
}
