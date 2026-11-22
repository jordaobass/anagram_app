// O arquivo de preset da Anagram, guardado como o JSON que veio do aparelho.
// Toda edição copia o JSON e muda só o campo alvo: campos que o app não
// conhece (bindings, sceneNames, chaves novas de firmware) voltam intactos.
import 'dart:convert';
import 'dart:math';

import '../protocolo/quadros_hid.dart';
import 'bloco_preset.dart';
import 'cenas_do_bloco.dart';
import 'controles_pedaleira.dart';
import 'ir_do_gabinete.dart';
import 'json_util.dart';
import 'preset_bruto.dart';
import 'vinculos_preset.dart';

class DocumentoPreset {
  DocumentoPreset._(this._json);

  /// Valida o envelope `{"preset":{...},"type":"preset","version":1}`.
  /// Versão maior que 1 é aceita (campos novos são preservados) com aviso.
  /// Preset com marcador de quadro num texto também é recusado: ele não
  /// teria como ir para a pedaleira (arquivo importado, DECISOES RN4).
  factory DocumentoPreset.doJson(Map<String, dynamic> json) {
    final versao = json['version'];
    if (json['type'] != 'preset' || versao is! int || versao < 1) {
      throw const FormatException('Não é um preset da Anagram (type/version).');
    }
    if (json['preset'] is! Map<String, dynamic>) {
      throw const FormatException('Falta o objeto "preset".');
    }
    _recusarMarcadorDeQuadro(json);
    return DocumentoPreset._(_comCenaAtivaNoBloco(copiaProfunda(json)));
  }

