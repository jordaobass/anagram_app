// Família visual do bloco: decide a cor e a forma da arte própria.
// As 6 categorias do firmware são largas demais para a grade (amp e gabinete
// dividem uma), então a uri e o nome refinam a escolha.
enum FamiliaBloco {
  drive,
  compressor,
  equalizador,
  filtro,
  modulacao,
  delay,
  reverb,
  amplificador,
  gabinete,
  utilitario;

  static FamiliaBloco de({required String uri, required String nome, required String categoria}) {
    final texto = '$uri $nome'.toLowerCase();
    bool tem(List<String> termos) => termos.any(texto.contains);
    if (tem(['cabinet', 'cab '])) return gabinete;
    if (tem(['reverb'])) return reverb;
    if (tem(['delay'])) return delay;
    // o Ignissor é compressor de 3 bandas: fica com os compressores, não
    // com os filtros, embora o firmware o ponha em "EQs, Filters & Dynamics"
    if (tem(['comp', 'suppressor', 'noisegate', 'gate', 'gravitron', 'ignissor'])) return compressor;
    if (tem(['hpf', 'lpf', 'pass filter', 'wah', 'wauwa', 'moerfer'])) return filtro;
    // o Axioma é um synth que segue a nota tocada, como os octavers: fica
    // com a modulação, embora o firmware o ponha em "Utilities" (AX6)
    if (tem(['axioma'])) return modulacao;
    if (tem(['eq', 'geq', 'fil4'])) return equalizador;
    return _porCategoria(categoria);
  }

  static FamiliaBloco _porCategoria(String categoria) {
    final texto = categoria.toLowerCase();
    if (texto.startsWith('amp')) return amplificador;
    if (texto.startsWith('overdrive')) return drive;
    if (texto.startsWith('modulation')) return modulacao;
    if (texto.startsWith('delays')) return delay;
    if (texto.startsWith('eqs')) return equalizador;
    return utilitario;
  }
}
