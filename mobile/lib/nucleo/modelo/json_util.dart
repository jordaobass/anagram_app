// Ajudantes para mexer no JSON cru do preset sem perder campos que o app
// não conhece.
import 'dart:convert';

Map<String, dynamic> copiaProfunda(Map<String, dynamic> origem) =>
    jsonDecode(jsonEncode(origem)) as Map<String, dynamic>;

Map<String, dynamic> mapaOuVazio(Object? valor) =>
    valor is Map<String, dynamic> ? valor : <String, dynamic>{};

/// Chaves "1", "2", … em ordem numérica (as do arquivo podem ter buracos).
List<String> chavesNumericas(Map<String, dynamic> mapa) {
  final chaves = mapa.keys.where((k) => int.tryParse(k) != null).toList();
  chaves.sort((a, b) => int.parse(a).compareTo(int.parse(b)));
  return chaves;
}

/// Próxima chave sem buraco para `parameters`/`properties`.
String proximaChave(Map<String, dynamic> mapa) {
  final chaves = chavesNumericas(mapa);
  return chaves.isEmpty ? '1' : '${int.parse(chaves.last) + 1}';
}

/// Leitura tolerante de campo escalar: tipo inesperado vale como ausente.
String? textoOuNulo(Object? valor) => valor is String ? valor : null;

num? numeroOuNulo(Object? valor) => valor is num ? valor : null;
