// Onde ficam, entre uma abertura e outra, a escolha de verificar versão nova
// e a versão que a pessoa mandou "lembrar depois".
import 'package:shared_preferences/shared_preferences.dart';

import '../nucleo/registro.dart';

class ConfiguracaoVersao {
  const ConfiguracaoVersao({this.verificarAoAbrir = true, this.dispensada});

  /// Ligado por padrão; desligado, o app não faz nenhuma chamada de rede.
  final bool verificarAoAbrir;

  /// A última versão dispensada: só uma maior que ela volta a avisar.
  final String? dispensada;

  ConfiguracaoVersao copiar({bool? verificarAoAbrir, String? dispensada}) => ConfiguracaoVersao(
      verificarAoAbrir: verificarAoAbrir ?? this.verificarAoAbrir, dispensada: dispensada ?? this.dispensada);
}

abstract interface class PreferenciasVersao {
  Future<ConfiguracaoVersao> ler();
  Future<void> gravar(ConfiguracaoVersao configuracao);
}

class PreferenciasVersaoLocais implements PreferenciasVersao {
  static const _verificar = 'versao.verificarAoAbrir';
  static const _dispensada = 'versao.dispensada';

  @override
  Future<ConfiguracaoVersao> ler() async {
    try {
      final p = await SharedPreferences.getInstance();
      return ConfiguracaoVersao(verificarAoAbrir: p.getBool(_verificar) ?? true, dispensada: p.getString(_dispensada));
    } on Object catch (erro) {
      // sem armazenamento vale o padrão, como na primeira abertura
      registro.w('versão nova: preferência não foi lida', error: erro);
      return const ConfiguracaoVersao();
    }
  }

  @override
  Future<void> gravar(ConfiguracaoVersao configuracao) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_verificar, configuracao.verificarAoAbrir);
      if (configuracao.dispensada case final versao?) await p.setString(_dispensada, versao);
    } on Object catch (erro) {
      registro.w('versão nova: preferência não foi gravada', error: erro);
    }
  }
}
