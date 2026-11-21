// Geometria dos desenhos do multibanda: a curva do compressor (1:1 até o
// Threshold, 1/ratio depois), a resposta da banda (nível no meio, −3 dB no
// corte) e a onda que satura com o drive; e o Solo feito pelos mutes.
import 'package:anagram_app/apresentacao/componentes/botoes_banda.dart';
import 'package:anagram_app/nucleo/catalogo/arranjo_multibanda.dart';
import 'package:anagram_app/nucleo/catalogo/curvas_multibanda.dart';
import 'package:anagram_app/nucleo/catalogo/tipos_de_drive.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';

void main() {
  test('should_follow_one_to_one_below_the_threshold_and_one_over_ratio_above_it', () {
    expect(saidaDoCompressorDb(-40, limiarDb: -30, razao: 4), -40);
    expect(saidaDoCompressorDb(-10, limiarDb: -30, razao: 4), -25);
    expect(saidaDoCompressorDb(-10, limiarDb: -30, razao: 4, ligado: false), -10, reason: 'comp desligado = reta 1:1');
    expect(curvaDoCompressor(limiarDb: -30, razao: 4), [(-60.0, -60.0), (-30.0, -30.0), (0.0, -22.5)],
        reason: 'o canto cai exatamente no Threshold');
  });

  test('should_sit_at_the_band_level_inside_and_three_db_below_it_at_the_cut', () {
    expect(respostaDaBandaDb(1000, inferior: 250, superior: 4000, nivelDb: -6), closeTo(-6, 0.1));
    expect(respostaDaBandaDb(250, inferior: 250, nivelDb: 0), closeTo(-3, 0.02));
    expect(respostaDaBandaDb(50, inferior: 250), lessThan(-20), reason: 'duas oitavas e pouco abaixo do corte');
    expect(respostaDaBandaDb(10000, superior: 250), lessThan(-60));
  });

  test('should_flatten_the_wave_as_the_drive_goes_up', () {
    double perto(double drive) => ondaSaturada(drive, pontos: 12)[1].$2; // fase 1/12: seno = 0,5

    expect(perto(0), closeTo(0.5, 0.15), reason: 'pouco drive: quase senoide');
    expect(perto(10), greaterThan(0.95), reason: 'muito drive: quase quadrada');
    expect(ondaSaturada(10).map((p) => p.$2.abs()).reduce((a, b) => a > b ? a : b), closeTo(1, 1e-9));
  });

  test('should_solo_by_muting_the_other_bands_and_unsolo_by_unmuting_all', () {
    final mutes = {BandaMultibanda.graves: 'lo_mute', BandaMultibanda.medios: 'mid_mute', BandaMultibanda.agudos: 'hi_mute'};
    final nenhuma = {for (final b in BandaMultibanda.values) b: false};

    expect(mutesDoSolo(BandaMultibanda.medios, mutes, nenhuma), {'lo_mute': 1, 'mid_mute': 0, 'hi_mute': 1});
    final soMedios = {BandaMultibanda.graves: true, BandaMultibanda.medios: false, BandaMultibanda.agudos: true};
    expect(emSolo(BandaMultibanda.medios, soMedios), isTrue, reason: 'mutar as outras à mão também é solo');
    expect(mutesDoSolo(BandaMultibanda.medios, mutes, soMedios), {'lo_mute': 0, 'mid_mute': 0, 'hi_mute': 0});
  });

  test('should_split_every_entropia_drive_option_into_type_and_mode_and_back', () {
    final opcoes = lerCatalogo().definicao('urn:darkglass:entropia').parametro('mid_drive_typemode')!.opcoes;
    final tipos = TiposDeDrive(opcoes);

    for (var i = 0; i < opcoes.length; i++) {
      final (tipo, modo) = tipos.doIndice(i);
      expect(tipos.indice(tipo, modo), i, reason: opcoes[i]);
      expect([tipo, ?modo].join(' '), opcoes[i]);
    }
    expect(tipos.tipos, ['Bypass', 'B3K', 'VMT', 'Alpha', 'Omega', 'Chinchilla', 'B3K Turbo', 'VMT Turbo', 'Alpha Turbo', 'Omega Turbo']);
    expect(tipos.modos('Chinchilla'), ['Flat', 'Midscoop', 'Midboost', 'Synth']);
    expect(opcoes[tipos.trocarTipo(opcoes.indexOf('B3K Grunt'), 'B3K Turbo')], 'B3K Turbo Grunt', reason: 'mantém o modo');
    expect(opcoes[tipos.trocarTipo(opcoes.indexOf('VMT Midboost 2'), 'Alpha')], 'Alpha Flat', reason: 'sem o modo: o primeiro');
  });
}
