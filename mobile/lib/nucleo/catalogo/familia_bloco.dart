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
    if (tem(['comp', 'suppressor', 'noisegate', 'gate', 'gravitron'])) return compressor;
    if (tem(['hpf', 'lpf', 'pass filter', 'wah', 'wauwa', 'moerfer', 'ignissor'])) return filtro;
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

  String get rotulo => switch (this) {
        drive => 'Drive',
        compressor => 'Dinâmica',
        equalizador => 'EQ',
        filtro => 'Filtro',
        modulacao => 'Modulação',
        delay => 'Delay',
        reverb => 'Reverb',
        amplificador => 'Amp',
        gabinete => 'Gabinete',
        utilitario => 'Utilitário',
      };
}
