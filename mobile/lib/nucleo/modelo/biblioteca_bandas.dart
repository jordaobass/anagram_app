// Biblioteca de presets prontos por banda (assets/biblioteca/bandas.json),
// tirados de um export do Anagram App: cada bloco com uri, posição, liga/
// desliga, valores (os que mudam por cena como {value, scenes}) e, nos
// gabinetes, modelo/microfone/posição. O preset da pedaleira é montado aqui
// com o mesmo bloco novo da biblioteca de efeitos ([blocoNovo]) e os mesmos
// helpers de cena e de IR do editor: o resultado tem o formato que a própria
// pedaleira grava. Os footswitches do arquivo ligam e desligam o bloco da
// posição indicada (modo stomp).
//
// [FonteBiblioteca] é o arquivo em si (o que se importa, exporta e guarda),
// em coleções; [BibliotecaBandas] é a mesma coisa já montada em presets da
// pedaleira, com busca e ordem para a lista.
import 'dart:convert';

import '../catalogo/biblioteca_blocos.dart';
import '../catalogo/catalogo_blocos.dart';
import '../catalogo/catalogo_gabinetes.dart';
import '../catalogo/definicao_bloco.dart';
import 'bloco_preset.dart';
import 'cenas_do_bloco.dart';
import 'controles_pedaleira.dart';
import 'documento_preset.dart';
import 'edicao_controles.dart';
import 'ir_do_gabinete.dart';
import 'json_util.dart';
import 'preset_bruto.dart';

/// O arquivo da biblioteca: coleções (o que entrou de uma vez: a do build, ou
/// um arquivo importado) com bandas e as entradas no formato do export do
/// Anagram App. É o que se importa, exporta e guarda (DECISOES BB2, BB3).
class FonteBiblioteca {
  const FonteBiblioteca(this.colecoes);

  const FonteBiblioteca.vazia() : colecoes = const [];

  /// Aceita três formatos e recusa o arquivo sem preset nenhum:
  /// - o exportado pelo app, `{"colecoes": [{"nome", "bandas"}]}`;
  /// - o de uma coleção só, `{"bandas": [{"nome", "presets"}]}` (o do build);
  /// - o export do Anagram App, `{"presets": [{"slot", "name", "blocks"}]}`,
  ///   que vira uma coleção de uma banda sem nome.
  /// Os dois últimos levam o nome do arquivo ([nomeDoArquivo]), senão
  /// "Import <data do export>".
  factory FonteBiblioteca.doTexto(String texto, {String? nomeDoArquivo}) {
    final Object? json;
    try {
      json = jsonDecode(texto);
    } on FormatException {
      throw const FormatException('o arquivo não é JSON.');
    }
    final raiz = mapaOuVazio(json);
    final data = textoOuNulo(raiz['exported']);
    final nomePadrao = _limpo(nomeDoArquivo) ?? (data == null ? 'Import' : 'Import $data');
    final colecoes = <ColecaoDaFonte>[];
    void colecao(String nome, List<BandaDaFonte> bandas) {
      if (bandas.isNotEmpty) colecoes.add(ColecaoDaFonte(nome, bandas));
    }

    if (raiz['colecoes'] is List) {
      for (final item in _lista(raiz['colecoes'])) {
        final campos = mapaOuVazio(item);
        colecao(_limpo(textoOuNulo(campos['nome'])) ?? nomePadrao, _bandas(campos['bandas']));
      }
    } else if (raiz['bandas'] is List) {
      colecao(nomePadrao, _bandas(raiz['bandas']));
    } else if (raiz['presets'] is List) {
      final presets = _entradas(raiz['presets']);
      colecao(nomePadrao, [if (presets.isNotEmpty) BandaDaFonte('', presets)]);
    }
    if (colecoes.isEmpty) throw const FormatException('não há presets de biblioteca no arquivo.');
    return FonteBiblioteca(colecoes);
  }

  static String? _limpo(String? nome) {
    final limpo = nome?.trim();
    return limpo == null || limpo.isEmpty ? null : limpo;
  }

  /// Banda sem nome vale (o export do Anagram App não tem banda): a tela só
  /// não mostra o título dela.
  static List<BandaDaFonte> _bandas(Object? bandas) => [
        for (final banda in _lista(bandas))
          if (_entradas(mapaOuVazio(banda)['presets']) case final presets when presets.isNotEmpty)
            BandaDaFonte(textoOuNulo(mapaOuVazio(banda)['nome'])?.trim() ?? '', presets),
      ];

