// De onde vem a arte de cada bloco: miniatura opcional de terceiros (pasta
// fora do git) ou arte própria por família. A arte da própria pedaleira (par
// ligado/desligado, do Darkglass Suite) vence a de anagramanswers.com na mesma
// uri; nenhuma das duas vai para o repositório nem para as lojas (DECISOES A2, A9).
import 'dart:convert';

import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/catalogo/familia_bloco.dart';

sealed class ArteBloco {
  const ArteBloco();
}

final class ArteMiniatura extends ArteBloco {
  const ArteMiniatura(this.caminhoAsset, this.credito, {this.caminhoDesligado});
  final String caminhoAsset;
  final String credito;

  /// Imagem do bloco em bypass, quando a fonte tem uma (a arte da pedaleira tem).
  final String? caminhoDesligado;
}

final class ArteDaFamilia extends ArteBloco {
  const ArteDaFamilia(this.familia);
  final FamiliaBloco familia;
}

class IndiceMiniaturas {
  IndiceMiniaturas(this._porUri, this._porNome, this.credito);

  factory IndiceMiniaturas.doTexto(String texto) {
    final json = jsonDecode(texto) as Map<String, dynamic>;
    final porUri = <String, _Arquivos>{};
    final porNome = <String, _Arquivos>{};
    final entradas = (json['blocos'] as Map<String, dynamic>).values.cast<Map<String, dynamic>>().toList()
      ..sort((a, b) => _prioridade(a).compareTo(_prioridade(b)));
    for (final bloco in entradas) {
      final arquivos = (bloco['arquivo'] as String, bloco['arquivoDesligado'] as String?);
      final nome = normalizarNome(bloco['nome'] as String? ?? '');
      if (nome.isNotEmpty) porNome[nome] = arquivos;
      for (final uri in (bloco['uris'] as List<dynamic>)) {
        porUri['$uri'] = arquivos;
      }
    }
    return IndiceMiniaturas(porUri, porNome, json['credito'] as String? ?? '');
  }

  factory IndiceMiniaturas.vazio() => IndiceMiniaturas(const {}, const {}, '');

  final Map<String, _Arquivos> _porUri;
  final Map<String, _Arquivos> _porNome;

  /// Arte da pedaleira por último, para sobrescrever a de terceiros na mesma chave.
  static int _prioridade(Map<String, dynamic> bloco) => bloco['origem'] == 'pedaleira' ? 1 : 0;
  final String credito;

  bool get vazio => _porUri.isEmpty && _porNome.isEmpty;

  /// Casa pela uri que a pedaleira informa; senão pelo nome do bloco.
  ArteBloco arteDe(DefinicaoBloco bloco) {
    final arquivos = _porUri[bloco.uri] ?? _porNome[normalizarNome(bloco.nome)];
    if (arquivos == null) return ArteDaFamilia(bloco.familia);
    final (ligado, desligado) = arquivos;
    return ArteMiniatura(ligado, credito, caminhoDesligado: desligado);
  }

  static String normalizarNome(String nome) => nome.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '');
}

typedef _Arquivos = (String ligado, String? desligado);
