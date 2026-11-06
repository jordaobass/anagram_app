// O arquivo de preset da Anagram, guardado como o JSON que veio do aparelho.
// Toda edição copia o JSON e muda só o campo alvo: campos que o app não
// conhece (bindings, sceneNames, chaves novas de firmware) voltam intactos.
import 'dart:math';

import 'bloco_preset.dart';
import 'json_util.dart';

class DocumentoPreset {
  DocumentoPreset._(this._json);

  /// Valida o envelope `{"preset":{...},"type":"preset","version":1}`.
  /// Versão maior que 1 é aceita (campos novos são preservados) com aviso.
  factory DocumentoPreset.doJson(Map<String, dynamic> json) {
    final versao = json['version'];
    if (json['type'] != 'preset' || versao is! int || versao < 1) {
      throw const FormatException('Não é um preset da Anagram (type/version).');
    }
    if (json['preset'] is! Map<String, dynamic>) {
      throw const FormatException('Falta o objeto "preset".');
    }
    return DocumentoPreset._(copiaProfunda(json));
  }

  factory DocumentoPreset.vazio(String nome) => DocumentoPreset._({
        // como nos arquivos reais: bindings presente mesmo vazio
        'preset': {'name': nome, 'bindings': <String, dynamic>{}, 'chains': <String, dynamic>{}, 'scene': 0},
        'type': 'preset',
        'version': 1,
      });

  final Map<String, dynamic> _json;

  Map<String, dynamic> get _preset => _json['preset'] as Map<String, dynamic>;

  Map<String, dynamic> paraJson() => copiaProfunda(_json);

  /// Formato mais novo que o conhecido (1): abre e preserva, mas avisa.
  bool get versaoMaisNova => (_json['version'] as int) > 1;

  String get nome => textoOuNulo(_preset['name']) ?? 'Sem nome';
  String? get uuid => textoOuNulo(_preset['uuid']);

  /// Cena ativa de 1 a 3 (no arquivo ela conta a partir de 0).
  int get cenaAtiva => (numeroOuNulo(_preset['scene'])?.toInt() ?? 0) + 1;

  String nomeDaCena(int cena) {
    final nomes = mapaOuVazio(_preset['sceneNames']);
    final nome = nomes['$cena'];
    return nome is String && nome.trim().isNotEmpty ? nome : 'Cena $cena';
  }

  /// Blocos de uma linha (1 ou 2), em ordem de casa.
  List<BlocoPreset> blocosDaLinha(int linha) {
    final blocos = _blocosBrutos(_preset, linha);
    return [
      for (final chave in chavesNumericas(blocos))
        // casa que não é objeto (arquivo editado à mão, firmware novo) é ignorada
        if (blocos[chave] case final Map<String, dynamic> bruto)
          BlocoPreset(PosicaoBloco(linha, int.parse(chave)), bruto),
    ];
  }

  BlocoPreset? bloco(PosicaoBloco posicao) {
    final bruto = _blocosBrutos(_preset, posicao.linha)['${posicao.casa}'];
    return bruto is Map<String, dynamic> ? BlocoPreset(posicao, bruto) : null;
  }

  DocumentoPreset comNome(String nome) => _editar((p) => p['name'] = nome);

  DocumentoPreset comCena(int cena) => _editar((p) => p['scene'] = cena - 1);

  DocumentoPreset comUuid(String uuid) => _editar((p) => p['uuid'] = uuid);

  /// Liga/desliga o bloco na cena ativa. As cenas guardam só o que difere,
  /// então a base e as outras cenas não mudam; sem registro da cena, ele é
  /// criado (as cenas que não têm registro seguem a base).
  DocumentoPreset comBlocoHabilitado(PosicaoBloco posicao, bool habilitado) =>
      _editarBloco(posicao, (bloco) {
        final cenas = bloco.putIfAbsent('scenes', () => <String, dynamic>{}) as Map<String, dynamic>;
        final cena = cenas.putIfAbsent('$cenaAtiva', () => <String, dynamic>{'parameters': <dynamic>[]})
            as Map<String, dynamic>;
        cena['enabled'] = habilitado;
      });

