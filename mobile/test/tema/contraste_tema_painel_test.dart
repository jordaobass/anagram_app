// Contraste dos painéis com a tela da pedaleira (Ignissor e Entropia em
// alumínio, Axioma em neon), medido com Color.computeLuminance. A aparência é
// única, a mesma com o app claro ou escuro (PT9). Texto e valor 4,5:1 sobre
// as superfícies e sobre cada degrau da tela pintada (com e sem o reflexo ou
// a grade, o pior caso); traço de estado (foco, contorno, curva, cor do
// bloco) 3:1; tinta de marcador sobre o destaque e as bandas 4,5:1. E as
// peças do aparelho: faixa dos módulos, LCD, campo Controlar, barra e
// cartões da janela de templates, letra gravada no alumínio.
import 'package:anagram_app/apresentacao/tema/paletas_painel.dart';
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
  for (final MapEntry(key: nome, value: (uri, bandas)) in _blocos.entries) {
    final t = TemaPainel.doBloco(uri)!;
    final p = t.paleta;
    final superficies = {'fundo-case': p.fundoCase, 'painel': p.painel, 'painel-elevado': p.painelElevado};
    final tela = {
      for (final (i, c) in t.tela.indexed) ...{'tela $i': c, 'tela $i com reflexo': Color.alphaBlend(t.reflexo, c)},
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
      for (final MapEntry(key: degrau, value: cor) in tela.entries) {
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
        _passa('destaque (arco, chave, curva) sobre $superficie', t.destaque, cor, _grafico);
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

  test('should_keep_the_axioma_device_parts_readable', () {
    final p = TemaPainel.neon().paleta;
    _passa('título na faixa magenta', CoresNeon.sobreFaixa, CoresNeon.faixaTitulo, _texto);
    _passa('chave desligada na faixa', p.textoSecundario, CoresNeon.faixaTitulo, _texto);
    _passa('slot no LCD', CoresNeon.lcdTinta, CoresNeon.lcdFundo, _texto);
    _passa('Controlar no campo azul', CoresNeon.campoTinta, CoresNeon.campoFundo, _texto);
    _passa('Controlar no fim do degradê', CoresNeon.campoTinta, Color.lerp(CoresNeon.campoFundo, CoresNeon.azul, 0.35)!, _texto);
    _passa('título da janela na barra azul', CoresNeon.sobreFaixa, CoresNeon.barraJanela, _texto);
    for (final cor in CoresNeon.barra) {
      _passa('ícone das abas na barra', CoresNeon.ciano, cor, _grafico);
    }
    _passa('nome do template no cartão', CoresNeon.sobreFaixa, p.painelElevado, _texto);
    _passa('descrição do template no cartão', p.textoSecundario, p.painelElevado, _texto);
    _passa('curva ciano na tela do módulo', CoresNeon.ciano, p.fundoCase, _grafico);
  });

  test('should_keep_engraved_ink_readable_on_the_aluminium', () {
    for (final cor in CoresChassi.gradiente) {
      _passa('letra gravada no alumínio', CoresChassi.tintaGravada, cor, _texto);
    }
    for (final cor in [...CoresChassi.barra, CoresChassi.placaBotao]) {
      _passa('nome e botão na barra clara', CoresChassi.tintaGravada, cor, _texto);
      _passa('template aplicado e legenda na barra clara', CoresChassi.tintaSecundariaGravada, cor, _texto);
      _passa('contorno do botão e foco na barra clara', CoresChassi.biselSombra, cor, _grafico);
    }
    _passa('separador "Do app" na janela de alumínio', CoresChassi.tintaSecundariaGravada, CoresChassi.gradiente[1], _texto);
    _passa('título da janela de alumínio', CoresChassi.tintaGravada, CoresChassi.gradiente.last, _texto);
  });

  test('should_look_the_same_whatever_the_app_theme_and_leave_other_blocks_on_the_case', () {
    expect(TemaPainel.doBloco('urn:darkglass:parametric_eq'), isNull);
    expect(TemaPainel.doBloco('urn:darkglass:alpha_omega'), isNull);
    expect(TemaPainel.neon().paleta.painel, TemaPainel.doBloco('urn:darkglass:axioma_synth')!.paleta.painel);
  });
}
