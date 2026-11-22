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
      // as 6 bandas do Global EQ como a pedaleira real exportou (2026-11-21):
      // médios no padrão de fábrica, grave e agudo cortados com width 4
      ..._bandaEq('ls', 35, -7.8, 4.0),
      ..._bandaEq('1', 160, 0, 0.5),
      ..._bandaEq('2', 397, 0, 0.5),
      ..._bandaEq('3', 1250, 0, 0.5),
      ..._bandaEq('4', 2500, 0, 0.5),
      ..._bandaEq('hs', 8000, -6.8, 4.0),
      'input-gain-preset0.db': 0,
      'mode': 'stomp',
      'scene-mode': 'all',
    };

Map<String, Object?> _bandaEq(String codigo, num freq, num gain, num width) => {
      'globaleq.$codigo.freq': freq,
      'globaleq.$codigo.gain': gain,
      'globaleq.$codigo.width': width,
    };

Map<String, Object?> placaDeSomInicial() => {
      'Headphone Gain': 2,
      'XLR Ground Lift': 0,
      'Capture Ground Lift': 0,
      'Analog CH3 Mic Gain': 0,
      'Analog CH4 Mic Gain': 0,
      'FX/Exp': 0,
    };

/// Guarda um `edit_settings` como a Anagram real: o valor volta na releitura.
/// Guardar não é tocar — na real, mixer, Global EQ e entrada voltam relidos e o
/// som não muda (DECISOES AJ1); por isso o app não os envia e os testes
/// conferem que nada sai, não que a demonstração guardou. `selected-preset-area`
/// fica com quem cuida das áreas.
void gravarAjustesGlobais(Map<String, Object?> ajustes, Map<String, dynamic> pedido) {
  pedido.forEach((chave, valor) {
    if (chave != 'selected-preset-area') ajustes[chave] = valor;
  });
}
