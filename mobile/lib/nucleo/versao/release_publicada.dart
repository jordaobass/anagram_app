// A release que o GitHub diz ser a última, lida da resposta da API. Só entra
// o que serve ao aviso: a versão e a página para baixar.
import 'versao_semantica.dart';

class ReleasePublicada {
  const ReleasePublicada({required this.versao, required this.pagina});

  /// Sem o "v" da tag: "0.1.18".
  final String versao;

  /// A página da release no GitHub (`html_url`), aberta pelo "Baixar".
  final Uri pagina;
}

/// A release de [json] (`/releases/latest`), ou `null` se for rascunho,
/// prerelease, tag fora do semver ou página que não seja do GitHub em https:
/// o "Baixar" nunca abre endereço que a resposta inventar.
ReleasePublicada? releaseDaResposta(Object? json) {
  if (json is! Map<String, dynamic>) return null;
  if (json['draft'] == true || json['prerelease'] == true) return null;
  final (tag, pagina) = (json['tag_name'], json['html_url']);
  if (tag is! String || pagina is! String) return null;
  final versao = VersaoSemantica.ler(tag);
  final endereco = Uri.tryParse(pagina);
  if (versao == null || endereco == null || !_ehDoGithub(endereco)) return null;
  return ReleasePublicada(versao: versao.toString(), pagina: endereco);
}

bool _ehDoGithub(Uri endereco) => endereco.scheme == 'https' && endereco.host == 'github.com';
