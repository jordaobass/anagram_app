// Trocar de cena é tocar, não editar: o undo da IA e o DESFAZER da tela pulam
// a troca e voltam a última edição de verdade, ficando na cena em que a
// pessoa está. Antes o undo da IA desfazia o select_scene, e o DESFAZER da
// tela era recusado depois de uma troca de cena (o preset "não era mais o
// que a mudança deixou").
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/modelo/cenas_do_bloco.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/app_com_mcp.dart';
import '../apoio/conexao_demo.dart';

const _b3k = PosicaoBloco(1, 4);

num? _blend(ProviderContainer container, int cena) =>
    container.read(editorProvider).atual!.bloco(_b3k)!.valorNaCena('Blend', cena);

void main() {
  test('should_undo_the_ai_parameter_change_and_stay_in_the_scene_it_switched_to', () async {
    final (container, endereco, token) = await appComMcp(slot: '03A');
    final original = _blend(container, 1);
    await ferramenta(endereco, token, 'set_parameter',
        {'row': 1, 'column': 4, 'parameter': 'Blend', 'value': 80, 'scope': 'scene'});
    await ferramenta(endereco, token, 'select_scene', {'scene': 2});

    final (erro, resposta) = await ferramenta(endereco, token, 'undo');

    expect(erro, isFalse, reason: '$resposta');
    expect((resposta! as Map)['remaining_undo_steps'], 0, reason: 'a troca de cena não conta como passo');
    expect(_blend(container, 1), original, reason: 'o Blend da cena 1 volta');
    expect(container.read(editorProvider).atual!.cenaAtiva, 2, reason: 'a pessoa continua na cena 2');
    expect(container.read(editorProvider).naoSalvo, isFalse);
  });

  test('should_undo_the_knob_from_the_screen_after_switching_scene', () async {
    final (container, _) = await conectarDemonstracao();
    final editor = container.read(editorProvider.notifier);
    await editor.abrirSlot(SlotPreset.doRotulo('03A'));
    final original = _blend(container, 1);
    final ponto = await editor.comDesfazer(() => editor.aplicarDocumento(
        container.read(editorProvider).atual!.comParametro(_b3k, 'Blend', 80, escopo: EscopoCenas.soNaCena)));
    await editor.escolherCena(3);

    expect(await editor.desfazer(ponto!), isTrue, reason: 'trocar de cena não é edição da pessoa');

    expect(_blend(container, 1), original);
    expect(container.read(editorProvider).atual!.cenaAtiva, 3);
  });
}
