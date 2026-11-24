// Blocos lidos da própria pedaleira (Marketplace, firmware novo; DECISOES P4):
// `read_all_plugins` lista o que está instalado e `get_plugin_info` descreve
// um bloco. As regras abaixo são as que geraram blocks-factory.json: aplicadas
// às 109 respostas da pedaleira do dono (1.19.2), devolvem as 109 definições
// do catálogo, parâmetro a parâmetro (conferido em 2026-11-24).
import '../modelo/json_util.dart';
import 'definicao_bloco.dart';

/// Bits de `flags` de cada porta (LV2 do firmware).
abstract final class _Porta {
  static const controle = 0x2;
  static const saida = 0x4;
  static const alternavel = 0x10;
  static const inteiro = 0x20;
  static const opcoes = 0x40;
  static const logaritmico = 0x80;
}

/// `designation` → papel do parâmetro no catálogo.
const _papeis = {1: 'bypass', 2: 'hostTempo', 3: 'reset', 4: 'quickpotDefault'};

/// Liga/desliga e reset do próprio LV2: o catálogo não os lista como parâmetro.
const _portasDoSistema = {'lv2_enabled', 'lv2_reset'};

/// Blocos instaláveis (Marketplace) e `read_all_plugins` chegaram no
/// firmware 1.14 (tabela de ações do Darkglass Suite 6.11.4, "1014000").
/// Antes disso o pedido só gastaria o prazo da fila; versão que não se lê
/// vale como nova.
bool firmwareComPlugins(String firmware) {
  final versao = RegExp(r'(\d+)\.(\d+)').firstMatch(firmware);
  if (versao == null) return true;
  final (maior, menor) = (int.parse(versao.group(1)!), int.parse(versao.group(2)!));
  return maior > 1 || (maior == 1 && menor >= 14);
}

/// As uris que a pedaleira diz ter instaladas (resposta de `read_all_plugins`).
List<String> urisDosPlugins(Object? resposta) => [
      for (final item in _lista(mapaOuVazio(resposta)['data'])) ?_uriOuNula(item),
    ];

String? _uriOuNula(Object? item) {
  final uri = textoOuNulo(mapaOuVazio(item)['uri']);
  return uri == null || uri.isEmpty ? null : uri;
}

/// A definição do bloco pela resposta de `get_plugin_info`, ou nula quando a
/// pedaleira não o descreve (não instalado, resposta sem portas).
/// [categoria] dá o nome do grupo pelo código (`category`), como no catálogo.
DefinicaoBloco? definicaoDoPluginInfo(String uri, Object? resposta, String Function(int codigo) categoria) {
  final dados = mapaOuVazio(mapaOuVazio(resposta)['data']);
  final portas = dados['ports'];
  if (portas is! List) return null;
  return DefinicaoBloco.doJson(uri, {
    'name': textoOuNulo(dados['name']) ?? uri,
    'abbr': textoOuNulo(dados['abbreviation']) ?? '',
    'category': categoria(numeroOuNulo(dados['category'])?.toInt() ?? 0),
    'params': [
      for (final porta in portas.whereType<Map<String, dynamic>>())
        if (_ehParametro(porta)) _parametro(porta),
    ],
  });
}

bool _ehParametro(Map<String, dynamic> porta) {
  final flags = numeroOuNulo(porta['flags'])?.toInt() ?? 0;
  return flags & _Porta.controle != 0 &&
      flags & _Porta.saida == 0 &&
      !_portasDoSistema.contains(porta['symbol']) &&
      porta['symbol'] is String;
}

Map<String, dynamic> _parametro(Map<String, dynamic> porta) {
  final flags = numeroOuNulo(porta['flags'])?.toInt() ?? 0;
  final pontos = _lista(porta['scalePoints']).map(mapaOuVazio).toList();
  final unidade = textoOuNulo(porta['unit']) ?? '';
  final alternavel = flags & _Porta.alternavel != 0;
  final opcoes = flags & _Porta.opcoes != 0 && pontos.isNotEmpty;
  return {
    'symbol': porta['symbol'],
    'name': textoOuNulo(porta['name']) ?? porta['symbol'],
    'min': numeroOuNulo(porta['min']) ?? 0,
    'max': numeroOuNulo(porta['max']) ?? 1,
    'def': numeroOuNulo(porta['def']) ?? 0,
    if (unidade.isNotEmpty) 'unit': unidade,
    if (alternavel) 'toggle': true,
    if (!alternavel && flags & _Porta.inteiro != 0 && flags & _Porta.opcoes == 0) 'integer': true,
    if (flags & _Porta.logaritmico != 0) 'log': true,
    if (opcoes) 'options': [for (final p in pontos) '${p['label']}'],
    'role': ?_papeis[numeroOuNulo(porta['designation'])?.toInt()],
  };
}

List<Object?> _lista(Object? valor) => valor is List ? valor : const [];