  /// Muda um parâmetro. Se a cena ativa sobrepõe esse parâmetro, a mudança
  /// fica na cena; senão vai para o valor base (vale para todas as cenas).
  DocumentoPreset comParametro(
    PosicaoBloco posicao,
    String simbolo,
    num valor, {
    String? nomeExibicao,
  }) =>
      _editarBloco(posicao, (bloco) {
        if (_mudarSobreposicao(bloco, simbolo, valor)) return;
        _mudarBase(bloco, simbolo, valor, nomeExibicao ?? simbolo);
      });

  /// Coloca uma cópia do bloco (colar) na posição, substituindo o que houver.
  DocumentoPreset comBlocoColado(PosicaoBloco posicao, Map<String, dynamic> bloco) =>
      _editar((p) {
        final chains = p.putIfAbsent('chains', () => <String, dynamic>{}) as Map<String, dynamic>;
        final linha = chains.putIfAbsent('${posicao.linha}', () => <String, dynamic>{})
            as Map<String, dynamic>;
        final blocos = linha.putIfAbsent('blocks', () => <String, dynamic>{}) as Map<String, dynamic>;
        blocos['${posicao.casa}'] = copiaProfunda(bloco);
      });

  DocumentoPreset semBloco(PosicaoBloco posicao) =>
      _editar((p) => _blocosBrutos(p, posicao.linha).remove('${posicao.casa}'));

  bool _mudarSobreposicao(Map<String, dynamic> bloco, String simbolo, num valor) {
    final cena = mapaOuVazio(bloco['scenes'])['$cenaAtiva'];
    final lista = cena is Map<String, dynamic> ? cena['parameters'] : null;
    if (lista is! List) return false;
    for (final item in lista) {
      if (item is Map<String, dynamic> && item['symbol'] == simbolo) {
        item['value'] = valor;
        return true;
      }
    }
    return false;
  }

  void _mudarBase(Map<String, dynamic> bloco, String simbolo, num valor, String nome) {
    final parametros =
        bloco.putIfAbsent('parameters', () => <String, dynamic>{}) as Map<String, dynamic>;
    for (final entrada in parametros.values) {
      if (entrada is Map<String, dynamic> && entrada['symbol'] == simbolo) {
        entrada['value'] = valor;
        return;
      }
    }
    parametros[proximaChave(parametros)] = {'name': nome, 'symbol': simbolo, 'value': valor};
  }

  DocumentoPreset _editarBloco(PosicaoBloco posicao, void Function(Map<String, dynamic>) mudar) =>
      _editar((p) {
        final bloco = _blocosBrutos(p, posicao.linha)['${posicao.casa}'];
        if (bloco is! Map<String, dynamic>) {
          throw StateError('Não há bloco em $posicao.');
        }
        mudar(bloco);
      });

  DocumentoPreset _editar(void Function(Map<String, dynamic> preset) mudar) {
    final copia = copiaProfunda(_json);
    mudar(copia['preset'] as Map<String, dynamic>);
    return DocumentoPreset._(copia);
  }

  static Map<String, dynamic> _blocosBrutos(Map<String, dynamic> preset, int linha) =>
      mapaOuVazio(mapaOuVazio(mapaOuVazio(preset['chains'])['$linha'])['blocks']);
}

/// Id novo no formato do aparelho: 56 hexadecimais em grupos 16-8-8-24.
String novoUuidPreset([Random? aleatorio]) {
  final gerador = aleatorio ?? Random.secure();
  final hex = List.generate(56, (_) => gerador.nextInt(16).toRadixString(16)).join();
  return '${hex.substring(0, 16)}-${hex.substring(16, 24)}-'
      '${hex.substring(24, 32)}-${hex.substring(32)}';
}
