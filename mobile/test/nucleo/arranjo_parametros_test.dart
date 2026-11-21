// Arranjo do painel: o paramétrico em bandas sem perder parâmetro, os amps
// na ordem do catálogo (a do painel do pedal) e o GEQ em faders.
import 'package:anagram_app/apresentacao/componentes/painel_parametros.dart';
import 'package:anagram_app/nucleo/catalogo/arranjo_parametros.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';

void main() {
  final catalogo = lerCatalogo();
  final parametrico = catalogo.definicao('urn:darkglass:fil4#mono');

  test('should_group_the_parametric_eq_by_band_with_each_band_switch_in_its_title_and_no_parameter_lost', () {
    final visiveis = parametrosVisiveis(parametrico, BlocoPreset(const PosicaoBloco(1, 1), {'uri': parametrico.uri}));

    final grupos = agruparParametros(parametrico, visiveis);

    final banda1 = grupos.firstWhere((g) => g.banda == BandaEq.banda1);
    expect(banda1.chave?.simbolo, 'sec1');
    expect(banda1.parametros.map((p) => p.rotulo), ['Frequency', 'Width', 'Gain']);
    final noPainel = [
      for (final g in grupos) ...[if (g.chave != null) g.chave!.simbolo, ...g.parametros.map((p) => p.parametro.simbolo)],
    ];
    expect(noPainel..sort(), [...visiveis.map((p) => p.simbolo)]..sort(), reason: 'cada parâmetro uma vez');
  });

  test('should_keep_catalog_order_in_a_single_group_for_amps', () {
    final amp = catalogo.definicao('urn:darkglass:neural-plugins:peggycl');

    final grupos = agruparParametros(amp, amp.parametros);

    expect(grupos.single.parametros.map((p) => p.parametro.simbolo), amp.parametros.map((p) => p.simbolo));
  });

  test('should_use_faders_for_graphic_eq_bands_and_knobs_elsewhere', () {
    final geq = catalogo.definicao('urn:darkglass:DarkglassGEQ');
    final nam = catalogo.definicao('urn:darkglass:neural:tone3000');

    expect(formaDoControle(geq, geq.parametro('S250Hz')!), FormaControle.fader);
    expect(formaDoControle(nam, nam.parametro('S1600Hz')!), FormaControle.fader);
    expect(formaDoControle(nam, nam.parametro('INPUT')!), FormaControle.knob);
    expect(formaDoControle(parametrico, parametrico.parametro('gain1')!), FormaControle.knob);
  });
}
