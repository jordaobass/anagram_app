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
import '../../plataforma/fotos_suite.dart';
import 'tons_tone3000.dart';

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

/// Foto fora dos assets: a do tom que a pessoa baixou pelo Darkglass Suite.
final class ArteFotoExterna extends ArteBloco {
  const ArteFotoExterna(this.caminho);
  final String caminho;
}

final class ArteDaFamilia extends ArteBloco {
  const ArteDaFamilia(this.familia);
  final FamiliaBloco familia;
}

class IndiceMiniaturas {
  IndiceMiniaturas(this._porUri, this._porNome, this.credito,
      {this.temArteDaPedaleira = false,
      Map<String, (String, String?)> gabinetes = const {},
      this.escolhasDeGabinete = const CatalogoGabinetes.vazio(),
      this.tons = TonsTone3000.vazio,
      this.creditosAdicionais = const []})
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
        temArteDaPedaleira: entradas.any((bloco) => bloco['origem'] == 'pedaleira'),
        gabinetes: _lerGabinetes(json),
        escolhasDeGabinete: CatalogoGabinetes.doJson(mapaOuVazio(json['gabinetes'])['escolhas']),
        tons: TonsTone3000.doJson(json['tone3000']),
        creditosAdicionais: _creditosAdicionais(json));
  }

  /// Os créditos das outras fontes de imagem (TONE3000, Marketplace).
  static List<String> _creditosAdicionais(Map<String, dynamic> json) => [
        for (final secao in ['tone3000', 'marketplace'])
          if (textoOuNulo(mapaOuVazio(json[secao])['credito']) case final String credito) credito,
      ];

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

  /// Título, tipo e foto dos tons de fábrica do TONE3000 (build com o Suite).
  final TonsTone3000 tons;

  /// Arte da pedaleira por último, para sobrescrever as outras na mesma chave;
  /// a do Marketplace (autorizada, A17) antes dela e depois das de terceiros.
  static int _prioridade(Map<String, dynamic> bloco) => switch (bloco['origem']) {
        'pedaleira' => 2,
        'marketplace' => 1,
        _ => 0,
      };
  final String credito;

  /// Créditos das outras fontes de imagem, um por linha na tela Sobre.
  final List<String> creditosAdicionais;

  bool get vazio => _porUri.isEmpty && _porNome.isEmpty;

  /// O índice traz a arte da própria pedaleira (o build com arte): a barra
  /// de cima mostra isso para a pessoa saber qual versão abriu.
  final bool temArteDaPedaleira;

  /// Casa pela uri que a pedaleira informa (com ou sem sufixo de canal);
  /// senão pelo nome do bloco. Com [arquivoIr] (gabinete), a foto do modelo
  /// daquele IR vence a genérica do bloco; no TONE3000, a foto do tom.
  ArteBloco arteDe(DefinicaoBloco bloco, {String? arquivoIr, FotosDoSuite? fotosDoSuite}) {
    final doTom = tons.arteDoTom(bloco.uri, arquivoIr, credito, fotosDoSuite);
    if (doTom != null) return doTom;
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
