// O que a pessoa escolheu deixar aberto ou recolhido na tela do editor,
// guardado entre uma abertura e outra. Atrás de uma interface para os testes
// não dependerem do armazenamento de cada plataforma.
import 'package:shared_preferences/shared_preferences.dart';

import '../nucleo/registro.dart';

abstract interface class PreferenciasPaineis {
  /// Nulo enquanto a pessoa não abriu nem recolheu "Controles da pedaleira".
  Future<bool?> lerControlesAbertos();

  Future<void> gravarControlesAbertos(bool abertos);
}

class PreferenciasPaineisLocais implements PreferenciasPaineis {
  static const _controles = 'paineis.controlesAbertos';

  @override
  Future<bool?> lerControlesAbertos() async {
    try {
      return (await SharedPreferences.getInstance()).getBool(_controles);
    } on Object catch (erro) {
      // sem armazenamento vale o padrão: aberto só com controle atribuído
      registro.w('painéis: preferência não foi lida', error: erro);
      return null;
    }
  }

  @override
  Future<void> gravarControlesAbertos(bool abertos) async {
    try {
      await (await SharedPreferences.getInstance()).setBool(_controles, abertos);
    } on Object catch (erro) {
      registro.w('painéis: preferência não foi gravada', error: erro);
    }
  }
}
