// A IA renomeando o preset e passeando pelos slots pelo servidor MCP de
// verdade, com a pedaleira de demonstração: abrir outro slot nunca joga fora
// edição sem a IA dizer que é para descartar, e ler um slot não muda o que
// está aberto nem o que soa.
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/modelo/controles_pedaleira.dart';
import 'package:anagram_app/nucleo/protocolo/api_anagram.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/app_com_mcp.dart';

int _enviosAoVivo(ProviderContainer container) =>
    pedaleiraDe(container).comandosRecebidos.where((c) => c.acao == AcoesAnagram.tocarAoVivo).length;

void main() {
  test('should_rename_the_preset_and_a_control_live_and_refuse_a_name_the_pedal_cannot_carry', () async {
    final (container, endereco, token) = await appComMcp();
    await ferramenta(endereco, token, 'assign_control', {'control': 'pot1', 'row': 1, 'column': 4, 'parameter': 'LowShelf'});

    final (erroPreset, preset) = await ferramenta(endereco, token, 'rename', {'name': 'Grave da IA'});
    final (erroControle, controle) = await ferramenta(endereco, token, 'rename', {'name': 'Graves', 'control': 'pot1'});
    final antes = container.read(editorProvider).atual;
    final (erroMarcador, motivo) = await ferramenta(endereco, token, 'rename', {'name': 'DEND'});
    final (erroLongo, _) = await ferramenta(endereco, token, 'rename', {'name': 'x' * 25});

    expect((erroPreset, erroControle), (false, false), reason: '$preset $controle');
    expect((erroMarcador, erroLongo), (true, true));
    expect(motivo, contains('DEND'));
    expect(identical(container.read(editorProvider).atual, antes), isTrue, reason: 'recusa não muda nada');
    final documento = container.read(editorProvider).atual!;
    expect(documento.nome, 'Grave da IA');
    expect(documento.controles[IdControle.pot1]!.nome, 'Graves');
    expect(pedaleiraDe(container).presetTocando!['preset']['name'], 'Grave da IA', reason: 'vai ao vivo');
    expect(container.read(editorProvider).naoSalvo, isTrue);
  });

  test('should_refuse_to_open_another_slot_over_unsaved_edits_unless_told_to_discard_them', () async {
    final (container, endereco, token) = await appComMcp();
    await ferramenta(endereco, token, 'set_parameter', {'row': 1, 'column': 1, 'parameter': 'Threshold', 'value': -12});
    final editado = container.read(editorProvider).atual;

    final (recusado, motivo) = await ferramenta(endereco, token, 'open_slot', {'slot': '03A'});
    expect(recusado, isTrue);
    expect(motivo, contains('discard_edits'));
    expect(identical(container.read(editorProvider).atual, editado), isTrue, reason: 'a edição continua na tela');

    final (erro, aberto) = await ferramenta(endereco, token, 'open_slot', {'slot': '03A', 'discard_edits': true});

    expect(erro, isFalse, reason: '$aberto');
    expect((aberto! as Map)['slot'], '03A');
    expect((aberto as Map)['preset']['name'], 'Paralelo Grave');
    expect(container.read(editorProvider).slot?.rotulo, '03A');
    expect(container.read(editorProvider).naoSalvo, isFalse);
    expect(container.read(editorProvider).slotNaPedaleira, isTrue, reason: 'a pedaleira passa a tocar o slot aberto');
  });

  test('should_read_and_list_slots_without_changing_what_is_open_or_what_plays', () async {
    final (container, endereco, token) = await appComMcp();
    final aberto = container.read(editorProvider).atual;
    final envios = _enviosAoVivo(container);

    final (erroLer, lido) = await ferramenta(endereco, token, 'read_slot', {'slot': '03A'});
    final (erroVazio, vazio) = await ferramenta(endereco, token, 'read_slot', {'slot': '42C'});
    final (erroLista, lista) = await ferramenta(endereco, token, 'list_slots');

    expect([erroLer, erroVazio, erroLista], everyElement(isFalse), reason: '$lido $vazio $lista');
    expect((lido! as Map)['preset']['name'], 'Paralelo Grave');
    expect(((lido as Map)['preset']['rows']['1'] as List).map((b) => b['type']), contains('urn:darkglass:B3K'));
    expect((vazio! as Map)['empty'], isTrue);
    final slots = ((lista! as Map)['slots'] as List).cast<Map<String, dynamic>>();
    expect(slots, contains(allOf(containsPair('slot', '03A'), containsPair('name', 'Paralelo Grave'))));
    expect(identical(container.read(editorProvider).atual, aberto), isTrue);
    expect(_enviosAoVivo(container), envios, reason: 'ler não toca nada');
  });
}
