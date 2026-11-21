// Áreas de presets ao longo do tempo: o cabo sai e volta, a pessoa troca de
// área na própria pedaleira, o firmware ignora o "tornar ativa". Em nenhum
// desses casos o app pode gravar na área errada nem mandar a pedaleira para
// o slot de outra área.
import 'package:anagram_app/aplicacao/avisos.dart';
import 'package:anagram_app/aplicacao/casos_de_uso/salvar_no_slot.dart';
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
  for (var i = 0; i < 500; i++) {
    final estado = container.read(bibliotecaProvider);
    if (!estado.carregando && estado.ocupados.isNotEmpty) return;
    await Future<void>.delayed(const Duration(milliseconds: 2));
  }
}

typedef _Bancada = (ProviderContainer, SaidaMidiDemonstracao);

Future<_Bancada> _conectar({void Function(TransporteDemonstracao)? ajuste}) async {
  final midi = SaidaMidiDemonstracao();
  final container = ProviderContainer(overrides: [
    presetsDemonstracaoProvider.overrideWith((ref) async => lerPresetsDemonstracao()),
    midiDemonstracaoProvider.overrideWithValue(() => midi),
    ajusteDemonstracaoProvider.overrideWithValue((pedaleira) => ajuste?.call(pedaleira)),
  ]);
  container.read(bibliotecaProvider);
  await container.read(conexaoProvider.notifier).conectarDemonstracao();
  await _esperarLista(container);
  return (container, midi);
}

TransporteDemonstracao _pedaleira(ProviderContainer container) =>
    container.read(conexaoProvider.notifier).transporte! as TransporteDemonstracao;

Future<void> _irPara(ProviderContainer container, String area) async {
  await container.read(bibliotecaProvider.notifier).selecionarArea(area);
  await _esperarLista(container);
}

void main() {
  test('should_not_overwrite_the_same_slot_of_another_area_when_saving_after_a_reconnect', () async {
    final (container, _) = await _conectar();
    await _irPara(container, 'user-2');
    final editor = container.read(editorProvider.notifier);
    await editor.abrirSlot(SlotPreset(1));
    await editor.renomear('Escalas rapidas');

    await container.read(conexaoProvider.notifier).desconectar();
    await container.read(conexaoProvider.notifier).conectarDemonstracao();
    await _esperarLista(container);
    final pedaleira = _pedaleira(container);
    final nomeNaPadrao = pedaleira.conteudoDoSlot(1)!['preset']['name'];
    // depois de reconectar a lista volta para a área ativa ("user")
    expect(container.read(bibliotecaProvider).areaSelecionada, 'user');

    final resultado = await editor.salvar();

    expect(resultado, isNot(isA<PresetSalvo>()), reason: 'o 01A aberto era da área user-2, não da que está na tela');
    expect(pedaleira.conteudoDoSlot(1)!['preset']['name'], nomeNaPadrao);
    expect(container.read(editorProvider).escolhendoDestino, isTrue, reason: 'vira um "Salvar como"');
  });

  test('should_keep_the_open_preset_without_a_slot_when_another_area_is_chosen', () async {
    final (container, _) = await _conectar();
    final editor = container.read(editorProvider.notifier);
    await editor.abrirSlot(SlotPreset(1));
    await editor.renomear('Levar para o estudo');

    await _irPara(container, 'user-2');

    final estado = container.read(editorProvider);
    expect(estado.slot, isNull, reason: 'o 01A aberto era da área anterior');
    expect(estado.atual?.nome, 'Levar para o estudo', reason: 'a edição pode ser gravada na área nova');
    expect(await editor.salvar(), isNull);
    expect(container.read(editorProvider).escolhendoDestino, isTrue);
  });

  test('should_keep_the_area_inactive_and_warn_when_the_pedal_ignores_the_switch', () async {
    final (container, _) = await _conectar(ajuste: (p) => p.ignorarTrocaDeArea = true);
    await _irPara(container, 'user-2');

    await container.read(bibliotecaProvider.notifier).tornarSelecionadaAtiva();

    final biblioteca = container.read(bibliotecaProvider);
    expect(biblioteca.areas.ativa, 'user', reason: 'o "ok" não basta: a pedaleira continuou na área padrão');
    expect(biblioteca.areaForaDaPedaleira, isTrue);
    expect(biblioteca.erro, isA<AvisoAreaNaoTrocou>());
  });

  test('should_not_send_program_change_when_the_pedal_switched_area_on_its_own', () async {
    final (container, midi) = await _conectar();
    // a pessoa trocou de área na tela da própria pedaleira
    _pedaleira(container).areaAtiva = 'user-2';

    await container.read(editorProvider.notifier).abrirSlot(SlotPreset(2));

    expect(midi.mensagens, isEmpty, reason: 'o 02 da área user-2 não é o 02 que está na tela');
    expect(container.read(bibliotecaProvider).areaForaDaPedaleira, isTrue);
  });

  test('should_not_send_program_change_when_the_pedal_does_not_say_which_area_is_active', () async {
    final (container, midi) = await _conectar(ajuste: (p) => p.semAreaAtiva = true);

    await container.read(editorProvider.notifier).abrirSlot(SlotPreset(2));

    expect(midi.mensagens, isEmpty);
    expect(container.read(bibliotecaProvider).areas.ativa, isNull, reason: 'desconhecida, não "user" por suposição');
  });

  test('should_not_leave_the_list_loading_when_the_cable_drops_while_the_areas_are_read', () async {
    final (container, _) = await _conectar(ajuste: (p) => p.naoResponder = AcoesAnagram.lerAjustes);

    await container.read(conexaoProvider.notifier).desconectar();
    // o prazo dos ajustes (3 s) vence depois que a conexão já acabou
    await Future<void>.delayed(ApiAnagram.prazoAjustes + const Duration(milliseconds: 300));

    final biblioteca = container.read(bibliotecaProvider);
    expect(biblioteca.carregando, isFalse);
    expect(biblioteca.ocupados, isEmpty);
  });
}
