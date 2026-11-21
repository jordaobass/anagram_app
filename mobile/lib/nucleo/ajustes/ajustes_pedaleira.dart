// O que `export_settings` devolveu: `settings` é um mapa PLANO com chaves de
// pontos (`mixer.headphones.vol`), provado na Anagram v1.19.2.24. Se algum
// firmware mandar aninhado, achatamos para a mesma forma. `soundcard` é só
// leitura: a pedaleira não responde a gravações nele (DECISOES PD1).
import 'mapa_ajustes.dart';

class AjustesPedaleira {
  const AjustesPedaleira({this.ajustes = const {}, this.placa = const {}});

  /// Da resposta crua (com ou sem `data` em volta).
  factory AjustesPedaleira.daResposta(Map<String, dynamic> resposta) {
    final dados = resposta['data'];
    final corpo = resposta['settings'] is Map || dados is! Map ? resposta : dados;
    return AjustesPedaleira(ajustes: achatar(corpo['settings']), placa: achatar(corpo['soundcard']));
  }

  final Map<String, Object?> ajustes;
  final Map<String, Object?> placa;

  num? valor(DefinicaoAjuste definicao) {
    final chave = definicao.chave;
    final valor = chave == null ? null : ajustes[chave];
    return valor is num ? valor : null;
  }
}

/// `{"mixer": {"headphones": {"vol": 6}}}` e `{"mixer.headphones.vol": 6}`
/// viram a mesma coisa.
Map<String, Object?> achatar(Object? mapa, [String prefixo = '']) {
  if (mapa is! Map) return const {};
  final saida = <String, Object?>{};
  mapa.forEach((chave, valor) {
    final nome = prefixo.isEmpty ? '$chave' : '$prefixo.$chave';
    if (valor is Map) {
      saida.addAll(achatar(valor, nome));
    } else {
      saida[nome] = valor;
    }
  });
  return saida;
}
