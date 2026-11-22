// Onde a pausa entre pacotes USB escolhida pela pessoa fica guardada entre
// uma abertura e outra do app. Atrás de uma interface para os testes não
// dependerem do armazenamento de cada plataforma.
import 'package:shared_preferences/shared_preferences.dart';

import '../nucleo/registro.dart';

abstract interface class PreferenciasPausa {
  /// Milissegundos salvos, ou nulo para a sugerida pelo transporte (Auto).
  Future<int?> ler();

  /// Nulo apaga a escolha (volta ao Auto).
  Future<void> gravar(int? milissegundos);
}

class PreferenciasPausaLocais implements PreferenciasPausa {
  static const _chave = 'pausaUsbMs';

  /// Valor fora disto (arquivo mexido à mão, versão futura) vale Auto.
  static const _maxima = 50;

  @override
  Future<int?> ler() async {
    try {
      final salvo = (await SharedPreferences.getInstance()).getInt(_chave);
      return salvo != null && salvo >= 0 && salvo <= _maxima ? salvo : null;
    } on Object catch (erro) {
      // sem armazenamento o app segue no Auto
      registro.w('pausa USB: preferência não foi lida', error: erro);
      return null;
    }
  }

  @override
  Future<void> gravar(int? milissegundos) async {
    try {
      final preferencias = await SharedPreferences.getInstance();
      milissegundos == null ? await preferencias.remove(_chave) : await preferencias.setInt(_chave, milissegundos);
    } on Object catch (erro) {
      registro.w('pausa USB: preferência não foi gravada', error: erro);
    }
  }
}
