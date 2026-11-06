// Sair da conexão (desconectar, cancelar, cabo puxado) limpa o que dependia
// da pedaleira e avisa uma vez só.
import 'dart:async';

import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/aplicacao/estado/estado_conexao.dart';
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/midi/saida_midi.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/conexao_demo.dart';
import '../apoio/demonstracao_na_tela.dart';
import '../apoio/fixtures.dart';

void main() {
  test('should_reset_destination_mode_and_pedal_slot_when_disconnecting', () async {
    final (container, _) = await conectarDemonstracao();
    final editor = container.read(editorProvider.notifier);
    await editor.abrirSlot(SlotPreset(3));
    editor.iniciarSalvarComo();

    await container.read(conexaoProvider.notifier).desconectar();

    final estado = container.read(editorProvider);
    expect([estado.escolhendoDestino, estado.slotNaPedaleira], [false, false]);
  });

  test('should_not_crash_when_cancelling_while_midi_opens', () async {
    final container = ProviderContainer(overrides: [
      presetsDemonstracaoProvider.overrideWith((ref) async => lerPresetsDemonstracao()),
      midiDemonstracaoProvider.overrideWithValue(() => SaidaMidiDemonstracao(atrasoAoAbrir: const Duration(milliseconds: 300))),
    ]);
    final conexao = container.read(conexaoProvider.notifier);
    final tentativa = conexao.conectarDemonstracao();
    await Future<void>.delayed(const Duration(milliseconds: 100));

    await conexao.cancelarConexao();
    await tentativa;

    expect(container.read(conexaoProvider), isA<SemConexao>());
  });

  testWidgets('should_say_the_disconnection_once_when_the_pedal_is_unplugged', (tester) async {
    final c = await abrirDemonstracao(tester);
    unawaited(c.read(editorProvider.notifier).abrirSlot(SlotPreset.doRotulo('01C')));
    await tester.pumpAndSettle();
    (c.read(conexaoProvider.notifier).transporte! as TransporteDemonstracao).desconectar();
    await tester.pumpAndSettle();

    expect(find.textContaining('foi desconectada'), findsOneWidget);
  });
}
