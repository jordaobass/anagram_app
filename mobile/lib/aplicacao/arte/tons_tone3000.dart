// Os tons de fábrica do TONE3000 que o Darkglass Suite traz (factory-data):
// título e tipo de equipamento ("gear") de cada um, pelo número do tom. A
// seção "tone3000" do indice.json é gerada por ferramentas/arte_tone3000.py.
import '../../nucleo/catalogo/modelo_carregado.dart';
import '../../nucleo/modelo/json_util.dart';

class TomDeFabrica {
  const TomDeFabrica({required this.titulo, this.gear, this.foto});

  final String titulo;

  /// amp, amp-cab, cab, pedal, outboard, experimental, full-rig, space.
  final String? gear;

  /// Foto do tom (asset), quando a ferramenta a trouxe.
  final String? foto;
}

class TonsTone3000 {
  const TonsTone3000(this._porId);

  static const vazio = TonsTone3000({});

  factory TonsTone3000.doJson(Object? secao) {
    final tons = mapaOuVazio(mapaOuVazio(secao)['tons']);
    return TonsTone3000({
      for (final MapEntry(:key, :value) in tons.entries)
        if (int.tryParse(key) case final int id)
          if (textoOuNulo(mapaOuVazio(value)['titulo']) case final String titulo)
            id: TomDeFabrica(
                titulo: titulo,
                gear: textoOuNulo(mapaOuVazio(value)['gear']),
                foto: textoOuNulo(mapaOuVazio(value)['foto'])),
    });
  }

  final Map<int, TomDeFabrica> _porId;

  TomDeFabrica? deFabrica(int? id) => id == null ? null : _porId[id];
}

/// O nome legível do arquivo carregado no bloco: o título do tom de fábrica,
/// senão o nome do arquivo. Nulo quando o bloco não carrega arquivo.
String? nomeDoModeloCarregado(String uri, String? valor, TonsTone3000 tons) {
  final modelo = modeloCarregadoDe(uri, valor);
  if (modelo == null) return null;
  return tons.deFabrica(modelo.idTone3000)?.titulo ?? modelo.nomeDoArquivo;
}
