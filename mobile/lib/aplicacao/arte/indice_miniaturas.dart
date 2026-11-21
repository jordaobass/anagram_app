// De onde vem a arte de cada bloco: miniatura opcional de terceiros (pasta
// fora do git) ou arte própria por família. A arte da própria pedaleira (par
// ligado/desligado, do Darkglass Suite) vence a de anagramanswers.com na mesma
// uri; nenhuma das duas vai para o repositório nem para as lojas (DECISOES A2, A9).
import 'dart:convert';

import '../../nucleo/catalogo/catalogo_gabinetes.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/catalogo/familia_bloco.dart';
import '../../nucleo/catalogo/variantes_uri.dart';
import '../../nucleo/modelo/json_util.dart';

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
  IndiceMiniaturas(this._porUri, this._porNome, this.credito,
      {this.temArteDaPedaleira = false,
      Map<String, (String, String?)> gabinetes = const {},
      this.escolhasDeGabinete = const CatalogoGabinetes.vazio()})
      : _gabinetes = gabinetes;

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
    return IndiceMiniaturas(porUri, porNome, json['credito'] as String? ?? '',
        temArteDaPedaleira: entradas.any((bloco) => _prioridade(bloco) == 1),
        gabinetes: _lerGabinetes(json),
        escolhasDeGabinete: CatalogoGabinetes.doJson(mapaOuVazio(json['gabinetes'])['escolhas']));
  }

  /// "gabinetes.porArquivo": nome do arquivo de IR sem extensão -> [ligada, desligada].
  static Map<String, _Arquivos> _lerGabinetes(Map<String, dynamic> json) {
    final secao = json['gabinetes'];
    final porArquivo = secao is Map<String, dynamic> ? secao['porArquivo'] : null;
    if (porArquivo is! Map<String, dynamic>) return const {};
    return {
      for (final MapEntry(:key, :value) in porArquivo.entries)
        if (value is List && value.length == 2 && value.every((v) => v is String))
          key: (value[0] as String, value[1] as String),
    };
  }

  factory IndiceMiniaturas.vazio() => IndiceMiniaturas(const {}, const {}, '');

  final Map<String, _Arquivos> _porUri;
  final Map<String, _Arquivos> _porNome;
  final Map<String, _Arquivos> _gabinetes;

  /// Modelo, microfone e posição de cada IR de gabinete (build com o Suite);
  /// vazio sem ele, e aí o bloco não oferece a escolha.
  final CatalogoGabinetes escolhasDeGabinete;

  /// Arte da pedaleira por último, para sobrescrever a de terceiros na mesma chave.
  static int _prioridade(Map<String, dynamic> bloco) => bloco['origem'] == 'pedaleira' ? 1 : 0;
  final String credito;

  bool get vazio => _porUri.isEmpty && _porNome.isEmpty;

  /// O índice traz a arte da própria pedaleira (o build com arte): a barra
  /// de cima mostra isso para a pessoa saber qual versão abriu.
  final bool temArteDaPedaleira;

  /// Casa pela uri que a pedaleira informa (com ou sem sufixo de canal);
  /// senão pelo nome do bloco. Com [arquivoIr] (gabinete), a foto do modelo
  /// daquele IR vence a genérica do bloco.
  ArteBloco arteDe(DefinicaoBloco bloco, {String? arquivoIr}) {
    final arquivos = _gabineteDe(arquivoIr) ??
        buscarPorVariantes(_porUri, bloco.uri) ??
        _porNome[normalizarNome(bloco.nome)];
    if (arquivos == null) return ArteDaFamilia(bloco.familia);
    final (ligado, desligado) = arquivos;
    return ArteMiniatura(ligado, credito, caminhoDesligado: desligado);
  }

  /// O Suite procura o nome do arquivo sem a extensão (bass) ou até o primeiro
  /// ponto (guitar e artists); aqui valem os dois.
  _Arquivos? _gabineteDe(String? caminho) {
    if (caminho == null || _gabinetes.isEmpty) return null;
    final nome = caminho.split('/').last;
    final semExtensao = nome.contains('.') ? nome.substring(0, nome.lastIndexOf('.')) : nome;
    return _gabinetes[semExtensao] ?? _gabinetes[nome.split('.').first];
  }

  static String normalizarNome(String nome) => nome.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '');
}

typedef _Arquivos = (String ligado, String? desligado);
