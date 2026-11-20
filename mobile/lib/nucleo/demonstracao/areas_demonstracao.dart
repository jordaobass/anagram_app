// Áreas da pedaleira de demonstração, como uma Anagram com firmware 1.18+:
// a padrão (os presets de sempre), "Estudo" e "User2", cada uma com presets
// próprios. Os das outras áreas são cópias renomeadas, com uuid novo, para
// a troca de área mostrar outra lista de verdade.
import 'dart:convert';

abstract final class AreasDemonstracao {
  static const nomes = ['Padrão', 'Estudo', 'User2'];

  /// Presets por id de área, além da "user" (que fica com [base]).
  static Map<String, Map<int, Map<String, dynamic>>> outras(Map<int, Map<String, dynamic>> base) {
    final ordem = base.keys.toList()..sort();
    Map<String, dynamic>? modelo(int i) => ordem.length > i ? base[ordem[i]] : null;
    return {
      'user-2': _area({1: (modelo(0), 'Escalas lentas'), 2: (modelo(1), 'Slap devagar'), 4: (modelo(2), 'Groove 70 bpm')}, 2),
      'user-3': _area({1: (modelo(1), 'Show sábado'), 3: (modelo(0), 'Ensaio banda')}, 3),
    };
  }

  static Map<int, Map<String, dynamic>> _area(Map<int, (Map<String, dynamic>?, String)> slots, int area) => {
        for (final MapEntry(key: numero, value: (modelo, nome)) in slots.entries)
          if (modelo != null) numero: _renomeado(modelo, nome, area * 1000 + numero),
      };

  static Map<String, dynamic> _renomeado(Map<String, dynamic> modelo, String nome, int marca) {
    final copia = jsonDecode(jsonEncode(modelo)) as Map<String, dynamic>;
    final preset = copia['preset'] as Map<String, dynamic>;
    preset['name'] = nome;
    // uuid próprio: a lista confere o id do slot com o do preset lido
    preset['uuid'] = '00000000-0000-4000-8000-${marca.toString().padLeft(12, '0')}';
    return copia;
  }
}
