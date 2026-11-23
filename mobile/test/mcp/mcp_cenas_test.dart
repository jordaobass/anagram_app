// A IA ajustando um parâmetro numa cena pelo servidor MCP de verdade, com a
// pedaleira de demonstração: o que muda tem de soar e ficar só onde a IA
// pediu. Caso real da bancada: Blend do B3K mudado na cena 2 aparecia nas
// cenas 1 e 3 (DECISOES IM1, IM2).
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/aplicacao/estado/escopo_cenas.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:anagram_app/nucleo/modelo/cenas_do_bloco.dart';
import 'package:anagram_app/nucleo/modelo/json_util.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/app_com_mcp.dart';

const _b3k = PosicaoBloco(1, 4);
const _geq = PosicaoBloco(1, 4);

/// O valor que a pedaleira de demonstração está tocando no bloco [posicao].
num? _tocando(ProviderContainer container, PosicaoBloco posicao, String simbolo) {
  final preset = pedaleiraDe(container).presetTocando!['preset'] as Map<String, dynamic>;
  final bloco = mapaOuVazio(mapaOuVazio(mapaOuVazio(preset['chains'])['${posicao.linha}'])['blocks'])['${posicao.casa}'];
  return BlocoPreset(posicao, bloco as Map<String, dynamic>).valorBase(simbolo);
}

num? _naCena(ProviderContainer container, PosicaoBloco posicao, String simbolo, int cena) =>
    container.read(editorProvider).atual!.bloco(posicao)!.valorNaCena(simbolo, cena);

void main() {
  group('set_parameter por cena', () {
    test('should_keep_scenes_1_and_3_when_the_ai_changes_the_b3k_blend_only_in_scene_2', () async {
      final (container, endereco, token) = await appComMcp(slot: '03A');
      final original = _naCena(container, _b3k, 'Blend', 1);
      await ferramenta(endereco, token, 'select_scene', {'scene': 2});

      final (erro, resposta) = await ferramenta(endereco, token, 'set_parameter',
          {'row': 1, 'column': 4, 'parameter': 'Blend', 'value': 80, 'scope': 'scene'});

      expect(erro, isFalse, reason: '$resposta');
      expect((resposta! as Map)['scope'], 'scene');
      expect(_tocando(container, _b3k, 'Blend'), 80, reason: 'a cena 2 soa com o valor novo');
      for (final cena in const [1, 3]) {
        await ferramenta(endereco, token, 'select_scene', {'scene': cena});
        final (_, lido) = await ferramenta(endereco, token, 'get_current_preset');
        final bloco = ((lido! as Map)['rows']['1'] as List).firstWhere((b) => b['column'] == 4) as Map;
        expect((bloco['parameters'] as List).firstWhere((p) => p['symbol'] == 'Blend')['value'], original,
            reason: 'a cena $cena não muda');
        expect(_tocando(container, _b3k, 'Blend'), original, reason: 'a pedaleira toca a cena $cena como era');
      }
      await ferramenta(endereco, token, 'select_scene', {'scene': 2});
      expect(_tocando(container, _b3k, 'Blend'), 80, reason: 'voltar à cena 2 traz o valor dela');
      expect(container.read(editorProvider).naoSalvo, isTrue);
    });

    test('should_set_the_value_in_every_scene_when_the_scope_is_all_scenes', () async {
      final (container, endereco, token) = await appComMcp(slot: '03A');
      // a cena 2 já tem Blend próprio (como deixaria o "só na cena")
      final editor = container.read(editorProvider.notifier);
      await editor.escolherCena(2);
      await editor.aplicarDocumento(container
          .read(editorProvider)
          .atual!
          .comParametro(_b3k, 'Blend', 80, escopo: EscopoCenas.soNaCena));
      await ferramenta(endereco, token, 'select_scene', {'scene': 1});

      final (erro, resposta) = await ferramenta(endereco, token, 'set_parameter',
          {'row': 1, 'column': 4, 'parameter': 'Blend', 'value': 20, 'scope': 'all_scenes'});

      expect(erro, isFalse, reason: '$resposta');
      expect([for (final cena in const [1, 2, 3]) _naCena(container, _b3k, 'Blend', cena)], [20, 20, 20]);
    });

    test('should_follow_the_app_control_switch_when_the_ai_sends_no_scope', () async {
      final (container, endereco, token) = await appComMcp();
      await ferramenta(endereco, token, 'select_scene', {'scene': 2});

      final (_, soAtiva) = await ferramenta(endereco, token, 'set_parameter',
          {'row': 1, 'column': 4, 'parameter': 'LowShelf', 'value': 4});
      expect((soAtiva! as Map)['scope'], 'scene', reason: 'padrão da tela: só a cena ativa (DECISOES CE1)');
      expect(_naCena(container, _geq, 'LowShelf', 1), isNot(4));

      container.read(escopoCenasProvider.notifier).definir(EscopoCenas.todasAsCenas);
      final (erro, todas) = await ferramenta(endereco, token, 'set_parameter',
          {'row': 1, 'column': 4, 'parameter': 'LowShelf', 'value': 5});

      expect(erro, isFalse, reason: '$todas');
      expect((todas! as Map)['scope'], 'all_scenes', reason: 'a IA fica sabendo onde a mudança valeu');
      expect([for (final cena in const [1, 2, 3]) _naCena(container, _geq, 'LowShelf', cena)], [5, 5, 5]);
    });

    test('should_switch_the_block_off_in_every_scene_when_the_ai_asks_for_all_scenes', () async {
      final (container, endereco, token) = await appComMcp();
      await ferramenta(endereco, token, 'select_scene', {'scene': 2});

      final (erro, resposta) = await ferramenta(endereco, token, 'set_block_enabled',
          {'row': 1, 'column': 4, 'enabled': false, 'scope': 'all_scenes'});

      expect(erro, isFalse, reason: '$resposta');
      final bloco = container.read(editorProvider).atual!.bloco(_geq)!;
      expect([for (final cena in const [1, 2, 3]) bloco.habilitadoNaCena(cena)], [false, false, false]);
    });
  });
}
