// A resposta da pedaleira é entrada externa: um firmware novo ou um arquivo
// editado à mão pode trazer número onde o app espera texto. Isso não pode
// virar exceção solta (tela carregando para sempre, tela vermelha).
import 'package:anagram_app/dados/repositorio_pedaleira.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/modelo/documento_preset.dart';
import 'package:anagram_app/nucleo/protocolo/api_anagram.dart';
import 'package:anagram_app/nucleo/protocolo/cliente_anagram.dart';
import 'package:anagram_app/nucleo/protocolo/erros_anagram.dart';
import 'package:anagram_app/nucleo/resultado.dart';
import 'package:flutter_test/flutter_test.dart';

/// Cliente que devolve uma resposta pronta (ou lança o que o teste mandar),
/// sem passar pelos relatórios HID.
class _ClienteRespondendo extends ClienteAnagram {
  _ClienteRespondendo(this._responder) : super(TransporteDemonstracao(presets: const {}));

  final Map<String, dynamic> Function(String acao) _responder;

  @override
  Future<Map<String, dynamic>> chamar(String acao, [Map<String, dynamic> carga = const {}, Duration? prazo]) async =>
      _responder(acao);
}

RepositorioPedaleira _repositorio(Map<String, dynamic> Function(String acao) responder) =>
    RepositorioPedaleira(ApiAnagram(_ClienteRespondendo(responder)));

void main() {
  test('should_list_the_slot_when_the_pedal_sends_numbers_where_text_was_expected', () async {
    final repositorio = _repositorio((_) => {
          'data': {
            'files': [
              {'filename': 7, 'name': 42, 'id': 9},
            ],
          },
        });

    final lista = await repositorio.listarSlots();

    final slots = (lista as Sucesso).valor as List;
    expect(slots.single.slot.rotulo, '03A');
    expect(slots.single.nome, '');
  });

  test('should_report_an_invalid_reply_when_reading_it_breaks_an_unexpected_type', () async {
    final repositorio = _repositorio((_) => throw TypeError());

    final lista = await repositorio.listarSlots();

    expect(lista, isA<Falha<dynamic>>());
    expect((lista as Falha).erro, isA<ErroRespostaInvalida>());
  });

  test('should_skip_a_chain_cell_that_is_not_an_object_when_listing_blocks', () {
    final documento = DocumentoPreset.doJson({
      'type': 'preset',
      'version': 1,
      'preset': {
        'name': 99,
        'chains': {
          '1': {
            'blocks': {
              '1': {'uri': 'urn:bloco', 'parameters': {'1': {'symbol': 'Gain', 'value': 'alto'}}},
              '2': 'casa corrompida',
            },
          },
        },
      },
    });

    final blocos = documento.blocosDaLinha(1);

    expect(blocos.map((b) => b.posicao.casa), [1]);
    expect(blocos.single.valorBase('Gain'), isNull);
    expect(documento.nome, 'Sem nome');
  });
}
