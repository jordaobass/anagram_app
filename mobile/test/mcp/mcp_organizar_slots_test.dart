// A IA arrumando a pedaleira (DECISOES IA9) pelo servidor MCP de verdade, com
// a pedaleira de demonstração: limpar e mover slots só com a pessoa
// confirmando a lista inteira uma vez, e nada é escrito antes disso.
import 'package:anagram_app/aplicacao/mcp/avisos_mcp.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/app_com_mcp.dart';

Future<Map<String, String>> _nomes(String endereco, String token) async {
  final (_, lista) = await ferramenta(endereco, token, 'list_slots');
  return {for (final s in (lista! as Map)['slots'] as List) s['slot'] as String: s['name'] as String};
}

/// Responde ao próximo pedido de organizar e guarda as linhas que a pessoa viu.
List<String> _responder(ProviderContainer container, bool confirmar) {
  final vistas = <String>[];
  container.listen(pedidoOrganizarProvider, (_, pedido) {
    if (pedido == null) return;
    vistas.addAll(pedido.linhas);
    pedido.responder(confirmar);
  });
  return vistas;
}

void main() {
  test('should_clear_several_slots_after_one_confirmation_listing_each_preset', () async {
    final (container, endereco, token) = await appComMcp();
    final antes = await _nomes(endereco, token);
    final vistas = _responder(container, true);

    final (erro, resposta) = await ferramenta(endereco, token, 'clear_slot', {
      'slots': ['03A', '02B'],
    });

    expect(erro, isFalse, reason: '$resposta');
    expect((resposta! as Map)['cleared'], ['02B', '03A'], reason: 'na ordem dos slots');
    expect(vistas, ['02B  ${antes['02B']}', '03A  ${antes['03A']}']);
    final depois = await _nomes(endereco, token);
    expect(depois.keys, isNot(contains('03A')));
    expect(depois.keys, isNot(contains('02B')));
    expect(depois.length, antes.length - 2);
  });

  test('should_write_nothing_when_the_player_declines_or_the_slot_is_already_empty', () async {
    final (container, endereco, token) = await appComMcp();
    final antes = await _nomes(endereco, token);
    _responder(container, false);

    final (erroRecusa, recusa) = await ferramenta(endereco, token, 'clear_slot', {
      'slots': ['03A'],
    });
    final (erroVazio, motivo) = await ferramenta(endereco, token, 'clear_slot', {
      'slots': ['42C'],
    });

    expect(erroRecusa, isFalse);
    expect((recusa! as Map)['status'], 'declined');
    expect(erroVazio, isTrue);
    expect(motivo, contains('42C'));
    expect(await _nomes(endereco, token), antes);
  });

  test('should_move_into_an_empty_slot_and_swap_with_an_occupied_one_in_the_order_given', () async {
    final (container, endereco, token) = await appComMcp();
    final antes = await _nomes(endereco, token);
    final vistas = _responder(container, true);

    final (erro, resposta) = await ferramenta(endereco, token, 'move_slot', {
      'moves': [
        {'from': '03A', 'to': '42C'},
        {'from': '02A', 'to': '02B'},
      ],
    });

    expect(erro, isFalse, reason: '$resposta');
    expect((resposta! as Map)['moved'], ['03A→42C', '02A→02B']);
    expect(vistas.first, '03A → 42C  ${antes['03A']}');
    expect(vistas.last, '02A → 02B  ${antes['02A']}  ⇄  ${antes['02B']}');
    final depois = await _nomes(endereco, token);
    expect(depois['42C'], antes['03A']);
    expect(depois.keys, isNot(contains('03A')));
    expect(depois['02B'], antes['02A']);
    expect(depois['02A'], antes['02B']);
  });

  test('should_refuse_a_move_from_a_slot_that_is_empty_at_that_point_of_the_list', () async {
    final (container, endereco, token) = await appComMcp();
    final antes = await _nomes(endereco, token);
    _responder(container, true);

    final (erro, motivo) = await ferramenta(endereco, token, 'move_slot', {
      'moves': [
        {'from': '03A', 'to': '42C'},
        {'from': '03A', 'to': '42B'},
      ],
    });

    expect(erro, isTrue);
    expect(motivo, contains('03A is empty'));
    expect(await _nomes(endereco, token), antes, reason: 'recusa antes de perguntar: nada mudou');
  });
}
