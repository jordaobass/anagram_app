// Onde fica, entre uma abertura e outra, a escolha de procurar a pedaleira
// sozinho ao abrir o app (DECISOES CA1).
import 'package:shared_preferences/shared_preferences.dart';

import '../nucleo/registro.dart';

abstract interface class PreferenciasConexao {
  /// Ligado por padrão, como na primeira abertura.
  Future<bool> lerConectarAoAbrir();
  Future<void> gravarConectarAoAbrir(bool ligado);
}

class PreferenciasConexaoLocais implements PreferenciasConexao {
  static const _conectarAoAbrir = 'conexao.conectarAoAbrir';

  @override
  Future<bool> lerConectarAoAbrir() async {
    try {
      final p = await SharedPreferences.getInstance();
      return p.getBool(_conectarAoAbrir) ?? true;
    } on Object catch (erro) {
      // sem armazenamento vale o padrão, como na primeira abertura
      registro.w('conexão ao abrir: preferência não foi lida', error: erro);
      return true;
    }
  }

  @override
  Future<void> gravarConectarAoAbrir(bool ligado) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_conectarAoAbrir, ligado);
    } on Object catch (erro) {
      registro.w('conexão ao abrir: preferência não foi gravada', error: erro);
    }
  }
}
