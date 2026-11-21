// Áreas de presets do usuário (firmware 1.18+): até 127 conjuntos de 126
// slots, cada um com nome dado pela pessoa ("Estudo", "User2"…). Os ids são
// os que a pedaleira usa no campo `userArea`: a primeira área é "user" e a
// área na posição i (contando de 1) é "user-i" — formato conferido no
// Darkglass Suite 6.11.4 (DECISOES, U10).
import 'json_util.dart';

class AreaPresets {
  const AreaPresets(this.id, this.nome);

  final String id;

  /// O nome dado na pedaleira; vazio quando a pessoa não deu nenhum (a tela
  /// mostra "Área N" no idioma em uso).
  final String nome;

  /// Posição da área, contando de 1, tirada do id ("user" = 1, "user-3" = 3).
  int get numero => id == 'user' ? 1 : int.tryParse(id.split('-').last) ?? 1;

  @override
  bool operator ==(Object other) => other is AreaPresets && other.id == id && other.nome == nome;

  @override
  int get hashCode => Object.hash(id, nome);
}

class AreasDaPedaleira {
  const AreasDaPedaleira(this.areas, {required this.ativa});

  /// Firmware sem áreas: uma só, e os comandos vão sem `userArea`.
  const AreasDaPedaleira.unica()
      : areas = const [],
        ativa = null;

  final List<AreaPresets> areas;

  /// Id da área que a pedaleira está usando agora (a dos footswitches e do
  /// Program Change). Nulo quando o firmware não tem áreas ou quando os
  /// ajustes não dizem qual é: aí ela é desconhecida, nunca suposta.
  final String? ativa;

  bool get temAreas => areas.isNotEmpty;

  AreaPresets? area(String? id) => areas.where((a) => a.id == id).firstOrNull;

  /// Lê o `settings` devolvido por `export_settings`. Sem "user-areas" (ou
  /// lista vazia) é firmware anterior às áreas. Uma "selected-preset-area"
  /// ausente ou fora da lista deixa a ativa desconhecida: supor a primeira
  /// faria o Program Change trocar o slot da área errada.
  factory AreasDaPedaleira.dosAjustes(Map<String, dynamic> ajustes) {
    final nomes = ajustes['user-areas'];
    if (nomes is! List || nomes.isEmpty) return const AreasDaPedaleira.unica();
    final areas = [
      for (var i = 0; i < nomes.length; i++) AreaPresets(idDaArea(i), _nome(nomes[i])),
    ];
    final ativa = textoOuNulo(ajustes['selected-preset-area']);
    return AreasDaPedaleira(areas, ativa: areas.any((a) => a.id == ativa) ? ativa : null);
  }

  /// Posição 0 é "user"; as outras, "user-2", "user-3"… como no Suite.
  static String idDaArea(int posicao) => posicao == 0 ? 'user' : 'user-${posicao + 1}';

  static String _nome(Object? nome) => textoOuNulo(nome)?.trim() ?? '';
}
