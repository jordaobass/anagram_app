// Os ajustes globais da pedaleira de demonstração, no mesmo formato plano
// que a Anagram v1.19.2.24 exporta (lido da pedaleira real em 2026-11-21):
// mixer, Global EQ, ganho de entrada e a placa de som, que só se lê.

/// Valores de partida: os da pedaleira real naquele dia, para a demonstração
/// mostrar uma curva de EQ que não seja plana.
Map<String, Object?> ajustesGlobaisIniciais() => {
      'mixer.headphones.vol': 6.0,
      'mixer.jack.left.vol': 0.0,
      'mixer.jack.right.vol': 0.0,
      'mixer.speaker.vol': 0.0,
      'mixer.xlr.left.vol': 0.0,
      'mixer.xlr.right.vol': 0.0,
      'globaleq.ls.freq': 40.5,
      'globaleq.ls.gain': -3.0,
      'globaleq.hs.freq': 9630.0,
      'globaleq.hs.gain': -4.6,
      'input-gain-preset0.db': 0,
      'mode': 'stomp',
      'scene-mode': 'all',
    };

Map<String, Object?> placaDeSomInicial() => {
      'Headphone Gain': 2,
      'XLR Ground Lift': 0,
      'Capture Ground Lift': 0,
      'Analog CH3 Mic Gain': 0,
      'Analog CH4 Mic Gain': 0,
      'FX/Exp': 0,
    };

/// Aplica um `edit_settings`: chaves planas viram valores; `selected-preset-area`
/// fica com quem cuida das áreas.
void gravarAjustesGlobais(Map<String, Object?> ajustes, Map<String, dynamic> pedido) {
  pedido.forEach((chave, valor) {
    if (chave != 'selected-preset-area') ajustes[chave] = valor;
  });
}
