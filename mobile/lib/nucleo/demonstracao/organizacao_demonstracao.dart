// Trocas de lugar na pedaleira de demonstração, como a Anagram faz com
// `swap_anagram_presets` e `swap_anagram_banks`: os índices são o número do
// slot (1–126) e trocar com um slot vazio é mover.

/// Troca os conteúdos dos slots [de] e [para] (um deles pode estar vazio).
Map<String, dynamic> trocarSlots(Map<int, dynamic> slots, Object? de, Object? para) {
  if (de is! int || para is! int) return {'error': 'Índices de slot inválidos.'};
  final origem = slots.remove(de);
  final destino = slots.remove(para);
  if (origem != null) slots[para] = origem;
  if (destino != null) slots[de] = destino;
  return {'status': 'ok'};
}

/// Troca bancos inteiros: [pares] traz um `{fromIndex, toIndex}` por letra.
Map<String, dynamic> trocarBancosDeSlots(Map<int, dynamic> slots, Object? pares) {
  if (pares is! List) return {'error': 'Faltam as posições dos bancos.'};
  for (final par in pares.whereType<Map<String, dynamic>>()) {
    final troca = trocarSlots(slots, par['fromIndex'], par['toIndex']);
    if (troca.containsKey('error')) return troca;
  }
  return {'status': 'ok'};
}
