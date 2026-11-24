// Onde a escolha de idioma fica guardada entre uma abertura e outra do app.
// Atrás de uma interface para os testes não dependerem do armazenamento
// de cada plataforma.
import 'package:shared_preferences/shared_preferences.dart';

import '../nucleo/registro.dart';

abstract interface class PreferenciasIdioma {
  /// Código salvo ("pt", "en", "es", "fr") ou nulo para seguir o sistema.
  Future<String?> ler();

  /// Nulo apaga a escolha (volta a seguir o sistema).
  Future<void> gravar(String? codigo);
}

class PreferenciasIdiomaLocais implements PreferenciasIdioma {
  static const _chave = 'idioma';

  @override
  Future<String?> ler() async {
    try {
      return (await SharedPreferences.getInstance()).getString(_chave);
    } on Object catch (erro) {
      // sem armazenamento o app segue no idioma do sistema
      registro.w('idioma: preferência não foi lida', error: erro);
      return null;
    }
  }

  @override
  Future<void> gravar(String? codigo) async {
    try {
      final preferencias = await SharedPreferences.getInstance();
      codigo == null ? await preferencias.remove(_chave) : await preferencias.setString(_chave, codigo);
    } on Object catch (erro) {
      registro.w('idioma: preferência não foi gravada', error: erro);
    }
  }
}
