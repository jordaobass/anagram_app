// A consulta à última release do GitHub e o veredito sobre ela. Não leva
// nada da pessoa: só o Accept e o User-Agent que a API do GitHub pede.
import 'dart:convert';

import '../nucleo/registro.dart';
import '../nucleo/versao/release_publicada.dart';
import '../nucleo/versao/versao_semantica.dart';
import '../plataforma/consulta_http.dart';
import 'versao_nova.dart';

class BuscaUltimaRelease {
  const BuscaUltimaRelease(this._consulta);

  final ConsultaHttp _consulta;

  static final endereco = Uri.parse('https://api.github.com/repos/jordaobass/anagram_app/releases/latest');

  /// Curto: a consulta roda em segundo plano, mas não deve ficar pendurada.
  static const limite = Duration(seconds: 5);

  /// Falha de rede, limite da API ou resposta estranha viram [VersaoSemResposta],
  /// com a causa e o endereço no log; a pessoa não vê erro nenhum.
  Future<SituacaoVersao> verificar(String versaoAtual) async {
    if (VersaoSemantica.ler(versaoAtual) == null) return _semResposta('versão do app ilegível ("$versaoAtual")');
    try {
      final corpo = await _consulta.obter(endereco, cabecalhos: _cabecalhos(versaoAtual), limite: limite);
      final release = releaseDaResposta(jsonDecode(corpo));
      if (release == null) return _semResposta('resposta sem release estável válida');
      registro.i('versão nova: última publicada ${release.versao}, aberta $versaoAtual');
      return ehMaisNova(release.versao, versaoAtual) ? VersaoDisponivel(release) : const VersaoEmDia();
    } on Object catch (erro) {
      return _semResposta('$erro');
    }
  }

  static Map<String, String> _cabecalhos(String versaoAtual) =>
      {'Accept': 'application/vnd.github+json', 'User-Agent': 'AnagramApp/$versaoAtual'};

  static SituacaoVersao _semResposta(String causa) {
    registro.w('versão nova: não deu para verificar em $endereco: $causa');
    return const VersaoSemResposta();
  }
}
