// Plugins instalados na pedaleira de demonstração: um bloco de Marketplace
// fictício, fora do catálogo de fábrica, para a lista de adicionar e o painel
// mostrarem o que a pedaleira descreve (DECISOES P4). As respostas seguem o
// formato real de `read_all_plugins` e `get_plugin_info` (firmware 1.19.2).

/// Uri do bloco fictício do Marketplace (o domínio .invalid não existe).
const uriNebulaDemonstracao = 'https://marketplace.invalid/plugins/nebula-synth';

/// Resposta de `read_all_plugins`: a lista do que está instalado. Tem também
/// dois blocos de fábrica, como na pedaleira real (que lista tudo).
Map<String, dynamic> listaDePluginsDemonstracao() => {
      'success': 1,
      'data': [
        {'uri': 'urn:darkglass:Suppressor', 'version': '0.0-0', 'type': 2},
        {'uri': 'urn:darkglass:CompLim', 'version': '0.0-0', 'type': 2},
        {'uri': uriNebulaDemonstracao, 'version': '1.0-3', 'type': 0},
      ],
    };

Map<String, dynamic> _porta(String simbolo, String nome, int flags, num minimo, num maximo, num padrao,
        {String unidade = '', int designacao = 0, List<Map<String, Object>> pontos = const []}) =>
    {
      'symbol': simbolo, 'name': nome, 'shortname': '', 'flags': flags, 'designation': designacao,
      'def': padrao, 'min': minimo, 'max': maximo, 'unit': unidade, 'scalePoints': pontos,
    };

/// Resposta de `get_plugin_info` para [uri]: a definição do bloco fictício,
/// ou só o nome para os outros (como antes; o app não os pede).
Map<String, dynamic> infoDePluginDemonstracao(String uri) => uri != uriNebulaDemonstracao
    ? {'data': {'name': uri.split(':').last}}
    : {
        'success': 1,
        'err_message': '',
        'data': {
          'abbreviation': 'NEB',
          'category': 22,
          'flags': 20,
          'name': 'Nebula Synth (demo)',
          'uri': uriNebulaDemonstracao,
          'version': '1.0-3',
          'properties': <dynamic>[],
          'ports': [
            _porta('lv2_audio_in_1', 'Audio Input 1', 1, 0, 1, 0),
            _porta('lv2_audio_out_1', 'Audio Output 1', 5, 0, 1, 0),
            _porta('lv2_enabled', 'Enabled', 50, 0, 1, 1, designacao: 1),
            _porta('lv2_reset', 'Reset', 34, 0, 2, 0, designacao: 3),
            _porta('cutoff', 'Cutoff', 130, 20, 20000, 1200, unidade: 'Hz', designacao: 4),
            _porta('resonance', 'Resonance', 2, 0, 10, 3),
            _porta('wave', 'Wave', 98, 0, 2, 0, pontos: [
              {'label': 'Saw', 'value': 0},
              {'label': 'Square', 'value': 1},
              {'label': 'Sine', 'value': 2},
            ]),
            _porta('octave', 'Octave', 34, -2, 2, 0),
            _porta('glide', 'Glide', 18, 0, 1, 0),
            _porta('level', 'Level', 2, -24, 6, 0, unidade: 'dB'),
          ],
        },
      };
