// A chave "Controlar: todas as cenas / só a cena ativa" do editor, guardada
// entre uma abertura e outra. Atrás de uma interface para os testes não
// dependerem do armazenamento de cada plataforma.
import 'package:shared_preferences/shared_preferences.dart';

import '../nucleo/modelo/cenas_do_bloco.dart';
import '../nucleo/registro.dart';

abstract interface class PreferenciasCenas {
  /// Nulo enquanto a pessoa não escolheu (ou se o guardado não é conhecido).
  Future<EscopoCenas?> lerEscopo();

  Future<void> gravarEscopo(EscopoCenas escopo);
}

class PreferenciasCenasLocais implements PreferenciasCenas {
  static const _escopo = 'cenas.controlar';

  @override
  Future<EscopoCenas?> lerEscopo() async {
    try {
      final salvo = (await SharedPreferences.getInstance()).getString(_escopo);
      return EscopoCenas.values.where((e) => e.name == salvo).firstOrNull;
    } on Object catch (erro) {
      // sem armazenamento vale o padrão (só a cena ativa)
      registro.w('cenas: preferência não foi lida', error: erro);
      return null;
    }
  }

  @override
  Future<void> gravarEscopo(EscopoCenas escopo) async {
    try {
      await (await SharedPreferences.getInstance()).setString(_escopo, escopo.name);
    } on Object catch (erro) {
      registro.w('cenas: preferência não foi gravada', error: erro);
    }
  }
}
