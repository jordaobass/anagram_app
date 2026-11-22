// Os tons do TONE3000 que a pedaleira devolve (respostas reais da v1.19.2.24
// em test/fixtures/t3k) e o caminho que o bloco grava para cada modelo.
import 'dart:convert';
import 'dart:io';

import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/modelo/ir_do_gabinete.dart';
import 'package:anagram_app/nucleo/protocolo/api_anagram.dart';
import 'package:anagram_app/nucleo/protocolo/api_tone3000.dart';
import 'package:anagram_app/nucleo/protocolo/cliente_anagram.dart';
import 'package:anagram_app/nucleo/tone3000/tom_tone3000.dart';
import 'package:anagram_app/nucleo/tone3000/tons_da_pedaleira.dart';
import 'package:flutter_test/flutter_test.dart';

const _neural = 'urn:darkglass:neural:tone3000';
const _gabineteT3k = 'urn:darkglass-anagram:cabinet-tone3000#stereo';

/// O caminho do preset real com o Ampeg SVT carregado (fw 1.19.2.24).
const _caminhoReal = '/factory-data/neural-models-t3k/28202/379991.nam';

Map<String, dynamic> _resposta(String arquivo) =>
    (jsonDecode(File('test/fixtures/t3k/$arquivo.json').readAsStringSync()) as Map<String, dynamic>)['resposta']
        as Map<String, dynamic>;

final _fabrica = tonsDeFabricaDaResposta(_resposta('get_t3k_factory_tones'));

TomTone3000 _tom(int id) => _fabrica.firstWhere((t) => t.id == id);

Future<ApiAnagram> _apiDaDemonstracao({bool semTone3000 = false}) async {
  final pedaleira = TransporteDemonstracao()..semTone3000 = semTone3000;
  await pedaleira.abrir();
  return ApiAnagram(ClienteAnagram(pedaleira));
}

void main() {
  test('should_read_the_15_factory_tones_of_the_real_reply_with_format_gear_author_and_models', () {
    expect(_fabrica, hasLength(15));
    expect(_fabrica.where((t) => t.formato == FormatoTom.ir).map((t) => t.id), [1612, 27465, 36273]);
    final svt = _tom(28202);
    expect(svt.titulo, 'Ampeg SVT Classic with 6x10');
    expect(svt.gear, 'amp-cab');
    expect((svt.autor, svt.licenca, svt.doUsuario), ('tone3000', 't3k', false));
    expect(svt.modelos, hasLength(8));
    expect((svt.modelos.first.id, svt.modelos.first.nome), (379991, 'Ampeg SVT - Gain 10 Ultra Lo and Hi MD 421'));
  });

  test('should_build_the_factory_path_the_pedal_writes_for_tone_28202_model_379991', () {
    final svt = _tom(28202);
    expect(svt.caminhoDo(svt.modelos.first), _caminhoReal);
    // IR: mesma regra, extensão do model_url (hipótese T3K3)
    final mesa = _tom(1612);
    expect(mesa.caminhoDo(mesa.modelos.single), '/factory-data/irs-t3k/1612/81565.wav');
  });

  test('should_find_the_tone_and_model_loaded_in_the_block_or_report_it_as_not_on_the_pedal', () {
    final tons = TonsDaPedaleira(fabrica: _fabrica);

    final achado = tons.doBloco(_neural, _caminhoReal)!;
    expect((achado.tom.id, achado.modelo?.id), (28202, 379991));
    expect(tons.doBloco(_neural, '/factory-data/neural-models-t3k/99999/1.nam'), isNull, reason: 'tom removido');
    expect(tons.doBloco(_neural, '/factory-data/neural-models-t3k/28202/1.nam')!.modelo, isNull,
        reason: 'o tom está lá, o arquivo não é um dos modelos listados');
    expect(tons.doBloco(_neural, null), isNull);
  });

  test('should_read_user_tones_from_the_metadata_pages_without_a_path_to_write', () {
    expect(PaginaDeTons.daResposta(_resposta('get_t3k_tones_metadata_vazio')).tons, isEmpty);
    final pagina = PaginaDeTons.daResposta(_resposta('get_t3k_tones_metadata_com_itens'));
    final tom = pagina.tons.single;

    expect((pagina.total, tom.id, tom.doUsuario, tom.modelos.single.id), (1, 77001, true, 88001));
    expect(tom.caminhoDo(tom.modelos.single), isNull, reason: 'a pedaleira não diz o nome do arquivo (T3K4)');
    final tons = TonsDaPedaleira(doUsuario: pagina.tons);
    expect(tons.doBloco(_neural, '/data/user-files/neural-models-t3k/77001/B7K Blend 50.nam')!.tom.id, 77001);
  });

  test('should_keep_name_uri_and_extra_keys_of_the_existing_property_when_writing_a_new_tone', () {
    final bloco = <String, dynamic>{
      'uri': _neural,
      'properties': <String, dynamic>{
        '1': <String, dynamic>{'name': 'Neural Model', 'uri': '$_neural#model', 'value': _caminhoReal, 'extra': 7},
      },
    };
    gravarArquivoDeIr(bloco, '/factory-data/neural-models-t3k/45809/382800.nam');

    expect(bloco['properties']['1'], {
      'name': 'Neural Model',
      'uri': '$_neural#model',
      'value': '/factory-data/neural-models-t3k/45809/382800.nam',
      'extra': 7,
    });
  });

  test('should_create_the_property_with_the_name_and_uri_of_each_kind_of_block_when_missing', () {
    final neural = <String, dynamic>{'uri': _neural, 'properties': <dynamic>[]};
    final gabinete = <String, dynamic>{'uri': _gabineteT3k};
    gravarArquivoDeIr(neural, _caminhoReal);
    gravarArquivoDeIr(gabinete, '/factory-data/irs-t3k/1612/81565.wav');

    expect(neural['properties']['1'], {'name': 'Neural Model', 'uri': '$_neural#model', 'value': _caminhoReal});
    expect(gabinete['properties']['1']['name'], 'Cabinet File');
    expect(gabinete['properties']['1']['uri'], 'urn:darkglass-anagram:cabinet-tone3000#file');
  });

  test('should_read_factory_and_user_tones_from_the_demo_pedal_and_none_when_the_firmware_lacks_t3k', () async {
    final tons = await (await _apiDaDemonstracao()).lerTonsDaPedaleira();
    expect(tons.disponivel, isTrue);
    expect(tons.fabrica.map((t) => t.id), contains(28202));
    expect(tons.doUsuario.single.doUsuario, isTrue);

    final semT3k = await (await _apiDaDemonstracao(semTone3000: true)).lerTonsDaPedaleira();
    expect(semT3k.disponivel, isFalse);
    expect(semT3k.todos, isEmpty, reason: 'firmware sem t3k não derruba nada: só não há tons');
  });
}
