// Ligar e desligar o MCP em sequência rápida (dois toques no interruptor)
// não pode deixar o servidor escutando com a opção desligada: abrir a porta
// leva tempo, e o desligar que chega nesse meio-tempo tem de valer por último.
import 'dart:async';

import 'package:anagram_app/aplicacao/mcp/controlador_mcp.dart';
import 'package:anagram_app/aplicacao/versao_app.dart';
import 'package:anagram_app/nucleo/mcp/protocolo_mcp.dart';
import 'package:anagram_app/plataforma/servidor_mcp.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

import '../apoio/app_de_teste.dart' show PreferenciasMcpEmMemoria;

/// Servidor cuja abertura da porta só termina quando o teste manda.
class _ServidorDemorado implements ServidorMcp {
  final aberturas = <Completer<void>>[];
  bool escutando = false;

  @override
  Future<int> iniciar({required int porta, required String token, required ProtocoloMcp protocolo}) async {
    final abertura = Completer<void>();
    aberturas.add(abertura);
    await abertura.future;
    escutando = true;
    return porta;
  }

  @override
  Future<void> parar() async => escutando = false;
}

Future<void> _esperarAte(bool Function() condicao) async {
  while (!condicao()) {
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
}

/// Servidor que não consegue abrir a porta, pela causa dada.
class _ServidorRecusado implements ServidorMcp {
  _ServidorRecusado(this.causa);
  final Object causa;

  @override
  Future<int> iniciar({required int porta, required String token, required ProtocoloMcp protocolo}) =>
      Future.error(ErroPortaOcupada(porta, causa));

  @override
  Future<void> parar() async {}
}

ProviderContainer _app(ServidorMcp servidor) {
  final container = ProviderContainer(overrides: [
    servidorMcpProvider.overrideWithValue(servidor),
    preferenciasMcpProvider.overrideWithValue(PreferenciasMcpEmMemoria()),
    mcpDisponivelProvider.overrideWithValue(true),
    versaoAppProvider.overrideWith((ref) async => '9.9.9'),
  ]);
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('should_stop_listening_when_mcp_is_turned_off_while_the_port_is_still_opening', () async {
    final servidor = _ServidorDemorado();
    final container = _app(servidor);
    final mcp = container.read(controladorMcpProvider.notifier);

    final ligar = mcp.ativar(true);
    await _esperarAte(() => servidor.aberturas.isNotEmpty);
    final desligar = mcp.ativar(false);
    await Future<void>.delayed(const Duration(milliseconds: 5));
    servidor.aberturas.single.complete();
    await ligar;
    await desligar;

    final estado = container.read(controladorMcpProvider);
    expect(estado.configuracao.ativo, isFalse);
    expect(estado.situacao, isA<McpDesligado>());
    expect(servidor.escutando, isFalse, reason: 'desligado na tela, a porta não pode ficar aberta');
  });

  test('should_log_the_real_cause_and_the_port_when_the_server_cannot_listen', () async {
    const causa = 'SocketException: Permission denied';
    final container = _app(_ServidorRecusado(causa));
    final eventos = <LogEvent>[];
    void ouvir(LogEvent evento) => eventos.add(evento);
    Logger.addLogListener(ouvir);
    addTearDown(() => Logger.removeLogListener(ouvir));

    await container.read(controladorMcpProvider.notifier).ativar(true);

    final aviso = eventos.where((e) => e.level == Level.warning).single;
    expect(aviso.message.toString(), contains('8765'));
    expect(aviso.error, causa, reason: 'o log guarda o motivo de verdade, não só "porta ocupada"');
    expect(container.read(controladorMcpProvider).situacao, isA<McpPortaOcupada>());
  });
}
