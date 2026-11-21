// Erro sem tratamento vai para o registro do app, e o tratamento padrão do
// Flutter continua acontecendo (nada é engolido).
import 'dart:ui';

import 'package:anagram_app/aplicacao/erros_nao_tratados.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

List<LogEvent> _ouvirRegistro() {
  final eventos = <LogEvent>[];
  void ouvir(LogEvent evento) => eventos.add(evento);
  Logger.addLogListener(ouvir);
  addTearDown(() => Logger.removeLogListener(ouvir));
  return eventos;
}

/// Os dois tratadores voltam ao que eram depois de cada teste.
void _restaurarTratadores() {
  final doFlutter = FlutterError.onError;
  final daPlataforma = PlatformDispatcher.instance.onError;
  addTearDown(() {
    FlutterError.onError = doFlutter;
    PlatformDispatcher.instance.onError = daPlataforma;
  });
}

void main() {
  setUp(_restaurarTratadores);

  test('should_log_a_widget_error_and_still_call_the_previous_flutter_handler', () {
    final repassados = <FlutterErrorDetails>[];
    FlutterError.onError = repassados.add;
    final eventos = _ouvirRegistro();
    final erro = StateError('quebrou no build');

    registrarErrosNaoTratados();
    FlutterError.onError!(FlutterErrorDetails(exception: erro, stack: StackTrace.current));

    expect(eventos.where((e) => e.level == Level.error).single.error, erro);
    expect(repassados.single.exception, erro, reason: 'o tratamento padrão continua');
  });

  test('should_log_an_uncaught_async_error_without_marking_it_as_handled', () {
    PlatformDispatcher.instance.onError = null;
    final eventos = _ouvirRegistro();
    final erro = StateError('Future solto falhou');

    registrarErrosNaoTratados();
    final tratado = PlatformDispatcher.instance.onError!(erro, StackTrace.current);

    expect(eventos.where((e) => e.level == Level.error).single.error, erro);
    expect(tratado, isFalse, reason: 'o motor segue relatando o erro');
  });
}
