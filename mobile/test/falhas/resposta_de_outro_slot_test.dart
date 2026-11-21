// A leitura do slot A estoura o prazo e a resposta dela chega atrasada, no meio
// da leitura do slot B. Aceitá-la abriria o preset de A com o rótulo de B, e o
// "Salvar" gravaria A por cima de B. A leitura de slot VAZIO não traz nome
// (bancada 2026-11-21: `{"data":{"presetFile":{}},"success":1,"err_message":
// "file does not exist"}`), então a atrasada de um vazio faria um slot ocupado
// parecer vazio, e o "Salvar como" gravaria por cima sem perguntar (RN10).
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:anagram_app/nucleo/protocolo/api_anagram.dart';
import 'package:anagram_app/nucleo/protocolo/cliente_anagram.dart';
import 'package:anagram_app/nucleo/protocolo/erros_anagram.dart';
import 'package:anagram_app/nucleo/protocolo/quadros_hid.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/pedaleira_roteirizada.dart';

Map<String, dynamic> _leitura(String arquivo) => {
      'action': AcoesAnagram.lerPreset,
      'payload': {
        'data': {
          'presetFile': {
            'name': arquivo,
            'content': {
              'type': 'preset',
              'version': 1,
              'preset': {'name': 'PRESET $arquivo', 'chains': <String, dynamic>{}},
            },
          },
        },
      },
    };

const Map<String, dynamic> _vazia = {
  'action': AcoesAnagram.lerPreset,
  'payload': {
    'data': {'presetFile': <String, dynamic>{}},
    'success': 1,
    'err_message': 'file does not exist',
  },
};

ApiAnagram _api(List<Map<String, dynamic>> Function(MensagemAnagram) roteiro) =>
    ApiAnagram(ClienteAnagram(PedaleiraRoteirizada(roteiro), prazoPadrao: const Duration(milliseconds: 50)));

void main() {
  test('should_discard_the_late_reply_of_another_slot_when_it_echoes_its_file_name', () async {
    // o primeiro pedido fica sem resposta; o segundo recebe a atrasada e a sua
    List<Map<String, dynamic>> roteiro(MensagemAnagram pedido) =>
        pedido.carga['filename'] == '1.json' ? const [] : [_leitura('1.json'), _leitura('${pedido.carga['filename']}')];
    final api = ApiAnagram(ClienteAnagram(PedaleiraRoteirizada(roteiro), prazoPadrao: const Duration(milliseconds: 50)));

    await expectLater(api.lerPreset(SlotPreset(1)), throwsA(isA<ErroSemResposta>()));
    final lido = await api.lerPreset(SlotPreset(2));

    expect(lido!.nome, 'PRESET 2.json');
  });

  test('should_not_take_the_late_reply_of_an_empty_slot_as_the_reply_of_an_occupied_one', () async {
    final api = _api((pedido) => pedido.carga['filename'] == '1.json' ? const [] : [_vazia, _leitura('2.json')]);

    await expectLater(api.lerPreset(SlotPreset(1)), throwsA(isA<ErroSemResposta>()));
    final lido = await api.lerPreset(SlotPreset(2));

    expect(lido?.nome, 'PRESET 2.json');
  });

  test('should_read_an_empty_slot_as_empty_when_no_late_reply_is_pending', () async {
    final api = _api((pedido) => const [_vazia]);

    expect(await api.lerPreset(SlotPreset(3)), isNull);
  });

  test('should_read_an_empty_slot_as_empty_after_the_late_reply_already_arrived', () async {
    final api = _api((pedido) => pedido.carga['filename'] == '1.json' ? const [] : [_leitura('1.json'), _vazia]);

    await expectLater(api.lerPreset(SlotPreset(1)), throwsA(isA<ErroSemResposta>()));

    expect(await api.lerPreset(SlotPreset(2)), isNull);
  });
}
