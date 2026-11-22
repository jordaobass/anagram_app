// Pausa entre pacotes USB: escolhida em Configurações (com ou sem pedaleira),
// fica guardada e vale na próxima abertura do app.
import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:anagram_app/nucleo/protocolo/cliente_anagram.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/app_de_teste.dart';
import '../apoio/demonstracao_na_tela.dart';
import '../apoio/fixtures.dart';

void main() {
  testWidgets('should_keep_the_usb_pause_picked_in_settings_even_without_a_pedal', (tester) async {
    final preferencias = PreferenciasPausaEmMemoria();
    await montarApp(tester, preferenciasPausa: preferencias);

    await tester.tap(find.byKey(const ValueKey('botao-configuracoes')));
    await tester.pumpAndSettle();
    final dois = find.descendant(of: find.byKey(const ValueKey('seletor-pausa')), matching: find.text('2 ms'));
    await tester.scrollUntilVisible(dois, 200, scrollable: find.byType(Scrollable).first);
    await tester.tap(dois);
    await tester.pumpAndSettle();

    expect(preferencias.salvo, 2);
  });

  test('should_send_with_the_saved_pause_when_the_app_opens_again', () async {
    final container = ProviderContainer(overrides: [
      presetsDemonstracaoProvider.overrideWith((ref) async => lerPresetsDemonstracao()),
      pausaSalvaProvider.overrideWithValue(const Duration(milliseconds: 2)),
    ]);
    addTearDown(container.dispose);
    await container.read(conexaoProvider.notifier).conectarDemonstracao();
    final medicoes = <MedicaoChamada>[];
    container.read(conexaoProvider.notifier).repositorio!.medicoes.listen(medicoes.add);

    await container.read(editorProvider.notifier).abrirSlot(SlotPreset(3));

    expect(medicoes.last.pausa, const Duration(milliseconds: 2));
  });
}
