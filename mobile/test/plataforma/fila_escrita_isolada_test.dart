// Escrita USB fora da thread da interface: cada relatório é escrito num
// isolate próprio, na ordem de chegada, e o Future só conclui depois da
// escrita. Encerrar espera as escritas na fila: o dispositivo só pode
// fechar quando nenhuma está em curso.
import 'dart:async';
import 'dart:io' show sleep;
import 'dart:typed_data';

import 'package:anagram_app/plataforma/fila_escrita_isolada.dart';
import 'package:flutter_test/flutter_test.dart';

/// Escrita falsa e lenta (bloqueia o isolate dela, como o `hid_write`):
/// devolve a ordem em que cada relatório foi escrito.
EscreverRelatorio _escritaLenta() {
  var ordem = 0;
  return (relatorio) {
    sleep(const Duration(milliseconds: 40));
    return ordem++;
  };
}

Uint8List _relatorio(int n) => Uint8List.fromList([n, ...List.filled(63, 0)]);

void main() {
  test('should_write_in_arrival_order_without_blocking_the_caller_isolate', () async {
    final fila = await FilaEscritaIsolada.iniciar(_escritaLenta);
    addTearDown(fila.encerrar);
    var tiques = 0;
    final relogio = Timer.periodic(const Duration(milliseconds: 10), (_) => tiques++);

    final ordens = await Future.wait([for (var n = 0; n < 5; n++) fila.escrever(_relatorio(n))]);
    relogio.cancel();

    expect(ordens, [0, 1, 2, 3, 4]);
    expect(tiques, greaterThan(10), reason: '200 ms de escrita não podem parar o isolate de quem chama');
  });

  test('should_finish_queued_writes_before_closing', () async {
    final fila = await FilaEscritaIsolada.iniciar(_escritaLenta);
    final escritas = [for (var n = 0; n < 3; n++) fila.escrever(_relatorio(n))];
    final concluidas = <int>[];
    for (final escrita in escritas) {
      unawaited(escrita.then(concluidas.add));
    }

    await fila.encerrar();

    expect(concluidas, [0, 1, 2], reason: 'o dispositivo fecha depois; escrita em curso usaria handle liberado');
    expect(() => fila.escrever(_relatorio(9)), throwsA(isA<StateError>()));
  });
}