  /// Só o que um preset da biblioteca usa: o resto do export (slot, nomes
  /// de exibição dos blocos) não volta no arquivo exportado.
  static List<Map<String, dynamic>> _entradas(Object? presets) => [
        for (final entrada in _lista(presets))
          if (entrada is Map<String, dynamic> && textoOuNulo(entrada['name']) != null && entrada['blocks'] is List)
            {
              'name': entrada['name'],
              'blocks': entrada['blocks'],
              if (entrada['footswitches'] != null) 'footswitches': entrada['footswitches'],
            },
      ];

  final List<ColecaoDaFonte> colecoes;

  int get quantidadePresets => colecoes.fold(0, (soma, colecao) => soma + colecao.quantidadePresets);

  ColecaoDaFonte? colecao(String nome) => colecoes.where((c) => c.nome == nome).firstOrNull;

  /// Cada import é uma coleção nova no fim, nunca mistura com as que já
  /// estão; nome repetido ganha " (2)", " (3)"…
  FonteBiblioteca comImportada(FonteBiblioteca outra) {
    final juntas = [...colecoes];
    for (final nova in outra.colecoes) {
      final usados = {for (final c in juntas) c.nome};
      var nome = nova.nome;
      for (var n = 2; usados.contains(nome); n++) {
        nome = '${nova.nome} ($n)';
      }
      juntas.add(ColecaoDaFonte(nome, nova.bandas));
    }
    return FonteBiblioteca(juntas);
  }

  FonteBiblioteca semColecao(String nome) => FonteBiblioteca([for (final c in colecoes) if (c.nome != nome) c]);

  /// O arquivo exportado, no formato que [FonteBiblioteca.doTexto] lê.
  String paraTexto() => const JsonEncoder.withIndent(' ').convert({
        'colecoes': [for (final colecao in colecoes) colecao.paraJson()],
      });
}

class ColecaoDaFonte {
  const ColecaoDaFonte(this.nome, this.bandas, {this.embutida = false});

  final String nome;
  final List<BandaDaFonte> bandas;

  /// A que vem no build: não se apaga nem é guardada nas preferências.
  final bool embutida;

  int get quantidadePresets => bandas.fold(0, (soma, banda) => soma + banda.presets.length);

  ColecaoDaFonte comoEmbutida() => ColecaoDaFonte(nome, bandas, embutida: true);

  Map<String, dynamic> paraJson() => {
        'nome': nome,
        'bandas': [
          for (final banda in bandas) {'nome': banda.nome, 'presets': banda.presets},
        ],
      };
}

class BandaDaFonte {
  const BandaDaFonte(this.nome, this.presets);

  /// Vazio no export do Anagram App, que não tem banda.
  final String nome;
  final List<Map<String, dynamic>> presets;
}

class PresetDaBiblioteca {
  const PresetDaBiblioteca({required this.colecao, required this.banda, required this.documento});

  final String colecao;
  final String banda;
  final DocumentoPreset documento;

  String get nome => documento.nome;
}

class BandaDaBiblioteca {
  const BandaDaBiblioteca(this.nome, this.presets);

  final String nome;
  final List<PresetDaBiblioteca> presets;
}

class ColecaoDaBiblioteca {
  const ColecaoDaBiblioteca(this.nome, this.bandas, {this.embutida = false});

  final String nome;
  final List<BandaDaBiblioteca> bandas;
  final bool embutida;

  int get quantidadePresets => bandas.fold(0, (soma, banda) => soma + banda.presets.length);
}

/// Ordem da lista: a do arquivo, ou bandas e presets pelo nome (as coleções
/// ficam sempre na ordem em que entraram, a do build primeiro).
enum OrdemBiblioteca { arquivo, nomeAZ, nomeZA }

class BibliotecaBandas {
  const BibliotecaBandas(this.colecoes);

  const BibliotecaBandas.vazia() : colecoes = const [];

