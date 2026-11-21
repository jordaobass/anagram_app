// Versão semântica (X.Y.Z) para saber se a release publicada é mais nova que
// a do app aberto. Comparar texto erraria: "0.1.9" > "0.1.10" na ordem
// alfabética. Prerelease ("-beta") e lixo não contam como versão publicada.

class VersaoSemantica implements Comparable<VersaoSemantica> {
  const VersaoSemantica(this.maior, this.menor, this.correcao);

  final int maior;
  final int menor;
  final int correcao;

  static final _formato = RegExp(r'^[vV]?(\d+)\.(\d+)\.(\d+)(\+[0-9A-Za-z.-]+)?$');

  /// Aceita "1.2.3", "v1.2.3" e "1.2.3+18" (o número de build não conta);
  /// `null` para prerelease ou texto fora do formato.
  static VersaoSemantica? ler(String texto) {
    final partes = _formato.firstMatch(texto);
    if (partes == null) return null;
    final numeros = [for (var grupo = 1; grupo <= 3; grupo++) int.parse(partes.group(grupo)!)];
    return VersaoSemantica(numeros[0], numeros[1], numeros[2]);
  }

  @override
  int compareTo(VersaoSemantica outra) {
    if (maior != outra.maior) return maior.compareTo(outra.maior);
    if (menor != outra.menor) return menor.compareTo(outra.menor);
    return correcao.compareTo(outra.correcao);
  }

  @override
  String toString() => '$maior.$menor.$correcao';
}

/// Só avisa de versão estável e estritamente maior; qualquer uma inválida = não.
bool ehMaisNova(String candidata, String atual) {
  final nova = VersaoSemantica.ler(candidata);
  final aberta = VersaoSemantica.ler(atual);
  return nova != null && aberta != null && nova.compareTo(aberta) > 0;
}
