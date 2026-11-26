// Biblioteca de presets por banda (DECISOES BB1): o arquivo do build monta
// presets no formato da pedaleira, com valores por cena, gabinete e
// footswitches do template.
import 'dart:io';

import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/nucleo/catalogo/catalogo_gabinetes.dart';
import 'package:anagram_app/nucleo/modelo/biblioteca_bandas.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:anagram_app/nucleo/modelo/controles_pedaleira.dart';
import 'package:anagram_app/nucleo/modelo/documento_preset.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';

BibliotecaBandas _doBuild({CatalogoGabinetes gabinetes = const CatalogoGabinetes.vazio()}) => BibliotecaBandas.doTexto(
  File(CaminhosAssets.bibliotecaBandas).readAsStringSync(),
  lerCatalogo(),
  gabinetes: gabinetes,
);

DocumentoPreset _preset(BibliotecaBandas biblioteca, String nome) =>
    biblioteca.presets.firstWhere((p) => p.nome == nome).documento;

void main() {
  test('should_build_every_preset_of_muse_and_the_four_other_bands_when_reading_the_bundled_file', () {
    final biblioteca = _doBuild();

    expect(biblioteca.colecoes.single.bandas.map((b) => b.nome), [
      'Muse',
      'Queens of the Stone Age',
      'System of a Down',
      'Limp Bizkit',
      'Tool',
    ]);
    expect(biblioteca.presets, hasLength(9), reason: 'nenhum preset pode ficar de fora');
  });

  test('should_keep_the_values_that_differ_per_scene_when_building_a_preset', () {
    final fuzz = _preset(_doBuild(), 'QOTSA FUZZ');
    final atomic = fuzz.bloco(const PosicaoBloco(1, 2))!;

    expect(fuzz.cenaAtiva, 1);
    expect(atomic.valorNaCena('drive', 1), 4);
    expect(atomic.valorNaCena('drive', 2), 1.5);
    expect(atomic.valorNaCena('drive', 3), 1.5);
    expect(atomic.valorNaCena('pres', 2), 5.5, reason: 'o que não muda vale em todas as cenas');
  });

  test('should_keep_disabled_blocks_off_in_every_scene_when_building_a_preset', () {
    final fuzz = _preset(_doBuild(), 'QOTSA FUZZ');
    final shifter = fuzz.bloco(const PosicaoBloco(1, 3))!;

    expect([for (final cena in fuzz.cenas) shifter.habilitadoNaCena(cena)], [false, false, false]);
    expect(fuzz.bloco(const PosicaoBloco(1, 4))!.habilitadoNaCena(2), isTrue);
  });

  test('should_put_the_parallel_row_and_the_guitar_cabinet_when_building_muse_hysteria', () {
    final hysteria = _preset(_doBuild(), 'MUSE HYSTERIA');

    expect(hysteria.blocosDaLinha(2).map((b) => b.uri), contains('urn:darkglass-anagram:cabinet-guitar'));
    expect(hysteria.bloco(const PosicaoBloco(1, 2))!.uri, 'urn:darkglass-anagram:split');
  });

  test('should_assign_shifter_fuzz_and_octaver_to_the_footswitches_when_the_preset_follows_the_template', () {
    final fuzz = _preset(_doBuild(), 'MUSE FUZZ');
    final limpo = _preset(_doBuild(), 'SOAD CLEAN');

    expect(fuzz.controles.keys, containsAll([IdControle.foot1, IdControle.foot2, IdControle.foot3]));
    expect(limpo.controles, isEmpty, reason: 'fora do template não há footswitch atribuído');
  });

  test('should_pick_the_cabinet_ir_when_the_build_has_the_cabinet_table', () {
    final gabinetes = CatalogoGabinetes.doJson({
      'bass': [
        ['Peggy 8x10', 'Condenser 103', 'Cap On Axis', 'PEGGY810_103_1'],
      ],
    });
    final fuzz = _preset(_doBuild(gabinetes: gabinetes), 'QOTSA FUZZ');

    expect(fuzz.bloco(const PosicaoBloco(1, 11))!.arquivoDeIr, contains('PEGGY810_103_1'));
  });

  test('should_leave_out_a_preset_with_an_unknown_block_without_hiding_the_others', () {
    const texto =
        '{"bandas":[{"nome":"X","presets":['
        '{"name":"BOM","blocks":[{"row":1,"col":1,"type":"urn:darkglass:FETComp","enabled":true,"params":{"Input":6}}]},'
        '{"name":"RUIM","blocks":[{"row":1,"col":1,"type":"urn:nada:existe","enabled":true,"params":{}}]}'
        ']}]}';
    final biblioteca = BibliotecaBandas.doTexto(texto, lerCatalogo());

    expect(biblioteca.presets.map((p) => p.nome), ['BOM']);
  });
}
