// L1: durante o arraste vai no máximo um documento por janela, sempre o mais
// recente, nunca dois em voo; ao soltar, o valor final vai na hora. A
// pedaleira daqui só responde quando o teste manda (Completer).
import 'dart:async';

import 'package:anagram_app/aplicacao/envio_ao_vivo.dart';
import 'package:anagram_app/nucleo/modelo/documento_preset.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pedaleira que anota cada envio e só o conclui quando o teste manda.
class _PedaleiraSegurada {
  final enviados = <String>[];
  final pendentes = <Completer<void>>[];
  int emVoo = 0;
  int maiorEmVoo = 0;

  Future<void> enviar(DocumentoPreset documento) async {
    enviados.add(documento.nome);
    emVoo++;
    if (emVoo > maiorEmVoo) maiorEmVoo = emVoo;
    final resposta = Completer<void>();
    pendentes.add(resposta);
    await resposta.future;
    emVoo--;
  }

  /// Responde o envio em voo e deixa o próximo sair.
  Future<void> responder() async {
    pendentes.removeAt(0).complete();
    await Future<void>.delayed(Duration.zero);
  }
}

const _janela = Duration(milliseconds: 30);

DocumentoPreset _documento(String nome) => DocumentoPreset.vazio(nome);

Future<void> _passarDaJanela() => Future<void>.delayed(_janela * 3);

void main() {
  late _PedaleiraSegurada pedaleira;
  late EnvioAoVivo envio;

  setUp(() {
    pedaleira = _PedaleiraSegurada();
    envio = EnvioAoVivo(pedaleira.enviar, intervalo: _janela);
  });

  test('should_send_only_the_latest_document_once_per_window_while_dragging', () async {
    envio
      ..agendar(_documento('A'))
      ..agendar(_documento('B'))
      ..agendar(_documento('C'));
    await _passarDaJanela();

    expect(pedaleira.enviados, ['C']);
  });

  test('should_never_have_two_sends_in_flight_and_send_the_latest_when_the_pedal_answers', () async {
    unawaited(envio.enviarAgora(_documento('A')));
    unawaited(envio.enviarAgora(_documento('B')));
    unawaited(envio.enviarAgora(_documento('C')));
    await Future<void>.delayed(Duration.zero);
    expect(pedaleira.enviados, ['A'], reason: 'o segundo espera o primeiro voltar');

    await pedaleira.responder();
    await pedaleira.responder();

    expect(pedaleira.enviados, ['A', 'C'], reason: 'o B ficou velho antes de sair');
    expect(pedaleira.maiorEmVoo, 1);
  });

  test('should_cancel_the_scheduled_drag_value_when_the_final_value_is_sent_now', () async {
    envio.agendar(_documento('arrastando'));
    unawaited(envio.enviarAgora(_documento('solto')));
    await Future<void>.delayed(Duration.zero);
    await pedaleira.responder();
    await _passarDaJanela();

    expect(pedaleira.enviados, ['solto']);
  });

  test('should_drop_the_scheduled_and_waiting_documents_when_cancelled', () async {
    unawaited(envio.enviarAgora(_documento('em voo')));
    await Future<void>.delayed(Duration.zero);
    unawaited(envio.enviarAgora(_documento('esperando')));
    envio
      ..agendar(_documento('agendado'))
      ..cancelar();
    await pedaleira.responder();
    await _passarDaJanela();

    expect(pedaleira.enviados, ['em voo']);
  });
}
