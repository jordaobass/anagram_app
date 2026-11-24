// Onde a escolha de tema fica guardada entre uma abertura e outra do app.
// Atrás de uma interface para os testes não dependerem do armazenamento
// de cada plataforma.
import 'package:shared_preferences/shared_preferences.dart';

import '../nucleo/registro.dart';

abstract interface class PreferenciasTema {
  /// Código salvo ("sistema", "escuro", "claro") ou nulo se nunca se escolheu.
  Future<String?> ler();

  Future<void> gravar(String codigo);
}

class PreferenciasTemaLocais implements PreferenciasTema {
  static const _chave = 'tema';

  @override
  Future<String?> ler() async {
    try {
      return (await SharedPreferences.getInstance()).getString(_chave);
    } on Object catch (erro) {
      // sem armazenamento o app segue o tema do sistema
      registro.w('tema: preferência não foi lida', error: erro);
      return null;
    }
  }

  @override
  Future<void> gravar(String codigo) async {
    try {
      await (await SharedPreferences.getInstance()).setString(_chave, codigo);
    } on Object catch (erro) {
      registro.w('tema: preferência não foi gravada', error: erro);
    }
  }
}
