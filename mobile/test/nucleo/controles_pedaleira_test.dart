// Footswitches, pots e pedal de expressão (`bindings`) lidos e editados no
// documento: o arquivo real volta inteiro, e cada edição mexe só no controle.
import 'dart:convert';
import 'dart:io';

import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:anagram_app/nucleo/modelo/controles_pedaleira.dart';
import 'package:anagram_app/nucleo/modelo/documento_preset.dart';
import 'package:anagram_app/nucleo/modelo/edicao_controles.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';

/// Os presets reais com controles: os exemplos e os 36 de fábrica do Suite.
List<Map<String, dynamic>> presetsReais() {
  final fabrica = jsonDecode(File('assets/blocos_terceiros/fabrica.json').readAsStringSync()) as Map<String, dynamic>;
  return [
    for (final n in ['1', '2', '13', '41']) lerExemplo(n),
    for (final item in fabrica['presets'] as List) (item as Map<String, dynamic>)['preset'] as Map<String, dynamic>,
  ];
}

Map<String, dynamic> vinculos(DocumentoPreset documento) =>
    documento.paraJson()['preset']['bindings'] as Map<String, dynamic>;

const suppressor = PosicaoBloco(1, 1);
const wah = PosicaoBloco(1, 2);

void main() {
  final catalogo = lerCatalogo();
  final threshold = catalogo.definicao('urn:darkglass:Suppressor').parametro('Threshold')!;
  final position = catalogo.definicao('urn:darkglass:wah').parametro('Position')!;

  test('should_read_every_control_and_keep_unknown_fields_when_editing_real_presets', () {
    final presets = presetsReais();
    var controlesLidos = 0;
    for (final json in presets) {
      final documento = DocumentoPreset.doJson(json);
      final originais = mapaDe(json['preset']['bindings']);
      expect(documento.controles.keys.map((id) => id.chave).toSet(), originais.keys.toSet(),
          reason: 'toda chave real é um controle conhecido');
      controlesLidos += documento.controles.length;
      for (final MapEntry(key: id, value: controle) in documento.controles.entries) {
        final esperado = jsonDecode(jsonEncode(originais))..[id.chave]['name'] = 'X';
        expect(vinculos(documento.comNomeDoControle(id, 'X')), esperado,
            reason: '${controle.nome}: só o nome muda; properties, faixa omitida e o resto voltam iguais');
      }
    }
    expect(controlesLidos, greaterThan(70));
  });

  test('should_assign_a_pot_with_the_catalog_range_and_the_value_playing_in_the_active_scene', () {
    final documento = DocumentoPreset.doJson(lerExemplo('1')).comParametroNoControle(IdControle.pot3, suppressor, threshold);

    final pot = documento.controles[IdControle.pot3]!;
    expect(vinculos(documento)['pot3'], {
      'name': 'Threshold',
      'parameters': [
        {'block': 1, 'max': 0, 'min': -80, 'row': 1, 'symbol': 'Threshold'}
      ],
      'properties': <dynamic>[],
      'value': documento.bloco(suppressor)!.valorNaCena('Threshold', documento.cenaAtiva),
    });
    expect(pot.valor, closeTo(-43.9, 0.01));
  });

  test('should_point_a_footswitch_at_the_block_bypass_with_its_current_state', () {
    final documento = DocumentoPreset.doJson(lerExemplo('1'));

    final desligado = documento.comFootswitchNoBloco(IdControle.foot2, wah, 'Wah');
    final ligado = documento.comFootswitchNoBloco(IdControle.foot1, suppressor, 'Suppressor');

    expect(vinculos(desligado)['foot2'], {
      'name': 'Wah',
      'parameters': [
        {'block': 2, 'max': 1, 'min': 0, 'row': 1, 'symbol': ':bypass'}
      ],
      'properties': <dynamic>[],
      'value': 0,
    });
    expect(ligado.controles[IdControle.foot1]!.valor, 1, reason: 'no :bypass, 1 = bloco ligado');
  });

  test('should_move_a_parameter_out_of_its_old_control_when_assigned_to_another', () {
    final documento = DocumentoPreset.doJson(lerExemplo('1')).comParametroNoControle(IdControle.pot1, wah, position);

    expect(documento.controles.containsKey(IdControle.expressao), isFalse,
        reason: 'o Position era do pedal, que ficou sem alvo e saiu');
    expect(documento.controles[IdControle.pot1]!.alvos.map((a) => a.simbolo), [':bypass', 'Position'],
        reason: 'no pot ocupado o parâmetro entra junto com o que já havia');
  });

  test('should_drop_a_target_and_the_control_left_without_targets', () {
    final documento = DocumentoPreset.doJson(lerExemplo('1')).comParametroNoControle(IdControle.pot1, wah, position);

    final semUm = documento.semAlvoNoControle(IdControle.pot1, 0);
    expect(semUm.controles[IdControle.pot1]!.alvos.single.simbolo, 'Position');
    expect(semUm.semAlvoNoControle(IdControle.pot1, 0).controles.containsKey(IdControle.pot1), isFalse);
    expect(documento.semControle(IdControle.pot2).controles.keys, isNot(contains(IdControle.pot2)));
    expect(documento.controles.keys, contains(IdControle.pot2), reason: 'o documento é imutável');
  });

  test('should_refuse_a_range_without_travel_or_outside_the_parameter', () {
    expect(motivoFaixaInvalida(threshold, -20, -20), RecusaFaixa.iguais);
    expect(motivoFaixaInvalida(threshold, -90, 0), RecusaFaixa.foraDaFaixa);
    expect(motivoFaixaInvalida(threshold, 0, -80), isNull, reason: 'invertido é um controle válido');
    final ajustado = DocumentoPreset.doJson(lerExemplo('1')).comFaixaNoAlvo(IdControle.expressao, 0, 2, 8);
    expect(vinculos(ajustado)['exp.pedal']['parameters'][0], containsPair('min', 2));
    expect(vinculos(ajustado)['exp.pedal']['parameters'][0], containsPair('max', 8));
  });

  test('should_keep_an_assigned_control_following_its_block_when_moved_and_drop_it_when_removed', () {
    final documento = DocumentoPreset.doJson(lerExemplo('1')).comParametroNoControle(IdControle.pot3, suppressor, threshold);

    final movido = documento.comBlocoMovido(suppressor, const PosicaoBloco(1, 4));
    expect(movido.controles[IdControle.pot3]!.alvos.single.posicao, const PosicaoBloco(1, 4));
    expect(movido.semBloco(const PosicaoBloco(1, 4)).controles.containsKey(IdControle.pot3), isFalse);
  });
}

Map<String, dynamic> mapaDe(Object? valor) => valor is Map<String, dynamic> ? valor : <String, dynamic>{};
