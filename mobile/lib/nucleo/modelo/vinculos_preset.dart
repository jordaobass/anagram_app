// Pots, footswitches e pedal de expressão (`bindings`) apontam para os blocos
// pela posição (`row` + `block`), não por um id. Quando um bloco muda de casa,
// o controle tem de ir junto, senão passa a mexer no bloco que ficou ali.
import 'bloco_preset.dart';
import 'json_util.dart';

/// Troca as referências de [a] e [b] em todos os controles do preset (cru).
/// Com [b] vazia, é só a mudança de [a] para [b].
void trocarVinculos(Map<String, dynamic> preset, PosicaoBloco a, PosicaoBloco b) {
  for (final controle in mapaOuVazio(preset['bindings']).values) {
    final alvos = mapaOuVazio(controle)['parameters'];
    if (alvos is! List) continue;
    for (final alvo in alvos.whereType<Map<String, dynamic>>()) {
      final posicao = _posicaoDe(alvo);
      final nova = posicao == a ? b : (posicao == b ? a : null);
      if (nova == null) continue;
      alvo['row'] = nova.linha;
      alvo['block'] = nova.casa;
    }
  }
}

/// Solta os controles que apontavam para [posicao] (bloco removido). O
/// controle sem nenhum alvo sai do preset, como nos presets que a pedaleira
/// grava (nenhum exemplo real tem controle com lista vazia).
void soltarVinculos(Map<String, dynamic> preset, PosicaoBloco posicao) {
  final controles = mapaOuVazio(preset['bindings']);
  final vazios = <String>[];
  for (final MapEntry(:key, :value) in controles.entries) {
    final alvos = mapaOuVazio(value)['parameters'];
    if (alvos is! List) continue;
    alvos.removeWhere((alvo) => alvo is Map<String, dynamic> && _posicaoDe(alvo) == posicao);
    if (alvos.isEmpty) vazios.add(key);
  }
  vazios.forEach(controles.remove);
}

PosicaoBloco _posicaoDe(Map<String, dynamic> alvo) =>
    PosicaoBloco(numeroOuNulo(alvo['row'])?.toInt() ?? 0, numeroOuNulo(alvo['block'])?.toInt() ?? 0);