  /// Preset que não monta (bloco fora do catálogo, valor estranho) fica de
  /// fora e não esconde os outros; banda ou coleção sem preset também sai.
  factory BibliotecaBandas.daFonte(FonteBiblioteca fonte, CatalogoBlocos catalogo,
      {CatalogoGabinetes gabinetes = const CatalogoGabinetes.vazio()}) {
    final colecoes = <ColecaoDaBiblioteca>[];
    for (final colecao in fonte.colecoes) {
      final bandas = <BandaDaBiblioteca>[];
      for (final banda in colecao.bandas) {
        final presets = [
          for (final entrada in banda.presets)
            if (montarPresetDaBiblioteca(entrada, catalogo, gabinetes) case final documento?)
              PresetDaBiblioteca(colecao: colecao.nome, banda: banda.nome, documento: documento),
        ];
        if (presets.isNotEmpty) bandas.add(BandaDaBiblioteca(banda.nome, presets));
      }
      if (bandas.isNotEmpty) colecoes.add(ColecaoDaBiblioteca(colecao.nome, bandas, embutida: colecao.embutida));
    }
    return BibliotecaBandas(colecoes);
  }

  factory BibliotecaBandas.doTexto(String texto, CatalogoBlocos catalogo,
          {CatalogoGabinetes gabinetes = const CatalogoGabinetes.vazio()}) =>
      BibliotecaBandas.daFonte(FonteBiblioteca.doTexto(texto), catalogo, gabinetes: gabinetes);

  final List<ColecaoDaBiblioteca> colecoes;

  bool get vazia => colecoes.isEmpty;

  Iterable<PresetDaBiblioteca> get presets => colecoes.expand((c) => c.bandas).expand((b) => b.presets);

  int get quantidadePresets => presets.length;

  /// O que a busca encontra, na [ordem] pedida. A busca ignora maiúsculas e
  /// casa com o nome do preset, da banda ou da coleção:
  /// achar a banda (ou a coleção) traz todos os presets dela.
  BibliotecaBandas filtrada({String busca = '', OrdemBiblioteca ordem = OrdemBiblioteca.arquivo}) {
    final termo = busca.trim().toLowerCase();
    bool casa(String texto) => termo.isEmpty || texto.toLowerCase().contains(termo);
    List<T> ordenar<T>(List<T> itens, String Function(T) nome) => switch (ordem) {
          OrdemBiblioteca.arquivo => itens,
          OrdemBiblioteca.nomeAZ => [...itens]..sort((a, b) => _comparar(nome(a), nome(b))),
          OrdemBiblioteca.nomeZA => [...itens]..sort((a, b) => _comparar(nome(b), nome(a))),
        };
    return BibliotecaBandas([
      for (final colecao in colecoes) ?_filtrarColecao(colecao, casa, ordenar),
    ]);
  }

  static ColecaoDaBiblioteca? _filtrarColecao(ColecaoDaBiblioteca colecao, bool Function(String) casa,
      List<T> Function<T>(List<T>, String Function(T)) ordenar) {
    final todaAColecao = casa(colecao.nome);
    final bandas = <BandaDaBiblioteca>[];
    for (final banda in colecao.bandas) {
      final todaABanda = todaAColecao || casa(banda.nome);
      final presets = [for (final p in banda.presets) if (todaABanda || casa(p.nome)) p];
      if (presets.isNotEmpty) bandas.add(BandaDaBiblioteca(banda.nome, ordenar(presets, (p) => p.nome)));
    }
    if (bandas.isEmpty) return null;
    return ColecaoDaBiblioteca(colecao.nome, ordenar(bandas, (b) => b.nome), embutida: colecao.embutida);
  }

  static int _comparar(String a, String b) => a.toLowerCase().compareTo(b.toLowerCase());
}

/// O preset pronto, na cena 1, ou nulo se algum bloco não está no catálogo.
DocumentoPreset? montarPresetDaBiblioteca(
    Map<String, dynamic> entrada, CatalogoBlocos catalogo, CatalogoGabinetes gabinetes) {
  final nome = textoOuNulo(entrada['name']);
  if (nome == null || motivoNomeInvalido(nome) != null) return null;
  try {
    var documento = DocumentoPreset.vazio(nome.trim());
    final nomesDosBlocos = <PosicaoBloco, String>{};
    for (final bloco in _lista(entrada['blocks'])) {
      final campos = mapaOuVazio(bloco);
      final posicao = PosicaoBloco(_inteiro(campos['row']), _inteiro(campos['col']));
      final definicao = catalogo.definicao(textoOuNulo(campos['type']) ?? '');
      if (definicao.parametros.isEmpty) return null;
      documento = documento.comBlocoColado(posicao, _blocoBruto(campos, definicao, gabinetes));
      nomesDosBlocos[posicao] = definicao.nome;
    }
    final footswitches = entrada['footswitches'] is Map ? mapaOuVazio(entrada['footswitches']) : _footswitchesDoTemplate(entrada);
    for (final MapEntry(key: chave, value: alvo) in footswitches.entries) {
      final id = IdControle.daChave(chave);
      final lista = _lista(alvo);
      if (id == null || lista.length != 2) continue;
      final posicao = PosicaoBloco(_inteiro(lista[0]), _inteiro(lista[1]));
      final nomeDoBloco = nomesDosBlocos[posicao];
      if (nomeDoBloco != null) documento = documento.comFootswitchNoBloco(id, posicao, nomeDoBloco);
    }
    // passa pelo envelope de novo: a validação e a normalização de cenas da
    // abertura valem também para o que foi montado aqui
    return DocumentoPreset.doJson(documento.paraJson());
  } on FormatException {
    return null;
  } on StateError {
    return null;
  }
}

