// A Anagram (v1.19.2.24) grava o preset mas pode não confirmar o
// edit_anagram_presets em 30 s. O app não pode dizer "falhou" quando o preset
// está gravado: relê o slot e só acusa a falha se o conteúdo não for o enviado.
import 'package:anagram_app/dados/repositorio_pedaleira.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/modelo/documento_preset.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:anagram_app/nucleo/protocolo/api_anagram.dart';
import 'package:anagram_app/nucleo/protocolo/cliente_anagram.dart';
import 'package:anagram_app/nucleo/protocolo/erros_anagram.dart';
import 'package:anagram_app/nucleo/resultado.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pedaleira que grava sem confirmar: o salvar estoura o prazo, a leitura
/// devolve o que [gravado] disser.
class _PedaleiraMuda extends ClienteAnagram {
  _PedaleiraMuda(this.gravado) : super(TransporteDemonstracao(presets: const {}));

  final Map<String, dynamic>? gravado;

  @override
  Future<Map<String, dynamic>> chamar(String acao, [Map<String, dynamic> carga = const {}, Duration? prazo]) async {
    if (acao == AcoesAnagram.salvar) throw ErroSemResposta(acao, const Duration(seconds: 30));
    return {'data': {'presetFile': {'name': '10.json', 'content': gravado}}};
  }
}

Map<String, dynamic> _preset(String nome, String uri, {num ganho = 5, num? ganhoNaCena2}) => {
      'type': 'preset',
      'version': 1,
      'preset': {
        'name': nome,
        'chains': {
          '1': {
            'blocks': {
              '1': {
                'uri': uri,
                'enabled': true,
                'parameters': {
                  '1': {'name': 'Gain', 'symbol': 'gain', 'value': ganho},
                },
                'properties': {},
                'scenes': {
                  if (ganhoNaCena2 != null)
                    '2': {
                      'enabled': true,
                      'parameters': [
                        {'symbol': 'gain', 'value': ganhoNaCena2},
                      ],
                    },
                },
              },
            },
          },
        },
      },
    };

void main() {
  final enviado = DocumentoPreset.doJson(_preset('CAPTURA IGN', 'urn:darkglass:ignissor'));

  test('should_report_success_when_the_pedal_does_not_confirm_but_the_slot_holds_what_was_sent', () async {
    final repositorio = RepositorioPedaleira(ApiAnagram(_PedaleiraMuda(_preset('CAPTURA IGN', 'urn:darkglass:ignissor'))));

    final resultado = await repositorio.salvar(SlotPreset(10), enviado, area: 'user');

    expect(resultado, isA<Sucesso<void>>());
  });

  test('should_report_the_failure_when_the_pedal_does_not_confirm_and_the_slot_holds_something_else', () async {
    final repositorio = RepositorioPedaleira(ApiAnagram(_PedaleiraMuda(_preset('OUTRO', 'urn:darkglass:BUSComp'))));

    final resultado = await repositorio.salvar(SlotPreset(10), enviado, area: 'user');

    expect((resultado as Falha).erro, isA<ErroSemResposta>());
  });

  test('should_report_the_failure_when_the_slot_holds_the_same_chain_with_another_knob_value', () async {
    final repositorio = RepositorioPedaleira(ApiAnagram(_PedaleiraMuda(_preset('CAPTURA IGN', 'urn:darkglass:ignissor', ganho: 2))));

    final resultado = await repositorio.salvar(SlotPreset(10), enviado, area: 'user');

    expect((resultado as Falha).erro, isA<ErroSemResposta>());
  });

  test('should_report_the_failure_when_the_slot_lost_the_value_of_a_scene', () async {
    final enviadoComCena = DocumentoPreset.doJson(_preset('CAPTURA IGN', 'urn:darkglass:ignissor', ganhoNaCena2: 8));
    final semACena = _preset('CAPTURA IGN', 'urn:darkglass:ignissor', ganhoNaCena2: 3);
    final repositorio = RepositorioPedaleira(ApiAnagram(_PedaleiraMuda(semACena)));

    final resultado = await repositorio.salvar(SlotPreset(10), enviadoComCena, area: 'user');

    expect((resultado as Falha).erro, isA<ErroSemResposta>());
  });

  test('should_report_success_when_the_slot_holds_the_sent_value_rounded_to_single_precision', () async {
    final enviadoComFracao = DocumentoPreset.doJson(_preset('CAPTURA IGN', 'urn:darkglass:ignissor', ganho: 7.6));
    final gravadoEmFloat = _preset('CAPTURA IGN', 'urn:darkglass:ignissor', ganho: 7.599999904632568);
    final repositorio = RepositorioPedaleira(ApiAnagram(_PedaleiraMuda(gravadoEmFloat)));

    final resultado = await repositorio.salvar(SlotPreset(10), enviadoComFracao, area: 'user');

    expect(resultado, isA<Sucesso<void>>());
  });
}
