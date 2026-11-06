// Apoio às capturas: tamanhos, fontes reais, imagens assentadas e atalhos.
import 'dart:async';
import 'dart:io';

import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'demonstracao_na_tela.dart';
import 'fixtures.dart';

/// Com miniaturas de terceiros, as capturas vão para uma pasta ignorada pelo git.
final pasta = comMiniaturas ? 'goldens_terceiros' : 'goldens';

class Tamanho {
  const Tamanho(this.nome, this.largura, this.altura, this.densidade);
  final String nome;
  final double largura;
  final double altura;
  final double densidade;
}

const tamanhos = [
  Tamanho('tablet-paisagem', 1366, 1024, 1),
  Tamanho('celular-retrato', 390, 844, 2),
  Tamanho('desktop', 1440, 900, 1),
];

Future<void> carregarFontes() async {
  final familias = {
    'Barlow': ['Barlow-Regular', 'Barlow-Medium', 'Barlow-SemiBold'],
    'BarlowCondensed': ['BarlowCondensed-SemiBold', 'BarlowCondensed-Bold'],
    'SairaStencil': ['SairaStencilOne-Regular'],
    'PermanentMarker': ['PermanentMarker-Regular'],
  };
  for (final MapEntry(key: familia, value: arquivos) in familias.entries) {
    final carregador = FontLoader(familia);
    for (final a in arquivos) {
      carregador.addFont(Future.value(ByteData.sublistView(File('assets/fontes/$a.ttf').readAsBytesSync())));
    }
    await carregador.load();
  }
  final icones = File('${Platform.environment['FLUTTER_ROOT']}/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  await (FontLoader('MaterialIcons')..addFont(Future.value(ByteData.sublistView(icones.readAsBytesSync())))).load();
}

Future<void> assentarImagens(WidgetTester tester) async {
  await tester.runAsync(() async {
    for (final elemento in find.byType(Image).evaluate()) {
      final imagem = elemento.widget as Image;
      await precacheImage(imagem.image, elemento);
    }
  });
  await tester.pumpAndSettle();
}

Future<void> preparar(WidgetTester tester, Tamanho t, {List<Override> overrides = const []}) =>
    montarApp(tester, tamanho: Size(t.largura, t.altura), densidade: t.densidade, overrides: overrides);

Future<ProviderContainer> abrirSlot(WidgetTester tester, String rotulo) async {
  final container = await entrarNaDemonstracao(tester);
  // sem await: o relógio é falso e só anda no pump
  unawaited(container.read(editorProvider.notifier).abrirSlot(SlotPreset.doRotulo(rotulo)));
  await tester.pumpAndSettle();
  return container;
}

Future<void> abrirPresetEditado(WidgetTester tester, Tamanho t) async {
  final container = await abrirSlot(tester, '02A');
  unawaited(container.read(editorProvider.notifier).escolherCena(2));
  container.read(editorProvider.notifier).alterarParametro('Threshold', -52, arrastando: false);
  await tester.pumpAndSettle();
  await assentarImagens(tester);
}

