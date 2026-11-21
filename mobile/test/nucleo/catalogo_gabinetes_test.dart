// O gabinete se escolhe como na pedaleira: modelo → microfone → posição, e a
// escolha vira o arquivo de IR gravado no bloco. Linhas reais da tabela do
// Darkglass Suite 6.11.4 (ib.qv).
import 'package:anagram_app/nucleo/catalogo/catalogo_gabinetes.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:anagram_app/nucleo/modelo/documento_preset.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';

final catalogoDeTeste = CatalogoGabinetes.doJson({
  'bass': [
    ['Darkglass Neo 2x12', 'Condenser 103', 'Cap On Axis', '212 103 on axis_01-MP'],
    ['Darkglass Neo 2x12', 'Condenser 103', 'Edge On Axis', '212 103 off axis_01-MP'],
    ['Darkglass Neo 2x12', 'Dynamic 112', 'Cap On Axis', '212 D112 on axis_01-MP'],
    ['Black & Yellow 4x10', 'Condenser 103', 'Cap On Axis', 'Markb410_103_1_90-MP'],
    ['Black & Yellow 4x10', 'Condenser 103', 'Cone On Axis', 'Markb410_103_2A_90-MP'],
  ],
});

void main() {
  test('should_tell_model_mic_and_position_of_the_ir_saved_in_the_preset', () {
    final opcao = catalogoDeTeste.doArquivo(TipoGabinete.bass, '/factory-data/cabinets/212 103 on axis_01-MP.dat')!;

    expect([opcao.modelo, opcao.microfone, opcao.posicao], ['Darkglass Neo 2x12', 'Condenser 103', 'Cap On Axis']);
    expect(catalogoDeTeste.doArquivo(TipoGabinete.bass, '/user-files/cabinets/meu IR.wav'), isNull,
        reason: 'IR do usuário não está na tabela');
  });

  test('should_offer_only_the_mics_and_positions_of_the_chosen_model', () {
    expect(catalogoDeTeste.modelos(TipoGabinete.bass), ['Darkglass Neo 2x12', 'Black & Yellow 4x10']);
    expect(catalogoDeTeste.microfones(TipoGabinete.bass, 'Darkglass Neo 2x12'), ['Condenser 103', 'Dynamic 112']);
    expect(catalogoDeTeste.posicoes(TipoGabinete.bass, 'Black & Yellow 4x10', 'Condenser 103'),
        ['Cap On Axis', 'Cone On Axis']);
  });

  test('should_keep_mic_and_position_when_the_new_model_has_them_after_changing_model', () {
    final mesma = catalogoDeTeste.escolher(TipoGabinete.bass, 'Black & Yellow 4x10',
        microfone: 'Condenser 103', posicao: 'Cone On Axis')!;
    final outra = catalogoDeTeste.escolher(TipoGabinete.bass, 'Black & Yellow 4x10',
        microfone: 'Dynamic 112', posicao: 'Edge On Axis')!;

    expect(mesma.arquivo, 'Markb410_103_2A_90-MP');
    expect(outra.arquivo, 'Markb410_103_1_90-MP', reason: 'sem o microfone, vai o primeiro do modelo');
  });

  test('should_write_the_ir_in_the_device_format_when_a_cabinet_is_chosen', () {
    final exemplo = DocumentoPreset.doJson(lerExemplo('2'));
    const posicao = PosicaoBloco(1, 9);
    final escolhido = catalogoDeTeste.escolher(TipoGabinete.bass, 'Black & Yellow 4x10')!;

    final bloco = exemplo.comArquivoDeIr(posicao, escolhido.caminho).bloco(posicao)!;

    expect(bloco.bruto['properties'], {
      '1': {
        'name': 'Cabinet File',
        'uri': 'urn:darkglass-anagram:cabinet-bass#file',
        'value': '/factory-data/cabinets/Markb410_103_1_90-MP.dat',
      },
    });
  });

  test('should_create_the_ir_property_like_the_device_when_the_block_has_none', () {
    final demo = DocumentoPreset.doJson(lerPresetsDemonstracao()[3]!);
    const posicao = PosicaoBloco(1, 6);

    final bloco = demo.comArquivoDeIr(posicao, '/factory-data/cabinets/x.dat').bloco(posicao)!;

    expect(bloco.arquivoDeIr, '/factory-data/cabinets/x.dat');
    expect((bloco.bruto['properties'] as Map<String, dynamic>)['1'],
        {'name': 'Cabinet File', 'uri': 'urn:darkglass-anagram:cabinet-bass#file', 'value': '/factory-data/cabinets/x.dat'});
  });
}
