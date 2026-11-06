import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/estado_conexao.dart';
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/nucleo/protocolo/api_anagram.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';

ProviderContainer pedaleiraMuda() => ProviderContainer(overrides: [
      presetsDemonstracaoProvider.overrideWith((ref) async => lerPresetsDemonstracao()),
      ajusteDemonstracaoProvider.overrideWithValue((p) => p.naoResponder = AcoesAnagram.firmware),
    ]);

void main() {
  test('should_give_up_the_handshake_after_3_seconds_when_the_pedal_is_silent', () async {
    final container = pedaleiraMuda();
    final relogio = Stopwatch()..start();

    await container.read(conexaoProvider.notifier).conectarDemonstracao();

    expect(relogio.elapsed, lessThan(const Duration(seconds: 5)));
    expect((container.read(conexaoProvider) as FalhaDeConexao).mensagem, contains('não respondeu'));
  });

  test('should_cancel_a_pending_handshake_and_stay_disconnected', () async {
    final container = pedaleiraMuda();
    final tentativa = container.read(conexaoProvider.notifier).conectarDemonstracao();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(container.read(conexaoProvider), isA<Conectando>());

    await container.read(conexaoProvider.notifier).cancelarConexao();
    expect(container.read(conexaoProvider), isA<SemConexao>());
    await tentativa;
    expect(container.read(conexaoProvider), isA<SemConexao>(), reason: 'o fim da tentativa cancelada não muda nada');
  });
}
