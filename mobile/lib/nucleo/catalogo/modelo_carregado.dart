// O arquivo que um bloco "carregador" usa: modelo neural (amp, pedal, misc),
// tom do TONE3000 (NAM ou IR) e IR do usuário. A pedaleira grava o caminho em
// `properties["1"].value`; sem ler esse valor, todos os blocos do mesmo tipo
// aparecem com o mesmo nome genérico ("TONE3000 NAM Loader").
//
// Formatos conferidos no Darkglass Suite 6.11.4 (funções jb e rQe):
//   /factory-data/neural-models/AX Komrade 1.dat            (neural de fábrica)
//   /factory-data/<pasta>/<id>/<arquivo>                    (tom de fábrica)
//   /data/user-files/neural-models-t3k/<id>/<arquivo>.nam   (tom do usuário)
//   Tone <id> - A2 model <arquivo>  /  Tone <id> - IR <arquivo>  (como o Suite exibe)
import 'variantes_uri.dart';

class ModeloCarregado {
  const ModeloCarregado({required this.nomeDoArquivo, this.idTone3000, this.doUsuario = false, this.ehIr = false});

  /// Sem caminho nem extensão: o que se mostra quando não há título melhor.
  final String nomeDoArquivo;

  /// Número do tom no TONE3000 (a pasta do arquivo); nulo fora desses blocos.
  final int? idTone3000;

  /// Arquivo enviado pela pessoa (fora de /factory-data/).
  final bool doUsuario;

  /// IR (irs-t3k, gabinete) em vez de modelo neural (neural-models-t3k).
  final bool ehIr;
}

const _urisTone3000 = {'urn:darkglass:neural:tone3000', 'urn:darkglass-anagram:cabinet-tone3000'};
const _urisComArquivo = {
  ..._urisTone3000,
  'urn:darkglass:neural:amp',
  'urn:darkglass:neural:pedal',
  'urn:darkglass:neural:misc',
  'urn:darkglass-anagram:cabinet-user',
};

final _comoOSuiteExibe = RegExp(r'^Tone (\d+) - (A2 model|IR) (.+)$');

bool ehBlocoTone3000(String uri) => _urisTone3000.contains(semSufixoDeCanal(uri));

/// O modelo do bloco [uri] com a propriedade [valor]; nulo se o bloco não
/// carrega arquivo ou o valor está vazio.
ModeloCarregado? modeloCarregadoDe(String uri, String? valor) {
  if (valor == null || valor.trim().isEmpty || !_urisComArquivo.contains(semSufixoDeCanal(uri))) return null;
  final exibido = _comoOSuiteExibe.firstMatch(valor.trim());
  if (exibido != null) {
    return ModeloCarregado(
        // o Suite já tirou a extensão (cortando no primeiro ponto)
        nomeDoArquivo: exibido.group(3)!,
        idTone3000: int.tryParse(exibido.group(1)!),
        doUsuario: true,
        ehIr: exibido.group(2) == 'IR');
  }
  return _doCaminho(uri, valor.trim());
}

ModeloCarregado _doCaminho(String uri, String caminho) {
  final partes = caminho.split('/').where((parte) => parte.isNotEmpty).toList();
  final pasta = partes.length >= 2 ? partes[partes.length - 2] : '';
  return ModeloCarregado(
    nomeDoArquivo: _semExtensao(partes.isEmpty ? caminho : partes.last),
    idTone3000: ehBlocoTone3000(uri) ? int.tryParse(pasta) : null,
    doUsuario: !caminho.startsWith('/factory-data/'),
    ehIr: partes.contains('irs-t3k') || semSufixoDeCanal(uri) == 'urn:darkglass-anagram:cabinet-tone3000',
  );
}

String _semExtensao(String nome) {
  final ponto = nome.lastIndexOf('.');
  return ponto > 0 ? nome.substring(0, ponto) : nome;
}
