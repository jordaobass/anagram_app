// O guia de um bloco montado para a IA: a curadoria (papel, armadilhas,
// ponto de partida) junto com o que o catálogo sabe (nome, família, faixa de
// cada parâmetro) e a explicação de cada controle. Em inglês, como o resto
// do MCP. Só os parâmetros-chave vêm com faixa e dica; os outros só por
// símbolo, para a resposta caber no limite (IC4).
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/catalogo/explicacoes_parametros.dart';
import '../../nucleo/conhecimento/base_conhecimento.dart';
import 'descricao_preset.dart';

class DescricaoGuiaBloco {
  const DescricaoGuiaBloco(this.explicacoes);

  final ExplicacoesParametros explicacoes;

  /// Sem curadoria, quantos parâmetros entram com faixa e dica.
  static const _chaveSemCuradoria = 6;

  /// Quantas letras do papel entram na lista por família.
  static const _tamanhoResumo = 160;

  Map<String, dynamic> bloco(DefinicaoBloco definicao, EntradaGuiaBloco? entrada) {
    final chave = _parametrosChave(definicao, entrada);
    final outros = [for (final p in DescricaoPreset.parametrosAjustaveis(definicao)) if (!chave.contains(p)) p.simbolo];
    return {
      'type': definicao.uri,
      'name': DescricaoPreset.nomeDoBloco(definicao),
      'family': definicao.familia.name,
      'role': entrada?.papel ?? 'No curated guide for this block yet; its parameters are below.',
      'models': ?entrada?.modela,
      'key_parameters': [for (final p in chave) _parametro(definicao.uri, p, entrada?.parametrosChave[p.simbolo])],
      if (entrada != null && entrada.pontoDePartida.isNotEmpty) ...{
        'starting_point': entrada.pontoDePartida,
        'starting_point_source': entrada.origemDoPonto,
      },
      if (entrada != null && entrada.armadilhas.isNotEmpty) 'pitfalls': entrada.armadilhas,
      if (entrada != null && entrada.combinaCom.isNotEmpty) 'pairs_with': entrada.combinaCom,
      if (outros.isNotEmpty) 'other_parameters': outros,
      if (entrada != null && entrada.uris.length > 1) 'variants': entrada.uris,
      'hint': 'Values for set_parameter: numbers in the unit shown, option labels as written, true/false for toggles.',
    };
  }

  /// A linha da lista por família: tipo, nome e a primeira frase do papel.
  Map<String, dynamic> resumo(DefinicaoBloco definicao, EntradaGuiaBloco? entrada) => {
        'type': definicao.uri,
        'name': DescricaoPreset.nomeDoBloco(definicao),
        'role': _primeiraFrase(entrada?.papel ?? ''),
      };

  /// Os parâmetros curados, na ordem da curadoria; sem curadoria, os primeiros ajustáveis.
  List<DefinicaoParametro> _parametrosChave(DefinicaoBloco definicao, EntradaGuiaBloco? entrada) {
    final ajustaveis = DescricaoPreset.parametrosAjustaveis(definicao);
    if (entrada == null || entrada.parametrosChave.isEmpty) return ajustaveis.take(_chaveSemCuradoria).toList();
    return entrada.parametrosChave.keys.map(definicao.parametro).nonNulls.where(ajustaveis.contains).toList();
  }

  Map<String, dynamic> _parametro(String uri, DefinicaoParametro p, String? dicaCurada) {
    final descrito = DescricaoPreset.parametro(p, p.padrao)
      ..remove('value')
      ..remove('display');
    final dica = dicaCurada ?? explicacoes.de(uri, p)?.em('en');
    return {...descrito, 'tip': ?dica};
  }

  static String _primeiraFrase(String texto) {
    final fim = texto.indexOf('. ');
    final frase = fim < 0 ? texto : texto.substring(0, fim + 1);
    return frase.length <= _tamanhoResumo ? frase : '${frase.substring(0, _tamanhoResumo - 1)}…';
  }
}
