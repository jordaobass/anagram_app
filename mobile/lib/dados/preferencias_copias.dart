// Onde fica, entre uma abertura e outra, o interruptor "Backup automático
// antes de gravar" (DECISOES BK5).
import 'package:shared_preferences/shared_preferences.dart';

import '../nucleo/registro.dart';

abstract interface class PreferenciasCopias {
  /// Ligado por padrão: o backup é a rede de segurança da gravação.
  Future<bool> lerAutomatica();
  Future<void> gravarAutomatica(bool ligada);
}

class PreferenciasCopiasLocais implements PreferenciasCopias {
  static const _automatica = 'backup.automatico';

  @override
  Future<bool> lerAutomatica() async {
    try {
      return (await SharedPreferences.getInstance()).getBool(_automatica) ?? true;
    } on Object catch (erro) {
      // sem armazenamento vale o padrão: backup ligado
      registro.w('backup: preferência não foi lida', error: erro);
      return true;
    }
  }

  @override
  Future<void> gravarAutomatica(bool ligada) async {
    try {
      await (await SharedPreferences.getInstance()).setBool(_automatica, ligada);
    } on Object catch (erro) {
      registro.w('backup: preferência não foi gravada', error: erro);
    }
  }
}

