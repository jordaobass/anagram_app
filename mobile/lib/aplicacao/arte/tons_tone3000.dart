// Os tons de fábrica do TONE3000 que o Darkglass Suite traz (factory-data):
// título e tipo de equipamento ("gear") de cada um, pelo número do tom. A
// seção "tone3000" do indice.json é gerada por ferramentas/arte_tone3000.py.
import '../../nucleo/catalogo/modelo_carregado.dart';
import '../../nucleo/modelo/json_util.dart';
import '../../plataforma/fotos_suite.dart';
import 'indice_miniaturas.dart';

class TomDeFabrica {
  const TomDeFabrica({required this.titulo, this.gear, this.foto});

  final String titulo;

  /// amp, amp-cab, cab, pedal, outboard, experimental, full-rig, space.
  final String? gear;

  /// Foto do tom (asset), quando a ferramenta a trouxe.
  final String? foto;
}

class TonsTone3000 {
  const TonsTone3000(this._porId, {Map<String, String> porGear = const {}, this.credito})
      : _porGear = porGear;

  static const vazio = TonsTone3000({});

  factory TonsTone3000.doJson(Object? secao) => TonsTone3000(_tons(mapaOuVazio(secao)['tons']),
      porGear: {
        for (final MapEntry(:key, :value) in mapaOuVazio(mapaOuVazio(secao)['porGear']).entries)
          if (value is String) key: value,
      },
      credito: textoOuNulo(mapaOuVazio(secao)['credito']));

  static Map<int, TomDeFabrica> _tons(Object? secao) {
    final tons = mapaOuVazio(secao);
    return {
      for (final MapEntry(:key, :value) in tons.entries)
        if (int.tryParse(key) case final int id)
          if (textoOuNulo(mapaOuVazio(value)['titulo']) case final String titulo)
            id: TomDeFabrica(
                titulo: titulo,
                gear: textoOuNulo(mapaOuVazio(value)['gear']),
                foto: textoOuNulo(mapaOuVazio(value)['foto'])),
    };
  }

  final Map<int, TomDeFabrica> _porId;
  final Map<String, String> _porGear;

  /// "Fotos dos tons de fábrica: …", para a tela de créditos.
  final String? credito;

  TomDeFabrica? deFabrica(int? id) => id == null ? null : _porId[id];

  /// A arte do tom carregado num bloco TONE3000, como o Suite (função rQe):
  /// tom conhecido pela foto ou pelo ícone do tipo; tom da pessoa pela foto
  /// que o Suite baixou. Null = fica a arte do bloco.
  ArteBloco? arteDoTom(String uri, String? valor, String creditoImagens, FotosDoSuite? fotosDoSuite) {
    final modelo = ehBlocoTone3000(uri) ? modeloCarregadoDe(uri, valor) : null;
    final id = modelo?.idTone3000;
    if (modelo == null || id == null) return null;
    final tom = deFabrica(id);
    final asset = tom?.foto ?? _porGear[tom?.gear];
    if (asset != null) return ArteMiniatura(asset, creditoImagens);
    final externa = modelo.doUsuario ? fotosDoSuite?.fotoDoTom(id, ehIr: modelo.ehIr) : null;
    return externa == null ? null : ArteFotoExterna(externa);
  }
}

/// O nome legível do arquivo carregado no bloco: o título do tom de fábrica,
/// senão o nome do arquivo. Nulo quando o bloco não carrega arquivo.
String? nomeDoModeloCarregado(String uri, String? valor, TonsTone3000 tons) {
  final modelo = modeloCarregadoDe(uri, valor);
  if (modelo == null) return null;
  return tons.deFabrica(modelo.idTone3000)?.titulo ?? modelo.nomeDoArquivo;
}
