// Blocos do Marketplace lidos da própria pedaleira (DECISOES P4): a resposta
// real de get_plugin_info vira a mesma definição que o catálogo de fábrica
// tem (o catálogo foi gerado dessas respostas), e read_all_plugins dá as uris
// instaladas. Respostas reais da Anagram do dono, firmware 1.19.2.
import 'dart:convert';
import 'dart:io';

import 'package:anagram_app/nucleo/catalogo/definicao_bloco.dart';
import 'package:anagram_app/nucleo/catalogo/plugins_da_pedaleira.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';

const _aperture = 'https://cognate.audio/plugins/cognate-aperture';

Map<String, dynamic> _respostas() =>
    jsonDecode(File('test/fixtures/plugins_da_pedaleira.json').readAsStringSync()) as Map<String, dynamic>;

List<Object?> _comoNoCatalogo(DefinicaoParametro p) =>
    [p.simbolo, p.nome, p.minimo, p.maximo, p.padrao, p.unidade, p.alternavel, p.inteiro, p.logaritmico, p.opcoes, p.papel];

void main() {
  test('should_read_an_installed_plugin_exactly_as_the_factory_catalog_describes_it', () {
    final catalogo = lerCatalogo();

    final lida = definicaoDoPluginInfo(_aperture, _respostas()['get_plugin_info'], catalogo.nomeDaCategoria)!;

    final esperada = catalogo.definicao(_aperture);
    expect((lida.nome, lida.abreviacao, lida.categoria), (esperada.nome, esperada.abreviacao, esperada.categoria));
    expect(lida.parametros.map(_comoNoCatalogo), esperada.parametros.map(_comoNoCatalogo));
  });

  test('should_list_the_uris_the_pedal_says_are_installed', () {
    final uris = urisDosPlugins(_respostas()['read_all_plugins']);

    expect(uris, contains(_aperture));
    expect(uris, hasLength(8));
  });

  test('should_give_no_definition_when_the_pedal_answers_without_ports', () {
    expect(definicaoDoPluginInfo('urn:x', {'data': {'name': 'x'}}, (_) => ''), isNull);
    expect(definicaoDoPluginInfo('urn:x', {'success': 0, 'err_message': 'not found'}, (_) => ''), isNull);
  });

  test('should_ask_for_plugins_only_from_firmware_1_14_on', () {
    // o Darkglass Suite 6.11.4 libera read_all_plugins a partir do 1014000
    expect([for (final f in ['v1.13.9.1', 'v1.14.0.0', 'v1.19.2.24\n', 'v2.0.0', '?']) firmwareComPlugins(f)],
        [false, true, true, true, true]);
  });
}
