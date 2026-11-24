// Capturas dos painéis com a tela da pedaleira (DECISOES PT): Ignissor e
// Entropia no chassi de alumínio, Axioma no aparelho em neon, com o app no
// tema escuro e no claro em volta (a tela do aparelho é a mesma nos dois,
// PT9), e a janela "Select Block Template" de cada um. Prefixo "px-".
// Gerar/atualizar: flutter test test/capturas/paineis_tema_capturas_test.dart --update-goldens
import 'dart:async';

import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/aplicacao/tema.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/capturas_apoio.dart';
import '../apoio/fixtures.dart';

const _computadorAlto = Tamanho('desktop', 1440, 1950, 1, plataforma: TargetPlatform.windows);
const _computadorSynth = Tamanho('desktop', 1440, 2250, 1, plataforma: TargetPlatform.windows);
const _computador = Tamanho('desktop', 1440, 900, 1, plataforma: TargetPlatform.windows);

Future<void> _painel(WidgetTester tester, Tamanho tamanho, String uri, EscolhaTema tema) async {
  await preparar(tester, tamanho, tema: tema);
  final container = await abrirSlot(tester, '01A');
  unawaited(container.read(editorProvider.notifier).adicionarBloco(const PosicaoBloco(1, 4), lerCatalogo().definicao(uri)));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(carregarFontes);

  const blocos = [
    ('01', '07', 'ignissor', 'urn:darkglass:ignissor', _computadorAlto),
    ('03', '08', 'entropia', 'urn:darkglass:entropia', _computadorAlto),
    ('05', '09', 'axioma', 'urn:darkglass:axioma_synth', _computadorSynth),
  ];
  for (final (numero, janela, nome, uri, tamanho) in blocos) {
    final segundo = (int.parse(numero) + 1).toString().padLeft(2, '0');
    testWidgets('captura px: $nome com o app escuro', (tester) async {
      await _painel(tester, tamanho, uri, EscolhaTema.escuro);
      await capturar(tester, '$pasta/px-$numero-desktop-$nome-app-escuro.png');
    });
    testWidgets('captura px: $nome com o app claro (a tela não muda)', (tester) async {
      await _painel(tester, tamanho, uri, EscolhaTema.claro);
      await capturar(tester, '$pasta/px-$segundo-desktop-$nome-app-claro.png');
    });
    testWidgets('captura px: janela de templates do $nome', (tester) async {
      await _painel(tester, _computador, uri, EscolhaTema.escuro);
      final abrir = find.byKey(const ValueKey('abrir-templates'));
      await tester.ensureVisible(abrir);
      await tester.pumpAndSettle();
      await tester.tap(abrir);
      await tester.pumpAndSettle();
      await capturar(tester, '$pasta/px-$janela-desktop-templates-$nome.png');
    });
  }
}
