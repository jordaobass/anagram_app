// Onde a biblioteca de presets ficava antes da pasta (DECISOES BB4): as
// coleções importadas numa chave das preferências (BB3) e, antes delas, a
// biblioteca inteira juntada por banda (BB2). Só é lida para levar o que
// houver para a pasta, uma vez, e então apagada. Atrás de uma interface para
// os testes não dependerem do armazenamento de cada plataforma.
import 'package:shared_preferences/shared_preferences.dart';

import '../nucleo/registro.dart';

abstract interface class PreferenciasBiblioteca {
  /// As coleções importadas guardadas pelo BB3 (`{"colecoes": …}`).
  Future<String?> lerColecoes();

  /// A biblioteca guardada pelo BB2: bandas do build e importadas juntas.
  Future<String?> lerAntiga();

  Future<void> apagarTudo();
}

class PreferenciasBibliotecaLocais implements PreferenciasBiblioteca {
  static const _colecoes = 'biblioteca.colecoes';
  static const _antiga = 'biblioteca.presets';

  @override
  Future<String?> lerColecoes() => _ler(_colecoes);

  @override
  Future<String?> lerAntiga() => _ler(_antiga);

  @override
  Future<void> apagarTudo() async {
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.remove(_colecoes);
    await preferencias.remove(_antiga);
  }

  static Future<String?> _ler(String chave) async {
    try {
      return (await SharedPreferences.getInstance()).getString(chave);
    } on Object catch (erro) {
      registro.w('biblioteca: a guardada nas preferências não foi lida', error: erro);
      return null;
    }
  }
}

class PreferenciasBibliotecaEmMemoria implements PreferenciasBiblioteca {
  PreferenciasBibliotecaEmMemoria({this.colecoes, this.antiga});

  String? colecoes;
  String? antiga;

  @override
  Future<String?> lerColecoes() async => colecoes;

  @override
  Future<String?> lerAntiga() async => antiga;

  @override
  Future<void> apagarTudo() async {
    colecoes = null;
    antiga = null;
  }
}