/// O bloco como a pedaleira grava: valores da cena 1 no bloco (é a cena
/// ativa), as três fotos com o liga/desliga e com os parâmetros que mudam de
/// cena para cena.
Map<String, dynamic> _blocoBruto(Map<String, dynamic> campos, DefinicaoBloco definicao, CatalogoGabinetes gabinetes) {
  // cópia com tipos de JSON: o literal de [blocoNovo] infere mapas mais estreitos
  final bloco = copiaProfunda(blocoNovo(definicao));
  final habilitado = campos['enabled'] != false;
  bloco['enabled'] = habilitado;
  for (final foto in mapaOuVazio(bloco['scenes']).values) {
    mapaOuVazio(foto)['enabled'] = habilitado;
  }
  for (final MapEntry(key: simbolo, value: valor) in mapaOuVazio(campos['params']).entries) {
    final nome = definicao.parametro(simbolo)?.nome ?? simbolo;
    if (valor is num) {
      mudarValorBase(bloco, simbolo, valor, nome);
      continue;
    }
    final porCena = mapaOuVazio(valor);
    final cenas = mapaOuVazio(porCena['scenes']);
    final base = numeroOuNulo(porCena['value']) ?? numeroOuNulo(cenas['1']);
    if (base == null) throw const FormatException('parâmetro sem valor');
    mudarValorBase(bloco, simbolo, base, nome);
    for (final MapEntry(key: cena, value: valorDaCena) in cenas.entries) {
      final numero = int.tryParse(cena);
      final valorNumerico = numeroOuNulo(valorDaCena);
      if (numero != null && valorNumerico != null) gravarNaFotoDaCena(bloco, numero, simbolo, valorNumerico);
    }
  }
  final gabinete = mapaOuVazio(campos['cabinet']);
  final tipo = TipoGabinete.daUri(definicao.uri);
  final modelo = textoOuNulo(gabinete['model']);
  if (tipo != null && modelo != null) {
    final opcao = gabinetes.escolher(tipo, modelo,
        microfone: textoOuNulo(gabinete['microphone']), posicao: textoOuNulo(gabinete['position']));
    // sem a tabela de gabinetes no build, o bloco fica com o IR padrão
    if (opcao != null) gravarArquivoDeIr(bloco, opcao.caminho);
  }
  return bloco;
}

/// Export sem footswitches: o template das notas do export (Pitch Shifter na
/// casa 3, Green PiRate na 4, Sublime na 5 da linha 1) usa foot1/2/3 neles.
Map<String, dynamic> _footswitchesDoTemplate(Map<String, dynamic> entrada) {
  const template = {
    3: 'urn:darkglass:PitchShifter',
    4: 'urn:darkglass:neural-plugins:pirate',
    5: 'urn:darkglass:Sublime',
  };
  final linha1 = {
    for (final bloco in _lista(entrada['blocks']).whereType<Map<String, dynamic>>())
      if (bloco['row'] == 1) bloco['col']: bloco['type'],
  };
  if (template.entries.any((casa) => linha1[casa.key] != casa.value)) return const {};
  return const {
    'foot1': [1, 3],
    'foot2': [1, 4],
    'foot3': [1, 5],
  };
}

int _inteiro(Object? valor) =>
    numeroOuNulo(valor)?.toInt() ?? (throw const FormatException('posição de bloco inválida'));

List<dynamic> _lista(Object? valor) => valor is List ? valor : const [];
