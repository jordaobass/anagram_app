// Blocos do Marketplace (DECISOES P4): a pedaleira de demonstração tem um
// plugin fictício instalado, o "Nebula Synth (demo)", que não está no
// catálogo de fábrica. Relato de usuário: o Macrosynth instalado na Anagram
// não era reconhecido pelo app (aparecia com faixa estimada e não entrava na
// lista de adicionar).
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/demonstracao/plugins_demonstracao.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:anagram_app/nucleo/protocolo/api_anagram.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/app_com_mcp.dart';

Map<String, dynamic> _presetCom(String uri) => {
      'type': 'preset',
      'version': 1,
      'preset': {
        'name': 'Com Nebula',
        'bindings': <String, dynamic>{},
        'scene': 0,
        'chains': {
          '1': {
            'blocks': {
              '1': {
                'uri': uri,
                'enabled': true,
                'parameters': {
                  '1': {'name': 'Cutoff', 'symbol': 'cutoff', 'value': 800},
                },
                'properties': <String, dynamic>{},
                'scenes': <String, dynamic>{},
              },
            },
          },
        },
      },
    };

Map<String, dynamic> _parametro(Object? bloco, String simbolo) =>
    ((bloco! as Map)['parameters'] as List).firstWhere((p) => p['symbol'] == simbolo) as Map<String, dynamic>;

void main() {
  test('should_offer_the_installed_marketplace_block_to_the_ai_with_its_real_parameters', () async {
    final (_, endereco, token) = await appComMcp();

    final (_, tipos) = await ferramenta(endereco, token, 'list_block_types', {'search': 'nebula'});
    expect('$tipos', contains(uriNebulaDemonstracao), reason: 'o plugin instalado entra na lista');
    final (erro, bloco) = await ferramenta(endereco, token, 'add_block', {'row': 1, 'column': 5, 'type': uriNebulaDemonstracao});

    expect(erro, isFalse, reason: '$bloco');
    expect((bloco! as Map)['name'], 'Nebula Synth (demo)');
    expect(_parametro(bloco, 'cutoff'), allOf(containsPair('min', 20), containsPair('max', 20000)));
    expect(_parametro(bloco, 'wave')['options'], ['Saw', 'Square', 'Sine']);
  });

  test('should_ask_the_pedal_once_for_a_block_outside_the_catalog_when_a_preset_uses_it', () async {
    final (container, endereco, token) = await appComMcp();
    final pedaleira = pedaleiraDe(container)
      ..semListaDePlugins = true
      ..substituirSlot(3, _presetCom(uriNebulaDemonstracao));
    final editor = container.read(editorProvider.notifier);
    await ferramenta(endereco, token, 'get_current_preset'); // a IA já estava ali antes

    await editor.abrirSlot(SlotPreset.doRotulo('02A'));
    await editor.abrirSlot(SlotPreset.doRotulo('01C'));
    await editor.abrirSlot(SlotPreset.doRotulo('02A'));
    await editor.abrirSlot(SlotPreset.doRotulo('01C'));
    final (_, lido) = await ferramenta(endereco, token, 'get_current_preset');

    final bloco = ((lido! as Map)['rows']['1'] as List).first;
    expect((bloco as Map)['name'], 'Nebula Synth (demo)', reason: 'a definição veio da pedaleira');
    expect(_parametro(bloco, 'cutoff'), allOf(containsPair('min', 20), containsPair('max', 20000)),
        reason: 'faixa real, não estimada');
    final pedidos = pedaleira.comandosRecebidos.where((c) => c.acao == AcoesAnagram.infoBloco).toList();
    expect([for (final p in pedidos) p.carga['uri']], [uriNebulaDemonstracao], reason: 'um pedido por conexão');
  });
}
