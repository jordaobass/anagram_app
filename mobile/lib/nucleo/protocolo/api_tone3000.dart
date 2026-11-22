// Leitura dos tons do TONE3000 que estão na pedaleira (fw 1.19.2.24 com a
// capacidade `t3k`). Só leitura: sem rede, sem enviar nem apagar arquivo.
// Firmware que não conhece as ações responde com erro: aí não há tons, e o
// resto do app segue (DECISOES T3K1).
import '../tone3000/tom_tone3000.dart';
import '../tone3000/tons_da_pedaleira.dart';
import 'api_anagram.dart';
import 'erros_anagram.dart';

extension ApiTone3000 on ApiAnagram {
  /// A lista de fábrica tem ~49 KB e levou 1,6 s na pedaleira real.
  static const prazoFabrica = Duration(seconds: 8);
  static const prazoPagina = Duration(seconds: 5);
  static const tonsPorPagina = 50;

  /// Com tons da pessoa às centenas, para de pedir aqui (cada página é um pedido).
  static const maximoDePaginas = 20;

  Future<List<TomTone3000>> lerTonsDeFabrica() async =>
      tonsDeFabricaDaResposta(await cliente.chamar(AcoesAnagram.tonsDeFabrica, const {}, prazoFabrica));

  Future<PaginaDeTons> lerPaginaDeTonsDoUsuario(int pagina) async => PaginaDeTons.daResposta(await cliente
      .chamar(AcoesAnagram.tonsDoUsuario, {'page': pagina, 'itemsPerPage': tonsPorPagina}, prazoPagina));

  /// Fábrica e os da pessoa; a lista da pessoa que falhar não apaga a de fábrica.
  Future<TonsDaPedaleira> lerTonsDaPedaleira() async {
    final List<TomTone3000> fabrica;
    try {
      fabrica = await lerTonsDeFabrica();
    } on ErroRespostaInvalida {
      return const TonsDaPedaleira.indisponivel();
    }
    return TonsDaPedaleira(fabrica: fabrica, doUsuario: await _tonsDoUsuarioOuNenhum());
  }

  Future<List<TomTone3000>> _tonsDoUsuarioOuNenhum() async {
    final tons = <TomTone3000>[];
    try {
      for (var pagina = 1; pagina <= maximoDePaginas; pagina++) {
        final lida = await lerPaginaDeTonsDoUsuario(pagina);
        tons.addAll(lida.tons);
        if (lida.tons.isEmpty || tons.length >= lida.total) break;
      }
    } on ErroRespostaInvalida {
      // sem a lista da pessoa, ficam os de fábrica
    }
    return tons;
  }
}
