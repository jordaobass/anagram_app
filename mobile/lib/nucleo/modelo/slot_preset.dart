// Endereço de um preset: 126 slots, 3 por banco (01A … 42C). O nome do
// arquivo na pedaleira é o número do slot: 17A = 49.json.
class SlotPreset implements Comparable<SlotPreset> {
  const SlotPreset._(this.numero);

  static const int total = 126;
  static const int porBanco = 3;
  static const int bancos = total ~/ porBanco;
  static const String _letras = 'ABC';

  factory SlotPreset(int numero) {
    if (numero < 1 || numero > total) {
      throw RangeError.range(numero, 1, total, 'numero', 'Slot fora de 1–$total');
    }
    return SlotPreset._(numero);
  }

  /// "49.json" → slot 49.
  factory SlotPreset.doArquivo(String arquivo) =>
      SlotPreset(int.parse(arquivo.split('.').first));

  /// "17A" → slot 49.
  factory SlotPreset.doRotulo(String rotulo) {
    final texto = rotulo.trim().toUpperCase();
    final banco = int.tryParse(texto.substring(0, texto.length - 1));
    final letra = _letras.indexOf(texto.substring(texto.length - 1));
    if (banco == null || letra < 0 || banco < 1 || banco > bancos) {
      throw FormatException('"$rotulo" não é um slot como 17A.');
    }
    return SlotPreset((banco - 1) * porBanco + letra + 1);
  }

  static List<SlotPreset> todos() => List.generate(total, (i) => SlotPreset(i + 1));

  final int numero;

  int get banco => (numero - 1) ~/ porBanco + 1;
  String get letra => _letras[(numero - 1) % porBanco];
  String get rotulo => '${banco.toString().padLeft(2, '0')}$letra';
  String get arquivo => '$numero.json';

  @override
  int compareTo(SlotPreset outro) => numero.compareTo(outro.numero);

  @override
  bool operator ==(Object other) => other is SlotPreset && other.numero == numero;

  @override
  int get hashCode => numero.hashCode;

  @override
  String toString() => rotulo;
}

/// Uma linha da lista de presets do aparelho.
class ResumoSlot {
  const ResumoSlot({required this.slot, required this.nome, this.id});
  final SlotPreset slot;
  final String nome;
  final String? id;
}
