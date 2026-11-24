// A IA montando um preset do zero num slot vazio, pelo servidor MCP de verdade
// com a pedaleira de demonstração: open_slot num slot vazio abre um preset
// novo com aquele slot como destino, como o botão "Criar preset aqui" da tela;
// add_block monta a cadeia e save_preset (confirmado pela pessoa) grava ali.
import 'package:anagram_app/aplicacao/mcp/avisos_mcp.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/modelo/documento_preset.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/app_com_mcp.dart';

void main() {
  test('should_build_and_save_a_new_preset_in_an_empty_slot_opened_by_the_ai', () async {
    final (container, endereco, token) = await appComMcp();
    final pedaleira = pedaleiraDe(container);
    final numero = SlotPreset.doRotulo('03C').numero;
    expect(pedaleira.conteudoDoSlot(numero), isNull, reason: 'o 03C da demonstração é vazio');

    final (erroAbrir, aberto) = await ferramenta(endereco, token, 'open_slot', {'slot': '03C', 'new_preset_name': 'Da IA'});
    expect(erroAbrir, isFalse, reason: '$aberto');
    expect((aberto! as Map)['new_preset'], isTrue);
    expect((aberto as Map)['preset']['name'], 'Da IA');
    final (erroBloco, bloco) =
        await ferramenta(endereco, token, 'add_block', {'row': 1, 'column': 1, 'type': 'urn:darkglass:CompLim'});
    expect(erroBloco, isFalse, reason: '$bloco');
    container.listen(pedidoSalvarProvider, (_, pedido) => pedido?.responder(true));
    final (erroSalvar, salvo) = await ferramenta(endereco, token, 'save_preset');

    expect(erroSalvar, isFalse, reason: '$salvo');
    expect((salvo! as Map)['saved_to'], '03C');
    final gravado = DocumentoPreset.doJson(pedaleira.conteudoDoSlot(numero)!);
    expect(gravado.nome, 'Da IA');
    expect([for (final b in gravado.blocosDaLinha(1)) b.uri], ['urn:darkglass:CompLim']);
    expect(gravado.uuid, isNotNull, reason: 'preset novo nasce com id próprio, como na tela');
    expect(container.read(editorProvider).slot?.rotulo, '03C');
  });

  test('should_name_the_new_preset_in_the_app_language_when_the_ai_gives_no_name', () async {
    final (_, endereco, token) = await appComMcp();

    final (_, aberto) = await ferramenta(endereco, token, 'open_slot', {'slot': '03C'});

    expect((aberto! as Map)['preset']['name'], isNotEmpty);
  });
}
