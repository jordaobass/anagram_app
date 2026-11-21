// Onde a configuração do MCP fica entre uma abertura e outra do app: ligado,
// porta e token. O token não é segredo de servidor (o servidor só escuta no
// próprio computador), mas impede que outro programa local mexa no timbre.
import 'package:shared_preferences/shared_preferences.dart';

import '../nucleo/registro.dart';

class ConfiguracaoMcp {
  const ConfiguracaoMcp({this.ativo = false, this.porta = portaPadrao, this.token});

  static const portaPadrao = 8765;

  final bool ativo;
  final int porta;

  /// Gerado na primeira vez que a pessoa liga o MCP.
  final String? token;

  ConfiguracaoMcp copiar({bool? ativo, int? porta, String? token}) =>
      ConfiguracaoMcp(ativo: ativo ?? this.ativo, porta: porta ?? this.porta, token: token ?? this.token);
}

abstract interface class PreferenciasMcp {
  Future<ConfiguracaoMcp> ler();
  Future<void> gravar(ConfiguracaoMcp configuracao);
}

class PreferenciasMcpLocais implements PreferenciasMcp {
  static const _ativo = 'mcp.ativo';
  static const _porta = 'mcp.porta';
  static const _token = 'mcp.token';

  @override
  Future<ConfiguracaoMcp> ler() async {
    try {
      final p = await SharedPreferences.getInstance();
      return ConfiguracaoMcp(
        ativo: p.getBool(_ativo) ?? false,
        porta: p.getInt(_porta) ?? ConfiguracaoMcp.portaPadrao,
        token: p.getString(_token),
      );
    } on Object catch (erro) {
      // sem armazenamento o MCP começa desligado, como na primeira abertura
      registro.w('mcp: configuração não foi lida', error: erro);
      return const ConfiguracaoMcp();
    }
  }

  @override
  Future<void> gravar(ConfiguracaoMcp configuracao) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_ativo, configuracao.ativo);
      await p.setInt(_porta, configuracao.porta);
      if (configuracao.token case final token?) await p.setString(_token, token);
    } on Object catch (erro) {
      registro.w('mcp: configuração não foi gravada', error: erro);
    }
  }
}
