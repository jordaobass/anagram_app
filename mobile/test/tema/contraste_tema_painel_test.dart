// Contraste dos painéis temáticos (Ignissor e Entropia em alumínio, Axioma em
// synthwave) nos DOIS brilhos, medido com Color.computeLuminance: texto e
// valor 4,5:1 sobre as superfícies do painel E sobre cada degrau do fundo
// pintado (com e sem o reflexo/grade por cima, que é o pior caso); traço de
// estado (foco, contorno, curva, cor do bloco) 3:1; tinta de marcador sobre o
// destaque e as bandas (opção marcada, solo) 4,5:1.
import 'package:anagram_app/apresentacao/tema/tema_painel.dart';
import 'package:anagram_app/nucleo/catalogo/arranjo_multibanda.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/contraste.dart';

const _texto = 4.5;
const _grafico = 3.0;

void _passa(String par, Color frente, Color fundo, double minimo) =>
    expect(contraste(frente, fundo), greaterThanOrEqualTo(minimo),
        reason: '$par: ${contraste(frente, fundo).toStringAsFixed(2)}:1, mínimo $minimo:1');

const _blocos = {
  'ignissor': ('urn:darkglass:ignissor', PaletaBandas.ignissor),
  'entropia': ('urn:darkglass:entropia', PaletaBandas.entropia),
  'axioma': ('urn:darkglass:axioma_synth', null),
};

void main() {
  for (final MapEntry(key: bloco, value: (uri, bandas)) in _blocos.entries) {
    for (final brilho in Brightness.values) {
      final nome = '${bloco}_${brilho == Brightness.dark ? 'escuro' : 'claro'}';
      final t = TemaPainel.doBloco(uri, brilho)!;
      final p = t.paleta;
      final superficies = {'fundo-case': p.fundoCase, 'painel': p.painel, 'painel-elevado': p.painelElevado};
      final fundo = {
        for (final (i, c) in t.fundo.indexed) ...{
          'fundo $i': c,
          'fundo $i com reflexo': Color.alphaBlend(t.reflexo, c),
        },
      };

      test('should_keep_text_and_values_above_aa_on_the_${nome}_panel', () {
        final tintas = {
          'texto': p.texto,
          'texto-secundario': p.textoSecundario,
          'aluminio-claro': p.aluminioClaro,
          'tally-tinta': p.tallyTinta,
          'erro': p.erro,
        };
        for (final MapEntry(key: tinta, value: frente) in tintas.entries) {
          for (final MapEntry(key: superficie, value: cor) in superficies.entries) {
            _passa('$tinta sobre $superficie', frente, cor, _texto);
          }
        }
        // o letreiro, a legenda e o botão de templates ficam sobre o fundo pintado
        for (final MapEntry(key: degrau, value: cor) in fundo.entries) {
          _passa('texto sobre $degrau', p.texto, cor, _texto);
          _passa('texto secundário sobre $degrau', p.textoSecundario, cor, _texto);
          _passa('anel de foco sobre $degrau', p.tallyTinta, cor, _grafico);
          _passa('contorno de botão sobre $degrau', p.aluminio, cor, _grafico);
        }
      });

      test('should_keep_state_strokes_and_the_block_colour_readable_on_the_${nome}_panel', () {
        _passa('anel de foco no painel', p.tallyTinta, p.painel, _grafico);
        for (final MapEntry(key: superficie, value: cor) in superficies.entries) {
          _passa('contorno e aro do knob sobre $superficie', p.aluminio, cor, _grafico);
          _passa('destaque (arco, chave) sobre $superficie', t.destaque, cor, _grafico);
        }
        _passa('marcador sobre a opção marcada', p.tintaMarcador, t.destaque, _texto);
        if (bandas == null) return;
        for (final banda in BandaMultibanda.values) {
          final cor = p.daBanda(banda, bandas);
          _passa('banda ${banda.name} sobre o painel', cor, p.painel, _grafico);
          _passa('marcador sobre o solo da banda ${banda.name}', p.tintaMarcador, cor, _texto);
        }
        _passa('traço do Threshold', p.linhaThreshold, p.painel, _grafico);
        _passa('traço do Level', p.linhaLevel, p.painel, _grafico);
      });
    }
  }

  test('should_leave_every_other_block_on_the_app_case', () {
    expect(TemaPainel.doBloco('urn:darkglass:parametric_eq', Brightness.dark), isNull);
    expect(TemaPainel.doBloco('urn:darkglass:alpha_omega', Brightness.light), isNull);
  });
}
