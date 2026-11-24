// O preset aberto descrito para a IA: cadeia, blocos com nome legível, cada
// parâmetro com valor, faixa, unidade e opções, cenas e gabinete. Em inglês
// e com números de verdade (ponto decimal): é dado para o modelo, não tela.
import '../../nucleo/catalogo/catalogo_gabinetes.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/catalogo/formatador_valor.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../../nucleo/modelo/documento_preset.dart';
import '../estado/estado_editor.dart';

/// Papéis que não são ajuste de som (o liga/desliga é o `enabled` do bloco).
const _papeisFora = {'bypass', 'reset', 'hostTempo'};

typedef DefinicaoPorUri = DefinicaoBloco Function(String uri);

class DescricaoPreset {
  const DescricaoPreset(this.definicaoDe, this.gabinetes);

  final DefinicaoPorUri definicaoDe;
  final CatalogoGabinetes gabinetes;

  /// O preset aberto: o documento e em que pé ele está na tela.
  Map<String, dynamic> preset(EstadoEditor estado, DocumentoPreset documento) => {
        'slot': estado.slot?.rotulo,
        'unsaved': estado.naoSalvo,
        'live': estado.aoVivo,
        ...conteudo(documento),
      };

  /// Só o que o arquivo do preset diz (serve também a um slot lido sem abrir).
  Map<String, dynamic> conteudo(DocumentoPreset documento) => {
        'name': documento.nome,
        'active_scene': documento.cenaAtiva,
        'scenes': [
          for (final cena in documento.cenas) {'number': cena, 'name': documento.nomeDaCena(cena) ?? 'Scene $cena'},
        ],
        'layout': 'Signal flows left to right on row 1 (columns 1-12). Row 2 is a parallel line that '
            'only exists between a Split and a Merge block on row 1.',
        'rows': {
          for (final linha in const [1, 2])
            '$linha': [for (final b in documento.blocosDaLinha(linha)) bloco(b, documento.cenaAtiva)],
        },
      };

  Map<String, dynamic> bloco(BlocoPreset bloco, int cena) {
    final definicao = definicaoDe(bloco.uri);
    return {
      'row': bloco.posicao.linha,
      'column': bloco.posicao.casa,
      'type': bloco.uri,
      'name': nomeDoBloco(definicao),
      'family': definicao.familia.name,
      'enabled': bloco.habilitadoNaCena(cena),
      'cabinet': ?_gabinete(bloco),
      'parameters': _parametros(definicao, bloco, cena),
    };
  }

  static String nomeDoBloco(DefinicaoBloco definicao) => switch (definicao.canal) {
        CanalBloco.mono => '${definicao.nome} (mono)',
        CanalBloco.estereo => '${definicao.nome} (stereo)',
        CanalBloco.unico => definicao.nome,
      };

  /// Os parâmetros que viram controle na tela; bloco fora do catálogo mostra
  /// os que o preset guarda, sem faixa (não se sabe qual é).
  static List<DefinicaoParametro> parametrosAjustaveis(DefinicaoBloco definicao) =>
      [for (final p in definicao.parametros) if (!_papeisFora.contains(p.papel)) p];

  List<Map<String, dynamic>> _parametros(DefinicaoBloco definicao, BlocoPreset bloco, int cena) {
    final ajustaveis = parametrosAjustaveis(definicao);
    if (ajustaveis.isEmpty) {
      return [for (final s in bloco.simbolosGuardados) {'symbol': s, 'value': bloco.valorNaCena(s, cena)}];
    }
    return [
      for (final p in ajustaveis) {...parametro(p, bloco.valorNaCena(p.simbolo, cena) ?? p.padrao), ..._porCena(bloco, p)},
    ];
  }

  /// Parâmetro com valor próprio em alguma cena: o valor de cada uma, para a
  /// IA ver o que difere sem trocar de cena (sem registro, vale o do bloco).
  static Map<String, dynamic> _porCena(BlocoPreset bloco, DefinicaoParametro p) {
    final cenas = [for (var cena = 1; cena <= bloco.quantidadeCenas; cena++) cena];
    if (cenas.every((c) => bloco.sobreposicaoDaCena(p.simbolo, c) == null)) return const {};
    return {
      'scene_values': {for (final c in cenas) '$c': bloco.valorNaCena(p.simbolo, c) ?? p.padrao},
    };
  }

  static Map<String, dynamic> parametro(DefinicaoParametro p, num valor) => {
        'symbol': p.simbolo,
        'name': p.nome,
        'value': valor,
        'display': exibir(p, valor),
        if (p.opcoes.isNotEmpty) 'options': p.opcoes,
        if (p.opcoes.isEmpty && !p.alternavel) ...{'min': p.minimo, 'max': p.maximo},
        'unit': ?_unidade(p),
        if (p.alternavel) 'toggle': true,
        if (p.logaritmico) 'log_scale': true,
        'default': p.padrao,
      };

  /// "1dPt" é escala 0–10 sem unidade (ver FormatadorValor).
  static String? _unidade(DefinicaoParametro p) => p.unidade == '1dPt' ? null : p.unidade;

  static String exibir(DefinicaoParametro p, num valor) =>
      FormatadorValor.formatar(p, valor, separadorDecimal: '.', ligado: 'On', desligado: 'Off');

  Map<String, dynamic>? _gabinete(BlocoPreset bloco) {
    final tipo = TipoGabinete.daUri(bloco.uri);
    if (tipo == null || !gabinetes.temEscolhas(tipo)) return null;
    final atual = gabinetes.doArquivo(tipo, bloco.arquivoDeIr);
    return {
      'model': atual?.modelo,
      'microphone': atual?.microfone,
      'position': atual?.posicao,
      'available_models': gabinetes.modelos(tipo),
    };
  }
}
