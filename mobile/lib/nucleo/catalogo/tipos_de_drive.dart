// O Drive TypeMode do Entropia é um parâmetro só, com 37 opções ("Bypass",
// "B3K Flat"… "Omega Turbo Both"). A pedaleira o apresenta em DOIS seletores
// — tipo (B3K, VMT, Alpha, Omega, Chinchilla e as versões Turbo) e modo
// (Flat, Grunt, Midboost, Both…) — e o app faz o mesmo. Tipo e modo saem dos
// próprios rótulos do catálogo: o tipo vai até "Turbo" (inclusive) ou é a
// primeira palavra; o modo é o resto. O valor gravado continua o índice.

class TiposDeDrive {
  TiposDeDrive(List<String> opcoes) : _partes = [for (final o in opcoes) _separar(o)];

  final List<(String, String?)> _partes;

  /// Os tipos na ordem do catálogo (o primeiro é "Bypass", sem modo).
  List<String> get tipos => [
        for (final (tipo, _) in _partes) tipo,
      ].fold<List<String>>([], (lista, tipo) => lista.contains(tipo) ? lista : [...lista, tipo]);

  /// Os modos de um tipo, na ordem do catálogo; vazio para "Bypass".
  List<String> modos(String tipo) => [
        for (final (t, modo) in _partes)
          if (t == tipo && modo != null) modo,
      ];

  (String, String?) doIndice(int indice) => _partes[indice.clamp(0, _partes.length - 1)];

  int? indice(String tipo, String? modo) {
    final i = _partes.indexWhere((p) => p.$1 == tipo && p.$2 == modo);
    return i < 0 ? null : i;
  }

  /// Trocar o tipo mantém o modo se o tipo novo o tiver ("Grunt" de B3K
  /// para B3K Turbo); senão fica o primeiro modo dele.
  int trocarTipo(int atual, String novoTipo) {
    final (_, modo) = doIndice(atual);
    final modos = this.modos(novoTipo);
    return indice(novoTipo, modos.contains(modo) ? modo : modos.firstOrNull)!;
  }

  static (String, String?) _separar(String opcao) {
    final palavras = opcao.split(' ');
    final turbo = palavras.indexOf('Turbo');
    final corte = turbo > 0 ? turbo + 1 : 1;
    final modo = palavras.skip(corte).join(' ');
    return (palavras.take(corte).join(' '), modo.isEmpty ? null : modo);
  }
}
