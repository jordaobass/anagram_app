// Áreas de presets (firmware 1.18+): a pessoa tem a área padrão, "Estudo" e
// "User2", cada uma com presets próprios. Ler, gravar e listar têm de valer
// para a área escolhida, e o Program Change só para a que está ativa.
import 'package:anagram_app/aplicacao/estado/controlador_biblioteca.dart';
import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/midi/saida_midi.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:anagram_app/nucleo/protocolo/api_anagram.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';

Future<void> _esperarLista(ProviderContainer container) async {
  // a primeira lista só vem depois dos ajustes: espera ela de fato chegar
  for (var i = 0; i < 500; i++) {
    final estado = container.read(bibliotecaProvider);
    if (!estado.carregando && estado.ocupados.isNotEmpty) return;
    await Future<void>.delayed(const Duration(milliseconds: 2));
  }
}

Future<(ProviderContainer, TransporteDemonstracao, SaidaMidiDemonstracao)> _conectar({bool semAjustes = false}) async {
  final midi = SaidaMidiDemonstracao();
  final container = ProviderContainer(overrides: [
    presetsDemonstracaoProvider.overrideWith((ref) async => lerPresetsDemonstracao()),
    midiDemonstracaoProvider.overrideWithValue(() => midi),
    ajusteDemonstracaoProvider.overrideWithValue((pedaleira) => pedaleira.semAjustes = semAjustes),
  ]);
  container.read(bibliotecaProvider);
  await container.read(conexaoProvider.notifier).conectarDemonstracao();
  await _esperarLista(container);
  final pedaleira = container.read(conexaoProvider.notifier).transporte! as TransporteDemonstracao;
  return (container, pedaleira, midi);
}

Future<void> _irPara(ProviderContainer container, String area) async {
  await container.read(bibliotecaProvider.notifier).selecionarArea(area);
  await _esperarLista(container);
}

Set<String> _nomesNaLista(ProviderContainer container) =>
    container.read(bibliotecaProvider).ocupados.values.map((r) => r.nome).toSet();

void main() {
  test('should_list_the_presets_of_the_chosen_area_when_another_area_is_selected', () async {
    final (container, _, _) = await _conectar();
    final biblioteca = container.read(bibliotecaProvider);
    expect(biblioteca.areas.areas.map((a) => a.nome), ['Padrão', 'Estudo', 'User2']);
    expect(biblioteca.areaSelecionada, 'user', reason: 'começa na área ativa da pedaleira');

    await _irPara(container, 'user-2');

    expect(_nomesNaLista(container), {'Escalas lentas', 'Slap devagar', 'Groove 70 bpm'});
  });

  test('should_send_the_chosen_area_with_the_preset_commands_when_the_firmware_has_areas', () async {
    final (container, pedaleira, _) = await _conectar();
    await _irPara(container, 'user-3');

    await container.read(editorProvider.notifier).abrirSlot(SlotPreset(1));

    final leitura = pedaleira.comandosRecebidos.lastWhere((m) => m.acao == AcoesAnagram.lerPreset);
    expect(leitura.carga['userArea'], 'user-3');
    expect(container.read(editorProvider).atual!.nome, 'Show sábado');
  });

  test('should_save_into_the_chosen_area_and_leave_the_same_slot_of_other_areas_untouched', () async {
    final (container, pedaleira, _) = await _conectar();
    final nomeNaPadrao = pedaleira.conteudoDoSlot(1)!['preset']['name'];
    await _irPara(container, 'user-2');
    final editor = container.read(editorProvider.notifier);
    await editor.abrirSlot(SlotPreset(1));
    await editor.renomear('Escalas rápidas');

    await editor.salvar();

    expect(pedaleira.conteudoDoSlot(1, area: 'user-2')!['preset']['name'], 'Escalas rápidas');
    expect(pedaleira.conteudoDoSlot(1)!['preset']['name'], nomeNaPadrao);
  });

  test('should_not_switch_the_pedal_slot_when_the_chosen_area_is_not_the_active_one', () async {
    final (container, pedaleira, midi) = await _conectar();
    await _irPara(container, 'user-2');

    await container.read(editorProvider.notifier).abrirSlot(SlotPreset(2));
    expect(midi.mensagens, isEmpty, reason: 'o Program Change levaria a pedaleira ao slot 2 da área padrão');
    expect(container.read(bibliotecaProvider).areaForaDaPedaleira, isTrue);

    await container.read(bibliotecaProvider.notifier).tornarSelecionadaAtiva();
    await container.read(editorProvider.notifier).abrirSlot(SlotPreset(4));

    expect(pedaleira.areaAtiva, 'user-2');
    expect(midi.mensagens, [MensagensMidi.trocaDePrograma(SlotPreset(4))]);
  });

  test('should_close_the_open_preset_when_another_area_is_chosen', () async {
    final (container, _, _) = await _conectar();
    await container.read(editorProvider.notifier).abrirSlot(SlotPreset(1));
    expect(container.read(editorProvider).atual, isNotNull);

    await _irPara(container, 'user-2');

    final editor = container.read(editorProvider);
    expect(editor.slot, isNull, reason: 'o slot 1 aberto era da área anterior');
    expect(editor.atual, isNull);
  });

  test('should_work_as_before_without_area_fields_when_the_firmware_has_no_settings', () async {
    final (container, pedaleira, _) = await _conectar(semAjustes: true);

    expect(container.read(bibliotecaProvider).areas.temAreas, isFalse);
    expect(_nomesNaLista(container), isNotEmpty);
    await container.read(editorProvider.notifier).abrirSlot(SlotPreset(1));

    final comandos = pedaleira.comandosRecebidos.where((m) => m.acao != AcoesAnagram.lerAjustes);
    expect(comandos.where((m) => m.carga.containsKey('userArea')), isEmpty);
  });
}
