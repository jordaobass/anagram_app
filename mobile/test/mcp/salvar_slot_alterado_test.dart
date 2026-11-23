// save_preset com o slot regravado na pedaleira depois de aberto: a IA
// recebe a recusa e nada é gravado (sobrescrever é decisão da pessoa).
import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/mcp/avisos_mcp.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/app_com_mcp.dart';

void main() {
  test('should_refuse_to_save_when_the_slot_was_changed_on_the_pedal_after_opening', () async {
    final (container, endereco, token) = await appComMcp();
    final pedaleira = container.read(conexaoProvider.notifier).transporte! as TransporteDemonstracao;
    final conteudo = pedaleira.conteudoDoSlot(3)!;
    final porFora = {...conteudo, 'preset': {...conteudo['preset'] as Map<String, dynamic>, 'name': 'Da pedaleira'}};
    pedaleira.substituirSlot(3, porFora);
    await ferramenta(endereco, token, 'set_parameter', {'row': 1, 'column': 1, 'parameter': 'Threshold', 'value': -12});
    container.listen(pedidoSalvarProvider, (_, pedido) => pedido?.responder(true));

    final (erro, motivo) = await ferramenta(endereco, token, 'save_preset');

    expect(erro, isTrue);
    expect(motivo, contains('changed on the pedal'));
    expect(pedaleira.conteudoDoSlot(3)!['preset']['name'], 'Da pedaleira', reason: 'nada vai para o slot');
  });
}
