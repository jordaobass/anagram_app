// O que cada parâmetro faz com o som, em pt/en/es. O texto do próprio pedal
// vence (o Threshold do Ignissor fala da banda; o do Suppressor, de porta de
// ruído); sem ele, vale a regra pelo tipo do parâmetro. Sem nenhum dos dois,
// não há explicação — melhor nada que um balão vazio ou um palpite.
// Os textos ficam em assets/explicacoes/parametros.json (DECISOES TT1).
import 'dart:convert';

import 'definicao_bloco.dart';

/// Um texto nos três idiomas do app.
class TextoExplicacao {
  const TextoExplicacao(this.porIdioma);

  factory TextoExplicacao.doJson(Map<String, dynamic> json) =>
      TextoExplicacao({for (final e in json.entries) e.key: e.value as String});

  static const idiomas = ['pt', 'en', 'es'];
  static const _reserva = 'en';

  final Map<String, String> porIdioma;

  /// Idioma fora dos três cai no inglês.
  String em(String idioma) => porIdioma[idioma] ?? porIdioma[_reserva] ?? porIdioma.values.first;
}

/// Regra pelo tipo: casa a expressão em "`símbolo nome`" (minúsculas) e,
/// quando pedido, só em chave liga/desliga ou só numa unidade ("" = sem unidade).
class RegraTipo {
  RegraTipo({required this.id, required String casa, required this.texto, this.alternavel, this.unidade})
      : _expressao = RegExp(casa);

  factory RegraTipo.doJson(Map<String, dynamic> json) => RegraTipo(
        id: json['id'] as String,
        casa: json['casa'] as String,
        alternavel: json['alternavel'] as bool?,
        unidade: json['unidade'] as String?,
        texto: TextoExplicacao.doJson(json['texto'] as Map<String, dynamic>),
      );

  final String id;
  final bool? alternavel;
  final String? unidade;
  final TextoExplicacao texto;
  final RegExp _expressao;

  bool vale(DefinicaoParametro p) {
    if (alternavel != null && alternavel != p.alternavel) return false;
    if (unidade != null && unidade != (p.unidade ?? '')) return false;
    return _expressao.hasMatch('${p.simbolo} ${p.nome}'.toLowerCase());
  }
}

class ExplicacoesParametros {
  ExplicacoesParametros({required this.tipos, required this.porBloco});

  factory ExplicacoesParametros.doTexto(String texto) =>
      ExplicacoesParametros.doJson(jsonDecode(texto) as Map<String, dynamic>);

  factory ExplicacoesParametros.doJson(Map<String, dynamic> json) => ExplicacoesParametros(
        tipos: [for (final t in json['tipos'] as List<dynamic>) RegraTipo.doJson(t as Map<String, dynamic>)],
        porBloco: _porBloco(json['blocos'] as List<dynamic>),
      );

  static const vazio = _Vazio();

  /// Regras na ordem do arquivo: a primeira que vale ganha.
  final List<RegraTipo> tipos;

  /// uri → símbolo → texto do próprio pedal.
  final Map<String, Map<String, TextoExplicacao>> porBloco;

  static Map<String, Map<String, TextoExplicacao>> _porBloco(List<dynamic> blocos) {
    final mapa = <String, Map<String, TextoExplicacao>>{};
    for (final bloco in blocos.cast<Map<String, dynamic>>()) {
      final parametros = {
        for (final e in (bloco['parametros'] as Map<String, dynamic>).entries)
          e.key: TextoExplicacao.doJson(e.value as Map<String, dynamic>),
      };
      for (final uri in (bloco['uris'] as List<dynamic>).cast<String>()) {
        mapa.putIfAbsent(uri, () => {}).addAll(parametros);
      }
    }
    return mapa;
  }

  /// O texto do pedal ou, sem ele, o do tipo; null quando nenhum se aplica.
  TextoExplicacao? de(String uri, DefinicaoParametro parametro) =>
      porBloco[uri]?[parametro.simbolo] ?? tipoDe(parametro)?.texto;

  RegraTipo? tipoDe(DefinicaoParametro parametro) {
    for (final regra in tipos) {
      if (regra.vale(parametro)) return regra;
    }
    return null;
  }
}

/// Antes do arquivo carregar (ou se ele faltar), nada se explica.
class _Vazio implements ExplicacoesParametros {
  const _Vazio();
  @override
  List<RegraTipo> get tipos => const [];
  @override
  Map<String, Map<String, TextoExplicacao>> get porBloco => const {};
  @override
  TextoExplicacao? de(String uri, DefinicaoParametro parametro) => null;
  @override
  RegraTipo? tipoDe(DefinicaoParametro parametro) => null;
}
