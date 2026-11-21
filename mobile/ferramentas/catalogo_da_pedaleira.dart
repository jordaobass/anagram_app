// Lê da Anagram ligada (rodar no PC com a pedaleira: dart run ferramentas/catalogo_da_pedaleira.dart): firmware, read_all_plugins e get_plugin_info de cada
// bloco, e grava as respostas cruas em catalogo-pedaleira.json.
import 'dart:convert';
import 'dart:io';

import 'package:anagram_app/nucleo/protocolo/cliente_anagram.dart';
import 'package:anagram_app/plataforma/transporte_hidapi.dart';

Future<void> main(List<String> argumentos) async {
  final transporte = TransporteHidapi();
  await transporte.abrir();
  final cliente = ClienteAnagram(transporte, prazoPadrao: const Duration(seconds: 15));
  final saida = <String, dynamic>{};
  saida['firmware'] = await cliente.chamar('fetch_firmware_version');
  final lista = await cliente.chamar('read_all_plugins', const {});
  saida['read_all_plugins'] = lista;
  stdout.writeln('lista: ${jsonEncode(lista).length} bytes');
  final uris = <String>{};
  void coletar(Object? no) {
    if (no is Map) {
      for (final e in no.entries) {
        if ((e.key == 'uri' || e.key == 'URI') && e.value is String) uris.add(e.value as String);
        coletar(e.value);
      }
    } else if (no is List) {
      for (final x in no) {
        if (x is String && x.contains(':') && !x.contains(' ')) uris.add(x);
        coletar(x);
      }
    }
  }
  coletar(lista);
  stdout.writeln('uris: ${uris.length}');
  final infos = <String, dynamic>{};
  for (final uri in uris) {
    try {
      infos[uri] = await cliente.chamar('get_plugin_info', {'uri': uri});
    } on Object catch (erro) {
      infos[uri] = {'erro': '$erro'};
    }
  }
  saida['get_plugin_info'] = infos;
  File('catalogo-pedaleira.json').writeAsStringSync(const JsonEncoder.withIndent(' ').convert(saida));
  await transporte.fechar();
  stdout.writeln('ok');
  exit(0);
}
