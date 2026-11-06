// Conectar, cancelar com o diálogo de permissão do Android aberto e conectar
// de novo: a resposta atrasada ("cancelado") da primeira tentativa não pode
// desligar os relatórios da segunda, que divide o mesmo EventChannel.
import 'dart:async';

import 'package:anagram_app/plataforma/transporte_canal_nativo.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _canalEventos = 'anagram_app/hid/eventos';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final mensageiro = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  test('should_keep_receiving_reports_when_a_previous_cancelled_attempt_fails_late', () async {
    final primeiroPedido = Completer<void>();
    var pedidos = 0;
    mensageiro.setMockMethodCallHandler(const MethodChannel(_canalEventos), (_) async => null);
    mensageiro.setMockMethodCallHandler(const MethodChannel('anagram_app/hid'), (chamada) async {
      if (chamada.method != 'abrir') return null;
      // o primeiro pedido fica no diálogo de permissão até o segundo chegar
      if (++pedidos == 1) {
        await primeiroPedido.future;
        throw PlatformException(code: 'cancelado');
      }
      return null;
    });
    final abandonada = TransporteCanalNativo('USB', pausaSugerida: Duration.zero);
    final atual = TransporteCanalNativo('USB', pausaSugerida: Duration.zero);
    final recebidos = <Uint8List>[];
    atual.relatoriosRecebidos.listen(recebidos.add);

    final tentativaAbandonada = abandonada.abrir().then((_) {}, onError: (_) {});
    await atual.abrir();
    primeiroPedido.complete();
    await tentativaAbandonada;
    await mensageiro.handlePlatformMessage(
        _canalEventos, const StandardMethodCodec().encodeSuccessEnvelope(Uint8List.fromList([1, 2, 3])), (_) {});
    await Future<void>.delayed(Duration.zero);

    expect(recebidos, hasLength(1));
  });
}
