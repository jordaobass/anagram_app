// O guia de blocos é o que a IA lê para saber o que cada bloco faz: todo
// bloco do catálogo de fábrica precisa de entrada, e tudo que a entrada
// cita (parâmetro-chave, ponto de partida) tem de existir no catálogo com o
// valor dentro da faixa — senão a IA aprende a mexer no que não existe.
import 'package:anagram_app/nucleo/catalogo/variantes_uri.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';
import '../apoio/validacao_catalogo.dart';

void main() {
  final catalogo = lerCatalogo();
  final guia = lerGuiaBlocos();

  test('should_have_a_guide_entry_for_every_block_in_the_factory_catalog', () {
    final semGuia = [for (final b in catalogo.todos) if (!guia.cobre(b.uri)) b.uri];

    expect(semGuia, isEmpty, reason: 'blocos sem entrada no guia: $semGuia');
    expect(catalogo.quantidade, greaterThanOrEqualTo(100), reason: 'o catálogo de fábrica tem 109 blocos');
  });

  test('should_only_point_at_catalog_uris_and_parameters_with_values_inside_their_ranges', () {
    final problemas = <String>[];
    for (final entrada in guia.entradas) {
      for (final uri in entrada.uris) {
        final definicao = catalogo.definicao(uri);
        if (definicao.parametros.isEmpty) problemas.add('$uri is not in the catalog');
        for (final simbolo in entrada.parametrosChave.keys) {
          if (definicao.parametro(simbolo) == null) problemas.add('$uri: key parameter "$simbolo" does not exist');
        }
        for (final ajuste in entrada.pontoDePartida.entries) {
          if (problemaDoAjuste(definicao, ajuste.key, ajuste.value) case final problema?) problemas.add(problema);
        }
      }
      if (entrada.pontoDePartida.isNotEmpty && entrada.origemDoPonto == null) {
        problemas.add('${entrada.uris.first}: starting point without its source');
      }
    }

    expect(problemas, isEmpty, reason: problemas.join('\n'));
  });

  test('should_describe_every_block_with_a_role_and_find_it_with_or_without_the_channel_suffix', () {
    for (final entrada in guia.entradas) {
      expect(entrada.papel.trim().length, greaterThan(30), reason: '${entrada.uris.first} precisa dizer o papel no som');
    }
    for (final bloco in catalogo.todos) {
      // a IA pede "urn:darkglass:fil4" ou "…fil4#stereo": as duas formas acham o guia
      expect(guia.de(semSufixoDeCanal(bloco.uri)), isNotNull, reason: bloco.uri);
      expect(guia.de(bloco.uri), isNotNull, reason: bloco.uri);
    }
    expect(guia.de('urn:darkglass:Chorus#stereo'), same(guia.de('urn:darkglass:ChorusStereo')),
        reason: 'variantes de canal do mesmo efeito dividem a entrada');
  });

  test('should_name_the_blocks_that_pair_with_an_entry_by_catalog_uri', () {
    final desconhecidos = [
      for (final e in guia.entradas)
        for (final uri in e.combinaCom)
          if (catalogo.definicao(uri).parametros.isEmpty) '${e.uris.first} -> $uri',
    ];

    expect(desconhecidos, isEmpty, reason: desconhecidos.join('\n'));
  });
}
