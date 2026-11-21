// Área Fábrica (DECISOES U18): os presets de fábrica não vêm da pedaleira,
// vêm do arquivo gerado do Suite. Abrir um deles só toca (temporário, sem
// Program Change e sem ler nada da pedaleira); guardar é copiar para uma área
// da pessoa, com uuid novo. Nada é gravado "na fábrica".
import 'package:anagram_app/aplicacao/casos_de_uso/salvar_no_slot.dart';
import 'package:anagram_app/aplicacao/estado/controlador_biblioteca.dart';
import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/midi/saida_midi.dart';
import 'package:anagram_app/nucleo/modelo/presets_fabrica.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:anagram_app/nucleo/protocolo/api_anagram.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';

const _fabrica = PresetsDeFabrica.idArea;

Future<void> _esperarLista(ProviderContainer container) async {
  for (var i = 0; i < 500; i++) {
    final estado = container.read(bibliotecaProvider);
    if (!estado.carregando && estado.ocupados.isNotEmpty) return;
    await Future<void>.delayed(const Duration(milliseconds: 2));
  }
}

Future<(ProviderContainer, TransporteDemonstracao, SaidaMidiDemonstracao)> _conectar() async {
  final midi = SaidaMidiDemonstracao();
  final container = ProviderContainer(
    overrides: [
      presetsDemonstracaoProvider.overrideWith((ref) async => lerPresetsDemonstracao()),
      presetsFabricaProvider.overrideWith((ref) async => PresetsDeFabrica.doTexto(textoFabricaDeTeste())),
      midiDemonstracaoProvider.overrideWithValue(() => midi),
    ],
  );
  addTearDown(container.dispose);
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

Iterable<String?> _areasPedidas(TransporteDemonstracao pedaleira) =>
    pedaleira.comandosRecebidos.map((m) => m.carga['userArea'] as String?);

void main() {
  test('should_play_a_factory_preset_without_program_change_or_asking_the_pedal_for_it_when_opened', () async {
    final (container, pedaleira, midi) = await _conectar();
    await _irPara(container, _fabrica);
    expect(container.read(bibliotecaProvider).ocupados.values.map((r) => r.nome), [
      'Harmonic Booster',
      'Vintage Microtubes',
    ]);
    final antes = midi.mensagens.length;

    await container.read(editorProvider.notifier).abrirSlot(SlotPreset(2));

    expect(container.read(editorProvider).atual!.nome, 'Vintage Microtubes');
    expect(midi.mensagens.length, antes, reason: 'Program Change levaria a pedaleira ao 01B da área ativa');
    expect(pedaleira.presetTocando!['preset']['name'], 'Vintage Microtubes', reason: 'a audição é o temporário');
    expect(_areasPedidas(pedaleira), isNot(contains(_fabrica)), reason: 'a fábrica nunca vai para a pedaleira');
  });

  test('should_copy_a_factory_preset_into_the_chosen_area_with_a_new_uuid_when_saved_there', () async {
    final (container, pedaleira, _) = await _conectar();
    await _irPara(container, _fabrica);
    final editor = container.read(editorProvider.notifier);
    await editor.abrirSlot(SlotPreset(1));
    final uuidDeFabrica = container.read(editorProvider).atual!.uuid;

    expect(await editor.salvar(), isNull, reason: 'salvar na fábrica pede o destino');
    await _irPara(container, 'user-2');
    editor.iniciarSalvarComo();
    final resultado = await editor.salvarComo(SlotPreset(10), confirmado: true);

    expect(resultado, isA<PresetSalvo>());
    final gravado = pedaleira.conteudoDoSlot(10, area: 'user-2')!['preset'] as Map<String, dynamic>;
    expect(gravado['name'], 'Harmonic Booster');
    expect(gravado['uuid'], isNot(uuidDeFabrica));
    expect(_areasPedidas(pedaleira), isNot(contains(_fabrica)));
  });

  test('should_refuse_to_write_when_a_destination_on_the_factory_list_is_picked', () async {
    final (container, pedaleira, _) = await _conectar();
    await _irPara(container, _fabrica);
    final editor = container.read(editorProvider.notifier);
    await editor.abrirSlot(SlotPreset(1));

    final resultado = await editor.salvarComo(SlotPreset(1), confirmado: true);

    expect(resultado, isA<FalhaAoSalvar>());
    expect(pedaleira.comandosRecebidos.where((m) => m.acao == AcoesAnagram.salvar), isEmpty);
  });
}
