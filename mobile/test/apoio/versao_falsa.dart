// Falsos da verificação de versão nova: o GitHub roteirizado (nenhuma
// chamada de rede de verdade), as preferências em memória e o registro
// capturado para conferir a causa das falhas.
import 'dart:convert';

import 'package:anagram_app/dados/preferencias_versao.dart';
import 'package:anagram_app/nucleo/registro.dart';
import 'package:anagram_app/plataforma/consulta_http.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

/// Responde como `/releases/latest` com [tag]; com [erro], a consulta falha.
class GithubFalso implements ConsultaHttp {
  GithubFalso({this.tag = 'v0.1.3', this.erro, this.prerelease = false, this.draft = false});

  String tag;
  final Object? erro;
  final bool prerelease;
  final bool draft;
  final pedidos = <({Uri endereco, Map<String, String> cabecalhos, Duration limite})>[];

  static String paginaDa(String tag) => 'https://github.com/jordaobass/anagram_app/releases/tag/$tag';

  @override
  Future<String> obter(Uri endereco, {required Map<String, String> cabecalhos, required Duration limite}) async {
    pedidos.add((endereco: endereco, cabecalhos: cabecalhos, limite: limite));
    if (erro case final erro?) throw erro;
    return jsonEncode({'tag_name': tag, 'html_url': paginaDa(tag), 'prerelease': prerelease, 'draft': draft});
  }
}

class PreferenciasVersaoEmMemoria implements PreferenciasVersao {
  PreferenciasVersaoEmMemoria([this.salvo = const ConfiguracaoVersao()]);

  ConfiguracaoVersao salvo;

  @override
  Future<ConfiguracaoVersao> ler() async => salvo;

  @override
  Future<void> gravar(ConfiguracaoVersao configuracao) async => salvo = configuracao;
}

/// Guarda as linhas do registro enquanto o teste roda.
class RegistroCapturado extends LogOutput {
  final linhas = <String>[];

  String get texto => linhas.join('\n');

  @override
  void output(OutputEvent event) => linhas.addAll(event.lines);

  static RegistroCapturado ligar() {
    final captura = RegistroCapturado();
    saidasDoRegistro.acrescentar(captura);
    addTearDown(() => saidasDoRegistro.remover(captura));
    return captura;
  }
}
