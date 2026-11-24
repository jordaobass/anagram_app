// A IA atribuindo e soltando footswitches, pots e pedal de expressão pelo
// servidor MCP de verdade, com a pedaleira de demonstração: as mesmas
// operações da seção Controles da tela, ao vivo (DECISOES IM4).
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:anagram_app/nucleo/modelo/controles_pedaleira.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/app_com_mcp.dart';

const _geq = PosicaoBloco(1, 4);
const _compressor = PosicaoBloco(1, 1);

void main() {
  group('controles da pedaleira', () {
    test('should_assign_a_pot_with_range_and_name_and_a_footswitch_and_read_them_back', () async {
      final (container, endereco, token) = await appComMcp();
      final enviosAntes = pedaleiraDe(container).presetTocando;

      final (erroPot, pot) = await ferramenta(endereco, token, 'assign_control', {
        'control': 'pot1', 'row': 1, 'column': 4, 'parameter': 'LowShelf', 'min': -6, 'max': 6, 'name': 'Graves',
      });
      final (erroFoot, foot) =
          await ferramenta(endereco, token, 'assign_control', {'control': 'foot1', 'row': 1, 'column': 1});
      final (erroLer, lidos) = await ferramenta(endereco, token, 'get_controls');

      expect([erroPot, erroFoot, erroLer], everyElement(isFalse), reason: '$pot $foot $lidos');
      final controles = container.read(editorProvider).atual!.controles;
      expect(controles[IdControle.pot1]!.nome, 'Graves');
      final alvo = controles[IdControle.pot1]!.alvos.single;
      expect((alvo.posicao, alvo.simbolo, alvo.minimo, alvo.maximo), (_geq, 'LowShelf', -6, 6));
      expect(controles[IdControle.foot1]!.alvos.single.mesmoParametro(_compressor, simboloBypass), isTrue);
      expect(pedaleiraDe(container).presetTocando!['preset']['bindings']['pot1'], isNotNull,
          reason: 'vai ao vivo, como a seção Controles da tela');
      expect(identical(pedaleiraDe(container).presetTocando, enviosAntes), isFalse);
      expect(container.read(editorProvider).naoSalvo, isTrue);
      final lista = ((lidos! as Map)['controls'] as List).cast<Map<String, dynamic>>();
      expect(lista.map((c) => c['control']), containsAll(['foot1', 'foot2', 'foot3', 'pot1', 'pot6', 'exp']));
      final lidoPot = lista.firstWhere((c) => c['control'] == 'pot1');
      expect(lidoPot['name'], 'Graves');
      expect((lidoPot['targets'] as List).single, containsPair('parameter', 'LowShelf'));
      expect(lista.firstWhere((c) => c['control'] == 'foot1')['targets'].single['parameter'], 'bypass');
      expect(lista.firstWhere((c) => c['control'] == 'pot2')['assigned'], isFalse);
    });

    test('should_refuse_a_parameter_on_a_footswitch_and_a_range_outside_the_parameter_changing_nothing', () async {
      final (container, endereco, token) = await appComMcp();
      final antes = container.read(editorProvider).atual;

      final (erroFoot, motivoFoot) = await ferramenta(endereco, token, 'assign_control',
          {'control': 'foot2', 'row': 1, 'column': 4, 'parameter': 'LowShelf'});
      final (erroFaixa, motivoFaixa) = await ferramenta(endereco, token, 'assign_control',
          {'control': 'pot1', 'row': 1, 'column': 4, 'parameter': 'LowShelf', 'min': -500, 'max': 6});

      expect((erroFoot, erroFaixa), (true, true));
      expect(motivoFoot, contains('on/off'));
      expect(motivoFaixa, contains('range'));
      expect(identical(container.read(editorProvider).atual, antes), isTrue, reason: 'recusa não muda nada');
    });

    test('should_release_one_target_or_the_whole_control', () async {
      final (container, endereco, token) = await appComMcp();
      await ferramenta(endereco, token, 'assign_control', {'control': 'pot1', 'row': 1, 'column': 4, 'parameter': 'LowShelf'});
      await ferramenta(endereco, token, 'assign_control', {'control': 'pot1', 'row': 1, 'column': 4, 'parameter': 'S250Hz'});
      await ferramenta(endereco, token, 'assign_control', {'control': 'foot1', 'row': 1, 'column': 1});

      final (erroAlvo, _) = await ferramenta(endereco, token, 'release_control', {'control': 'pot1', 'target_index': 0});
      final (erroTudo, _) = await ferramenta(endereco, token, 'release_control', {'control': 'foot1'});

      expect((erroAlvo, erroTudo), (false, false));
      final controles = container.read(editorProvider).atual!.controles;
      expect(controles[IdControle.pot1]!.alvos.single.simbolo, 'S250Hz');
      expect(controles.containsKey(IdControle.foot1), isFalse);
      expect(pedaleiraDe(container).presetTocando!['preset']['bindings'].containsKey('foot1'), isFalse);
    });
  });
}
