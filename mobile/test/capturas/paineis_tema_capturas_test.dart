// Capturas dos painéis com o tema da tela da pedaleira (DECISOES PT): Ignissor
// e Entropia em alumínio escovado, Axioma em synthwave, no escuro e no claro,
// no computador. Prefixo "px-". Gerar/atualizar:
// flutter test test/capturas/paineis_tema_capturas_test.dart --update-goldens
import 'dart:async';

import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/aplicacao/tema.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/capturas_apoio.dart';
import '../apoio/fixtures.dart';

const _computadorAlto = Tamanho('desktop', 1440, 1900, 1, plataforma: TargetPlatform.windows);
const _computadorSynth = Tamanho('desktop', 1440, 2050, 1, plataforma: TargetPlatform.windows);

Future<void> _painel(WidgetTester tester, Tamanho tamanho, String uri, EscolhaTema tema) async {
  await preparar(tester, tamanho, tema: tema);
  final container = await abrirSlot(tester, '01A');
  unawaited(container.read(editorProvider.notifier).adicionarBloco(const PosicaoBloco(1, 4), lerCatalogo().definicao(uri)));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(carregarFontes);

  const blocos = [
    ('01', 'ignissor', 'urn:darkglass:ignissor', _computadorAlto),
    ('03', 'entropia', 'urn:darkglass:entropia', _computadorAlto),
    ('05', 'axioma', 'urn:darkglass:axioma_synth', _computadorSynth),
  ];
  for (final (numero, nome, uri, tamanho) in blocos) {
    final segundo = (int.parse(numero) + 1).toString().padLeft(2, '0');
    testWidgets('captura px: $nome no escuro', (tester) async {
      await _painel(tester, tamanho, uri, EscolhaTema.escuro);
      await capturar(tester, '$pasta/px-$numero-desktop-$nome-escuro.png');
    });
    testWidgets('captura px: $nome no claro', (tester) async {
      await _painel(tester, tamanho, uri, EscolhaTema.claro);
      await capturar(tester, '$pasta/px-$segundo-desktop-$nome-claro.png');
    });
  }
}
