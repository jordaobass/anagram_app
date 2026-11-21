// Escolha do gabinete como a pedaleira oferece: modelo → microfone → posição,
// cada combinação um arquivo de IR. A tabela vem do Darkglass Suite (gerada
// pela ferramenta de arte, fora do git); sem ela não há o que escolher e o
// bloco segue com o IR que o preset já tem.
import '../modelo/json_util.dart';

enum TipoGabinete {
  bass('urn:darkglass-anagram:cabinet-bass'),
  guitar('urn:darkglass-anagram:cabinet-guitar'),
  artists('urn:darkglass-anagram:cabinet-artists');

  const TipoGabinete(this.uri);
  final String uri;

  /// O tipo do bloco pela uri; nulo para o que não é gabinete de fábrica
  /// (TONE3000, gabinete do usuário).
  static TipoGabinete? daUri(String uri) {
    for (final tipo in values) {
      if (tipo.uri == uri) return tipo;
    }
    return null;
  }
}

class OpcaoGabinete {
  const OpcaoGabinete(this.modelo, this.microfone, this.posicao, this.arquivo);

  final String modelo;
  final String microfone;
  final String posicao;

  /// Nome do arquivo de IR sem pasta nem extensão, como na tabela do Suite.
  final String arquivo;

  /// O valor que a pedaleira grava na property do bloco.
  String get caminho => '/factory-data/cabinets/$arquivo.dat';
}

class CatalogoGabinetes {
  const CatalogoGabinetes(this._opcoes);

  const CatalogoGabinetes.vazio() : _opcoes = const {};

  /// "gabinetes.escolhas" do indice.json: tipo -> [[modelo, microfone, posição, arquivo], …].
  factory CatalogoGabinetes.doJson(Object? secao) {
    final escolhas = mapaOuVazio(secao);
    return CatalogoGabinetes({
      for (final tipo in TipoGabinete.values)
        if (escolhas[tipo.name] case final List<dynamic> linhas)
          tipo: [
            for (final linha in linhas.whereType<List<dynamic>>())
              if (linha.length == 4)
                OpcaoGabinete('${linha[0]}', '${linha[1]}', '${linha[2]}', '${linha[3]}'),
          ],
    });
  }

  final Map<TipoGabinete, List<OpcaoGabinete>> _opcoes;

  List<OpcaoGabinete> opcoes(TipoGabinete tipo) => _opcoes[tipo] ?? const [];

  bool temEscolhas(TipoGabinete tipo) => opcoes(tipo).isNotEmpty;

  List<String> modelos(TipoGabinete tipo) => _semRepetir(opcoes(tipo).map((o) => o.modelo));

  List<String> microfones(TipoGabinete tipo, String modelo) =>
      _semRepetir(opcoes(tipo).where((o) => o.modelo == modelo).map((o) => o.microfone));

  List<String> posicoes(TipoGabinete tipo, String modelo, String microfone) => _semRepetir(opcoes(tipo)
      .where((o) => o.modelo == modelo && o.microfone == microfone)
      .map((o) => o.posicao)
      .where((p) => p.isNotEmpty));

  /// A opção do IR gravado no preset ("/factory-data/cabinets/x.dat" ou só "x");
  /// nula para IR que não está na tabela (do usuário).
  OpcaoGabinete? doArquivo(TipoGabinete tipo, String? caminho) {
    if (caminho == null) return null;
    final nome = caminho.split('/').last;
    final semExtensao = nome.endsWith('.dat') ? nome.substring(0, nome.length - 4) : nome;
    for (final opcao in opcoes(tipo)) {
      if (opcao.arquivo == semExtensao) return opcao;
    }
    return null;
  }

  /// A opção mais parecida com a escolha: mantém microfone e posição quando o
  /// modelo novo tem os dois, senão o primeiro microfone/posição dele.
  OpcaoGabinete? escolher(TipoGabinete tipo, String modelo, {String? microfone, String? posicao}) {
    final doModelo = opcoes(tipo).where((o) => o.modelo == modelo).toList();
    if (doModelo.isEmpty) return null;
    final doMicrofone = doModelo.where((o) => o.microfone == microfone).toList();
    final candidatas = doMicrofone.isEmpty ? doModelo : doMicrofone;
    return candidatas.where((o) => o.posicao == posicao).firstOrNull ?? candidatas.first;
  }

  static List<String> _semRepetir(Iterable<String> valores) => valores.toSet().toList();
}
