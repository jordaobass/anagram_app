// Contraste dos pares por papel nos DOIS temas, medido com a luminância da cor
// de verdade (Color.computeLuminance), não lido de texto. Texto e ícone que
// informam: 4,5:1 (WCAG AA). Traço que é o único sinal de um estado (anel de
// foco, contorno da seleção, arco do knob, fita da família): 3:1.
import 'package:anagram_app/apresentacao/tema/paleta.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/contraste.dart';

const _texto = 4.5;
const _grafico = 3.0;

void _passa(String par, Color frente, Color fundo, double minimo) =>
    expect(contraste(frente, fundo), greaterThanOrEqualTo(minimo),
        reason: '$par: ${contraste(frente, fundo).toStringAsFixed(2)}:1, mínimo $minimo:1');

void main() {
  for (final (nome, p) in [('escuro', Paleta.escura), ('claro', Paleta.clara)]) {
    final superficies = {'fundo-case': p.fundoCase, 'painel': p.painel, 'painel-elevado': p.painelElevado};

    test('should_keep_text_roles_above_aa_on_every_surface_in_the_${nome}_theme', () {
      final tintas = {
        'texto': p.texto,
        'texto-secundario': p.textoSecundario,
        'aluminio-claro': p.aluminioClaro,
        'tally-tinta': p.tallyTinta,
        'erro': p.erro,
        'led-ligado': p.ledLigado,
      };
      for (final MapEntry(key: tinta, value: frente) in tintas.entries) {
        for (final MapEntry(key: superficie, value: fundo) in superficies.entries) {
          _passa('$tinta sobre $superficie', frente, fundo, _texto);
        }
      }
    });

    test('should_keep_text_on_filled_surfaces_above_aa_in_the_${nome}_theme', () {
      _passa('sobre-tally no tally', p.sobreTally, p.tally, _texto);
      _passa('tinta de marcador na fita gaffer', p.tintaMarcador, p.fitaGaffer, _texto);
      _passa('sobre-alerta na fita de alerta', p.sobreAlerta, p.fitaAlerta, _texto);
      _passa('aviso (snackbar) na fita gaffer', p.tintaMarcador, p.fitaGaffer, _texto);
      for (final (modo, cor) in [('preset', p.modoPreset), ('stomp', p.modoStomp), ('scene', p.modoScene)]) {
        _passa('sobre-modo na pílula $modo', p.sobreModo, cor, _texto);
      }
    });

    test('should_keep_state_strokes_above_3_to_1_in_the_${nome}_theme', () {
      _passa('anel de foco e contorno da seleção', p.tallyTinta, p.painel, _grafico);
      _passa('contorno do botão secundário', p.aluminio, p.painel, _grafico);
      _passa('led da demonstração', p.ledDemonstracao, p.painel, _grafico);
      for (final (modo, cor) in [('preset', p.modoPreset), ('stomp', p.modoStomp), ('scene', p.modoScene)]) {
        _passa('pílula $modo acesa sobre o painel', cor, p.painel, _grafico);
      }
    });

    test('should_keep_family_stripes_and_marked_options_readable_in_the_${nome}_theme', () {
      for (final MapEntry(key: familia, value: cor) in p.familias.entries) {
        _passa('marcador sobre a opção marcada de ${familia.name}', p.tintaMarcador, cor, _texto);
        if (p.ehEscura) continue;
        // no escuro a fita é o acento claro sobre o case; no claro ela escurece até 3:1
        _passa('fita de ${familia.name} sobre o painel', cor, p.painel, _grafico);
      }
    });
  }
}
