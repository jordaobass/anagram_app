// Organizar os presets na pedaleira: mover um preset para outro slot (com o
// destino ocupado, os dois trocam de lugar depois de confirmar), clonar com
// uuid novo e trocar bancos inteiros — sempre na área que está na tela.
import 'package:anagram_app/aplicacao/estado/controlador_biblioteca.dart';
import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/aplicacao/estado/controlador_organizar.dart';
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:anagram_app/nucleo/protocolo/quadros_hid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';

final slot01a = SlotPreset.doRotulo('01A');
final slot01b = SlotPreset.doRotulo('01B');
final slot15b = SlotPreset.doRotulo('15B');

String? _nome(ProviderContainer c, SlotPreset slot) => c.read(bibliotecaProvider).resumo(slot)?.nome;

List<MensagemAnagram> _pedidos(TransporteDemonstracao t, String acao) =>
    t.comandosRecebidos.where((m) => m.acao == acao).toList();

/// Conecta e espera a lista (e as áreas) chegarem, como a pessoa vê ao abrir.
Future<(ProviderContainer, TransporteDemonstracao)> _conectarComLista() async {
  final container = ProviderContainer(overrides: [
    presetsDemonstracaoProvider.overrideWith((ref) async => lerPresetsDemonstracao()),
  ]);
  container.read(bibliotecaProvider);
  await container.read(conexaoProvider.notifier).conectarDemonstracao();
  await _esperarLista(container);
  return (container, container.read(conexaoProvider.notifier).transporte! as TransporteDemonstracao);
}

Future<void> _esperarLista(ProviderContainer container) async {
  for (var i = 0; i < 500; i++) {
    final estado = container.read(bibliotecaProvider);
    if (!estado.carregando && estado.ocupados.isNotEmpty) return;
    await Future<void>.delayed(const Duration(milliseconds: 2));
  }
}

Future<ResultadoOrganizar> _fazer(ProviderContainer c, OperacaoPreset operacao, SlotPreset origem, SlotPreset destino,
    {bool confirmado = false}) {
  final organizar = c.read(organizarProvider.notifier)..iniciar(operacao, origem);
  return organizar.concluir(destino, confirmado: confirmado);
}

void main() {
  test('should_move_the_preset_to_an_empty_slot_with_the_swap_command_when_moved', () async {
    final (container, pedaleira) = await _conectarComLista();
    final nome = _nome(container, slot01a);

    final resultado = await _fazer(container, OperacaoPreset.mover, slot01a, slot15b);

    expect(resultado, isA<Organizado>());
    expect(_nome(container, slot15b), nome);
    expect(_nome(container, slot01a), isNull, reason: 'a origem fica vazia');
    final pedido = _pedidos(pedaleira, 'swap_anagram_presets').single.carga;
    expect([pedido['fromIndex'], pedido['toIndex']], [1, 44], reason: 'índice = número do slot, como no Suite');
  });

  test('should_ask_and_send_nothing_then_swap_both_when_the_destination_is_occupied_and_confirmed', () async {
    final (container, pedaleira) = await _conectarComLista();
    final (a, b) = (_nome(container, slot01a), _nome(container, slot01b));

    final pergunta = await _fazer(container, OperacaoPreset.mover, slot01a, slot01b);
    expect(pergunta, isA<DestinoOcupado>());
    expect(_pedidos(pedaleira, 'swap_anagram_presets'), isEmpty);

    await container.read(organizarProvider.notifier).concluir(slot01b, confirmado: true);
    expect([_nome(container, slot01a), _nome(container, slot01b)], [b, a]);
  });

  test('should_clone_with_a_new_uuid_and_keep_the_origin_when_cloned', () async {
    final (container, pedaleira) = await _conectarComLista();

    final resultado = await _fazer(container, OperacaoPreset.clonar, slot01a, slot15b);

    expect(resultado, isA<Organizado>());
    expect(_nome(container, slot15b), _nome(container, slot01a));
    Object? uuid(SlotPreset s) => (pedaleira.conteudoDoSlot(s.numero)!['preset'] as Map<String, dynamic>)['uuid'];
    expect(uuid(slot15b), isNot(uuid(slot01a)), reason: 'dois presets com o mesmo id confundem a pedaleira');
  });

  test('should_ask_then_overwrite_the_occupied_slot_when_cloning_onto_it_is_confirmed', () async {
    final (container, pedaleira) = await _conectarComLista();
    final nomeDaOrigem = _nome(container, slot01a);

    final pergunta = await _fazer(container, OperacaoPreset.clonar, slot01a, slot01b);
    final resultado = await container.read(organizarProvider.notifier).concluir(slot01b, confirmado: true);

    expect(pergunta, isA<DestinoOcupado>());
    expect(resultado, isA<Organizado>(), reason: 'confirmado, o clone substitui o preset do destino');
    expect(pedaleira.conteudoDoSlot(slot01b.numero)!['preset']['name'], nomeDaOrigem);
  });

  test('should_swap_whole_banks_when_trading_a_bank', () async {
    final (container, pedaleira) = await _conectarComLista();
    final banco1 = [for (final r in ['01A', '01B', '01C']) _nome(container, SlotPreset.doRotulo(r))];

    await _fazer(container, OperacaoPreset.trocarBanco, slot01a, slot15b, confirmado: true);

    expect([for (final r in ['15A', '15B', '15C']) _nome(container, SlotPreset.doRotulo(r))], banco1);
    final pares = _pedidos(pedaleira, 'swap_anagram_banks').single.carga['positions'] as List<dynamic>;
    expect(pares, [
      {'fromIndex': 1, 'toIndex': 43},
      {'fromIndex': 2, 'toIndex': 44},
      {'fromIndex': 3, 'toIndex': 45},
    ]);
  });

  test('should_organize_in_the_area_on_screen_when_another_area_is_selected', () async {
    final (container, pedaleira) = await _conectarComLista();
    await container.read(bibliotecaProvider.notifier).selecionarArea('user-2');
    await _esperarLista(container);

    await _fazer(container, OperacaoPreset.mover, slot01a, slot15b);

    expect(_pedidos(pedaleira, 'swap_anagram_presets').single.carga['userArea'], 'user-2');
    expect(pedaleira.conteudoDoSlot(44, area: 'user-2'), isNotNull);
    expect(pedaleira.conteudoDoSlot(44), isNull, reason: 'a área padrão não muda');
  });

  test('should_keep_the_open_preset_in_the_editor_on_its_new_slot_when_it_is_moved', () async {
    final (container, _) = await _conectarComLista();
    await container.read(editorProvider.notifier).abrirSlot(slot01a);

    await _fazer(container, OperacaoPreset.mover, slot01a, slot15b);

    expect(container.read(editorProvider).slot, slot15b);
    expect(container.read(editorProvider).naoSalvo, isFalse);
  });

  test('should_not_save_the_replaced_preset_over_the_clone_when_the_clone_went_to_the_slot_open_in_the_editor',
      () async {
    final (container, pedaleira) = await _conectarComLista();
    final editor = container.read(editorProvider.notifier);
    await editor.abrirSlot(slot01b);
    final nomeDaOrigem = _nome(container, slot01a);

    await _fazer(container, OperacaoPreset.clonar, slot01a, slot01b, confirmado: true);
    await editor.salvar();

    expect(container.read(editorProvider).atual!.nome, nomeDaOrigem, reason: 'o editor mostra o que está no slot');
    expect(pedaleira.conteudoDoSlot(slot01b.numero)!['preset']['name'], nomeDaOrigem,
        reason: 'o Cmd+S não pode gravar o preset substituído por cima do clone');
  });
}
