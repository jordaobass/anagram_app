// Capturas do painel do Axioma Mono Synth: o bloco novo na casa 4 do 01A,
// no computador (padrão e com filtro ressonante, onda quadrada e arpejador
// ligado) e no celular. Prefixo "ax-". Saem com a arte real
// dos pedais.
import 'dart:async';

import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/capturas_apoio.dart';
import '../apoio/fixtures.dart';

const _computadorAlto = Tamanho('desktop', 1440, 2000, 1, plataforma: TargetPlatform.windows);
const _celular = Tamanho('celular-retrato', 390, 2600, 2);

Future<ProviderContainer> _painel(WidgetTester tester, Tamanho tamanho) async {
  await preparar(tester, tamanho);
  final container = await abrirSlot(tester, '01A');
  unawaited(container
      .read(editorProvider.notifier)
      .adicionarBloco(const PosicaoBloco(1, 4), lerCatalogo().definicao('urn:darkglass:axioma_synth')));
  await tester.pumpAndSettle();
  return container;
}

void main() {
  setUpAll(carregarFontes);

  testWidgets('captura ax: Axioma no computador', (tester) async {
    await _painel(tester, _computadorAlto);
    await capturar(tester, '$pasta/ax-01-desktop-axioma.png');
  });

  testWidgets('captura ax: Axioma com filtro ressonante, onda quadrada e arpejador', (tester) async {
    final c = await _painel(tester, _computadorAlto);
    c.read(editorProvider.notifier)
      ..alterarParametro('reso', 9, arrastando: false)
      ..alterarParametro('cutoff', 3, arrastando: false)
      ..alterarParametro('osc1_wave', 1, arrastando: false)
      ..alterarParametro('osc2_wave', 2, arrastando: false)
      ..alterarParametro('attack', 6, arrastando: false)
      ..alterarParametro('release', 7, arrastando: false)
      ..alterarParametro('arp_enable', 1, arrastando: false);
    await tester.pumpAndSettle();
    await capturar(tester, '$pasta/ax-02-desktop-axioma-ajustado.png');
  });

  testWidgets('captura ax: Axioma no celular', (tester) async {
    await _painel(tester, _celular);
    await capturar(tester, '$pasta/ax-90-celular-axioma.png');
  });
}
