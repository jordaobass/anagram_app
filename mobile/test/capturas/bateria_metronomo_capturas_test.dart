// Capturas dos painéis da bateria (Auto Drummer) e do metrônomo (Cognate
// Metro): o bloco novo na casa 4 do 01A, no computador e no celular.
// Prefixo "ut-". Com COM_MINIATURAS=1 saem com a arte, na pasta ignorada.
import 'dart:async';

import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/capturas_apoio.dart';
import '../apoio/fixtures.dart';

const _computadorAlto = Tamanho('desktop', 1440, 2000, 1, plataforma: TargetPlatform.windows);
const _celular = Tamanho('celular-retrato', 390, 2600, 2);

const _blocos = {
  'bateria': 'https://falktx.com/plugins/auto-drummer',
  'metronomo': 'https://cognate.audio/plugins/cognate-metro',
};

Future<void> _painel(WidgetTester tester, Tamanho tamanho, String uri) async {
  await preparar(tester, tamanho);
  final container = await abrirSlot(tester, '01A');
  unawaited(container.read(editorProvider.notifier).adicionarBloco(const PosicaoBloco(1, 4), lerCatalogo().definicao(uri)));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(carregarFontes);

  for (final MapEntry(key: nome, value: uri) in _blocos.entries) {
    testWidgets('captura ut: $nome no computador', (tester) async {
      await _painel(tester, _computadorAlto, uri);
      await capturar(tester, '$pasta/ut-01-desktop-$nome.png');
    });

    testWidgets('captura ut: $nome no celular', (tester) async {
      await _painel(tester, _celular, uri);
      await capturar(tester, '$pasta/ut-90-celular-$nome.png');
    });
  }
}
