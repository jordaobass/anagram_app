// O slot aberto foi regravado por fora (na própria pedaleira ou pelo Suite)
// depois que o app o abriu: o Salvar não pode passar por cima sem perguntar.
import 'package:anagram_app/aplicacao/casos_de_uso/salvar_no_slot.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/conexao_demo.dart';

void main() {
  test('should_not_overwrite_and_ask_when_the_slot_was_saved_outside_the_app_after_opening', () async {
    final (container, pedaleira) = await _editadoComSlotMudadoPorFora();

    final resultado = await container.read(editorProvider.notifier).salvar();

    expect(resultado, isA<SlotAlteradoFora>(), reason: 'o slot mudou desde que foi aberto');
    expect((resultado! as SlotAlteradoFora).atual!.nome, 'Gravado na pedaleira');
    expect(pedaleira.conteudoDoSlot(3)!['preset']['name'], 'Gravado na pedaleira');
    expect(container.read(editorProvider).naoSalvo, isTrue, reason: 'a edição continua na tela');
  });

  test('should_overwrite_only_when_the_player_insists_or_reload_the_outside_version', () async {
    final (container, pedaleira) = await _editadoComSlotMudadoPorFora();
    final editor = container.read(editorProvider.notifier);

    expect(await editor.salvar(mesmoAlteradoFora: true), isA<PresetSalvo>());
    expect(pedaleira.conteudoDoSlot(3)!['preset']['name'], 'Editado no app');

    pedaleira.substituirSlot(3, _renomeado(pedaleira.conteudoDoSlot(3)!, 'Outra vez por fora'));
    await editor.recarregarDaPedaleira();
    expect(container.read(editorProvider).atual!.nome, 'Outra vez por fora');
    expect(container.read(editorProvider).naoSalvo, isFalse);
  });

  test('should_save_normally_when_the_slot_is_unchanged_since_opening', () async {
    final (container, pedaleira) = await conectarDemonstracao();
    final editor = container.read(editorProvider.notifier);
    await editor.abrirSlot(SlotPreset(3));
    await editor.renomear('Editado no app');

    expect(await editor.salvar(), isA<PresetSalvo>());
    expect(pedaleira.conteudoDoSlot(3)!['preset']['name'], 'Editado no app');
  });
}

Map<String, dynamic> _renomeado(Map<String, dynamic> conteudo, String nome) =>
    {...conteudo, 'preset': {...conteudo['preset'] as Map<String, dynamic>, 'name': nome}};

/// 03 aberto e editado no app; depois, regravado por fora.
Future<(ProviderContainer, TransporteDemonstracao)> _editadoComSlotMudadoPorFora() async {
  final (container, pedaleira) = await conectarDemonstracao();
  final editor = container.read(editorProvider.notifier);
  await editor.abrirSlot(SlotPreset(3));
  pedaleira.substituirSlot(3, _renomeado(pedaleira.conteudoDoSlot(3)!, 'Gravado na pedaleira'));
  await editor.renomear('Editado no app');
  return (container, pedaleira);
}