  /// A pedaleira grava o bloco com os valores da cena ativa (é o que ela
  /// toca). Preset que não segue isso (escrito à mão, de outro editor) é
  /// acertado ao abrir, com os valores que a tela já mostra para a cena; num
  /// preset da pedaleira nada muda.
  static Map<String, dynamic> _comCenaAtivaNoBloco(Map<String, dynamic> json) {
    final preset = json['preset'] as Map<String, dynamic>;
    final ativa = (numeroOuNulo(preset['scene'])?.toInt() ?? 0) + 1;
    for (final bloco in todosOsBlocos(preset)) {
      carregarCena(bloco, ativa);
    }
    return json;
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

  /// O preset sem a cena ativa, serializado uma vez por documento. Trocar de
  /// cena é tocar, não editar; e o editor compara isto a cada arraste de knob,
  /// então refazer o JSON a cada comparação custaria seis passagens por quadro.
  late final String assinaturaSemCena = _assinaturaSemCena();

  String _assinaturaSemCena() {
    final json = paraJson();
    final preset = json['preset'] as Map<String, dynamic>..remove('scene');
    todosOsBlocos(preset).forEach(semEstadoDaCena);
    return jsonEncode(json);
  }

  /// O nome que o preset dá à cena, ou nulo (a tela mostra "Cena N" no
  /// idioma em uso).
  String? nomeDaCena(int cena) {
    final nomes = mapaOuVazio(_preset['sceneNames']);
    final nome = nomes['$cena'];
    return nome is String && nome.trim().isNotEmpty ? nome : null;
  }

  /// Blocos de uma linha (1 ou 2), em ordem de casa.
  List<BlocoPreset> blocosDaLinha(int linha) {
    final blocos = blocosBrutos(_preset, linha);
    return [
      for (final chave in chavesNumericas(blocos))
        // casa que não é objeto (arquivo editado à mão, firmware novo) é ignorada
        if (blocos[chave] case final Map<String, dynamic> bruto)
          BlocoPreset(PosicaoBloco(linha, int.parse(chave)), bruto),
    ];
  }

  BlocoPreset? bloco(PosicaoBloco posicao) {
    final bruto = blocosBrutos(_preset, posicao.linha)['${posicao.casa}'];
    return bruto is Map<String, dynamic> ? BlocoPreset(posicao, bruto) : null;
  }

  /// Footswitches, pots e pedal de expressão que o preset usa.
  Map<IdControle, ControlePedaleira> get controles => lerControles(_preset);

  /// Edita os controles no preset copiado (as operações de
  /// `controles_pedaleira.dart`); o resto do arquivo não muda.
  DocumentoPreset comControles(void Function(Map<String, dynamic> preset) mudar) => _editar(mudar);

  DocumentoPreset comNome(String nome) => _editar((p) => p['name'] = nome);

  /// Troca a cena ativa: cada bloco guarda a foto da cena que sai e recebe a
  /// da que entra, porque a pedaleira toca o que está no bloco.
  DocumentoPreset comCena(int cena) => _editar((p) {
        final saindo = cenaAtiva;
        if (cena != saindo) {
          for (final bloco in todosOsBlocos(p)) {
            guardarFotoDaCena(bloco, saindo);
            carregarCena(bloco, cena);
          }
        }
        p['scene'] = cena - 1;
      });

  DocumentoPreset comUuid(String uuid) => _editar((p) => p['uuid'] = uuid);

  /// Troca o arquivo do bloco: IR do gabinete ou tom/modelo do TONE3000.
  DocumentoPreset comArquivoDeIr(PosicaoBloco posicao, String caminho) =>
      _editarBloco(posicao, (bloco) => gravarArquivoDeIr(bloco, caminho));

  /// Liga/desliga o bloco na cena ativa: no próprio bloco (é o que a pedaleira
  /// toca ao vivo) e na foto da cena; as outras cenas não mudam.
  DocumentoPreset comBlocoHabilitado(PosicaoBloco posicao, bool habilitado) =>
      _editarBloco(posicao, (bloco) {
        // as outras cenas guardam o liga/desliga que tinham antes: senão,
        // sem registro, passariam a seguir o bloco, que vai mudar agora
        fixarLigaNasOutrasCenas(bloco, cenaAtiva);
        bloco['enabled'] = habilitado;
        final cenas = bloco.putIfAbsent('scenes', () => <String, dynamic>{}) as Map<String, dynamic>;
        final cena = cenas.putIfAbsent('$cenaAtiva', () => <String, dynamic>{'parameters': <dynamic>[]})
            as Map<String, dynamic>;
        cena['enabled'] = habilitado;
      });

  /// Muda um parâmetro no bloco (o que soa) e nas fotos de cena conforme o
  /// [escopo]. O padrão é a regra do knob (DECISOES C1): se a cena ativa tem
  /// valor próprio para ele, muda também na foto dela; as outras cenas não
  /// mudam. Em [EscopoParametro.soNaCena], [valorAntes] é o valor que as outras
  /// cenas sem registro tinham (o padrão do catálogo, se o bloco não o guarda).
  DocumentoPreset comParametro(
    PosicaoBloco posicao,
    String simbolo,
    num valor, {
    String? nomeExibicao,
    EscopoParametro escopo = EscopoParametro.comoNoKnob,
    num? valorAntes,
  }) =>
      _editarBloco(posicao, (bloco) {
        switch (escopo) {
          case EscopoParametro.comoNoKnob:
            if (!mudarSobreposicaoDaCena(bloco, cenaAtiva, simbolo, valor)) {
              gravarNaCenaAtiva(bloco, cenaAtiva, simbolo, valor);
            }
          case EscopoParametro.soNaCena:
            fixarValorNasOutrasCenas(bloco, cenaAtiva, simbolo, valorNoBloco(bloco, simbolo) ?? valorAntes ?? valor);
            gravarNaFotoDaCena(bloco, cenaAtiva, simbolo, valor);
          case EscopoParametro.todasAsCenas:
            mudarEmTodasAsFotos(bloco, simbolo, valor);
        }
        mudarValorBase(bloco, simbolo, valor, nomeExibicao ?? simbolo);
      });

  /// Coloca uma cópia do bloco (colar, efeito novo da biblioteca) na posição,
  /// substituindo o que houver.
  /// Colar por cima de um bloco o substitui: os controles que mexiam nele
  /// são soltos, como ao remover, senão passariam a mexer no bloco colado.
  /// O bloco copiado traz o som da cena em que foi copiado: ele vira a foto
  /// da cena ativa daqui, senão a tela mostraria a foto antiga desta cena
  /// enquanto a pedaleira toca a outra (DECISOES RV1).
  DocumentoPreset comBlocoColado(PosicaoBloco posicao, Map<String, dynamic> bloco) => _editar((p) {
        if (blocosBrutos(p, posicao.linha).containsKey('${posicao.casa}')) soltarVinculos(p, posicao);
        final copia = copiaProfunda(bloco);
        guardarFotoDaCena(copia, cenaAtiva);
        colocarBloco(p, posicao, copia);
      });

  /// Muda o bloco de casa; com a casa ocupada, os dois trocam de lugar.
  /// Parâmetros e cenas moram dentro do bloco e vão junto; os controles
  /// (pots, footswitches, pedal) são remapeados para seguir o bloco.
  DocumentoPreset comBlocoMovido(PosicaoBloco de, PosicaoBloco para) => _editar((p) {
        final origem = blocosBrutos(p, de.linha).remove('${de.casa}');
        if (origem is! Map<String, dynamic>) throw StateError('Não há bloco em $de.');
        final destino = blocosBrutos(p, para.linha).remove('${para.casa}');
        colocarBloco(p, para, origem);
        if (destino is Map<String, dynamic>) colocarBloco(p, de, destino);
        trocarVinculos(p, de, para);
      });

  /// Remove o bloco e solta os controles que mexiam nele: senão o próximo
  /// bloco posto na casa herdaria o pot ou o pedal sem a pessoa pedir.
  DocumentoPreset semBloco(PosicaoBloco posicao) => _editar((p) {
        blocosBrutos(p, posicao.linha).remove('${posicao.casa}');
        soltarVinculos(p, posicao);
      });

  DocumentoPreset _editarBloco(PosicaoBloco posicao, void Function(Map<String, dynamic>) mudar) =>
      _editar((p) {
        final bloco = blocosBrutos(p, posicao.linha)['${posicao.casa}'];
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
}

/// Preset com marcador de quadro num texto não teria como ir para a pedaleira.
void _recusarMarcadorDeQuadro(Map<String, dynamic> json) {
  final texto = jsonEncode(json);
  for (final marcador in ProtocoloAnagram.marcadores) {
    if (texto.contains(marcador)) {
      throw FormatException('um texto do preset (nome, cena ou controle) contém "$marcador", '
          'que a pedaleira lê como marcador de mensagem.');
    }
  }
}

/// Id novo no formato do aparelho: 56 hexadecimais em grupos 16-8-8-24.
String novoUuidPreset([Random? aleatorio]) {
  final gerador = aleatorio ?? Random.secure();
  final hex = List.generate(56, (_) => gerador.nextInt(16).toRadixString(16)).join();
  return '${hex.substring(0, 16)}-${hex.substring(16, 24)}-'
      '${hex.substring(24, 32)}-${hex.substring(32)}';
}

/// Por que [nome] não serve para um preset, ou `null` se serve. O nome viaja
/// dentro do quadro HID: com um marcador de quadro nele, a remontagem da
/// resposta corta a mensagem no lugar errado e a leitura do preset falha.
NomeInvalido? motivoNomeInvalido(String nome) {
  final limpo = nome.trim();
  if (limpo.isEmpty) return const NomeVazio();
  for (final marcador in ProtocoloAnagram.marcadores) {
    if (limpo.contains(marcador)) return NomeComMarcador(marcador);
  }
  return null;
}

/// Por que um nome não serve; a frase fica na tela, no idioma em uso.
sealed class NomeInvalido {
  const NomeInvalido();
}

final class NomeVazio extends NomeInvalido {
  const NomeVazio();
}

final class NomeComMarcador extends NomeInvalido {
  const NomeComMarcador(this.marcador);
  final String marcador;
}
