// Erros que não são do protocolo (WebHID bloqueado por política, canal
// nativo que sumiu) também têm de chegar à tela como falha, e fechar a
// conexão nunca pode travar o Desconectar.
import 'dart:typed_data';

import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/estado_conexao.dart';
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/midi/saida_midi.dart';
import 'package:anagram_app/nucleo/protocolo/erros_anagram.dart';
import 'package:anagram_app/nucleo/protocolo/transporte_anagram.dart';
import 'package:anagram_app/plataforma/fabrica_transporte.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';

/// Abrir falha com o erro dado: por padrão um de fora do protocolo, como o
/// DOMException do WebHID.
class _AparelhoBloqueado implements TransporteAnagram {
  _AparelhoBloqueado([this._erro]);

  final Object? _erro;

  @override
  String get descricao => 'WebHID';
  @override
  Duration get pausaSugerida => Duration.zero;
  @override
  bool get aberto => false;
  @override
  Stream<EstadoTransporte> get estados => const Stream.empty();
  @override
  Stream<Uint8List> get relatoriosRecebidos => const Stream.empty();
  @override
  Future<void> abrir() async => throw _erro ?? StateError('SecurityError: WebHID bloqueado por política');
  @override
  Future<void> enviarRelatorio(Uint8List relatorio) async {}
  @override
  Future<void> fechar() async {}
}

/// Conversa normal, mas o canal some ao fechar.
class _PedaleiraQueNaoFecha extends TransporteDemonstracao {
  _PedaleiraQueNaoFecha() : super(presets: lerPresetsDemonstracao());

  @override
  Future<void> fechar() async {
    await super.fechar();
    throw StateError('canal nativo já foi descartado');
  }
}

class _Fabrica implements FabricaTransporte {
  const _Fabrica(this._criar);

  final TransporteAnagram Function() _criar;

  @override
  SuporteAparelho get suporte => const AparelhoDisponivel('USB (teste)');
  @override
  TransporteAnagram criarAparelho() => _criar();
  @override
  SaidaMidiAnagram? criarMidi() => null;
}

ProviderContainer _container(TransporteAnagram Function() criar) =>
    ProviderContainer(overrides: [fabricaTransporteProvider.overrideWithValue(_Fabrica(criar))]);

void main() {
  test('should_report_a_connection_failure_when_opening_throws_an_error_outside_the_protocol', () async {
    final container = _container(_AparelhoBloqueado.new);

    await container.read(conexaoProvider.notifier).conectarAparelho();

    final estado = container.read(conexaoProvider);
    expect(estado, isA<FalhaDeConexao>());
    expect((estado as FalhaDeConexao).mensagem, contains('WebHID'));
  });

  test('should_explain_the_permission_and_not_blame_the_suite_when_the_system_denies_usb', () async {
    final container = _container(() => _AparelhoBloqueado(const ErroPermissaoNegada('Permissão USB negada')));

    await container.read(conexaoProvider.notifier).conectarAparelho();

    final mensagem = (container.read(conexaoProvider) as FalhaDeConexao).mensagem;
    expect(mensagem, contains('permissão'));
    expect(mensagem, isNot(contains('Darkglass Suite')));
  });

  test('should_disconnect_when_closing_the_transport_throws', () async {
    final container = _container(_PedaleiraQueNaoFecha.new);
    await container.read(conexaoProvider.notifier).conectarAparelho();
    expect(container.read(conexaoProvider), isA<Conectada>());

    await container.read(conexaoProvider.notifier).desconectar();

    expect(container.read(conexaoProvider), isA<SemConexao>());
  });
}
