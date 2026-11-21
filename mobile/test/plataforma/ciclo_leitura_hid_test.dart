// O ciclo da leitura USB no Linux/Windows sem a pedaleira: quem fecha o
// dispositivo, quando a perda é avisada e quando a memória compartilhada
// deixa de ser tocada. Errar aqui é fechar um handle duas vezes (queda do
// app) ou deixar a interface presa até desplugar o cabo.
import 'dart:typed_data';

import 'package:anagram_app/plataforma/ciclo_leitura_hid.dart';
import 'package:flutter_test/flutter_test.dart';

class _Registro {
  final recebidos = <Uint8List>[];
  var perdas = 0;
  var paradasEscritas = 0;
  var fechamentos = 0;
  var liberacoes = 0;

  CicloLeituraHid ciclo() => CicloLeituraHid(
        aoReceber: recebidos.add,
        aoPerder: () => perdas++,
        escreverParada: () => paradasEscritas++,
        fecharDispositivo: () => fechamentos++,
        liberarRecursos: () => liberacoes++,
      );
}

final _relatorio = Uint8List.fromList([1, 2, 3]);

void main() {
  test('should_leave_the_device_to_the_reader_and_drop_late_reports_when_the_stop_was_requested', () {
    final registro = _Registro();
    final ciclo = registro.ciclo();

    ciclo.pedirParada();
    ciclo.receber(_relatorio);
    ciclo.receber(null);

    expect(registro.paradasEscritas, 1);
    expect(registro.recebidos, isEmpty);
    expect(registro.fechamentos, 0, reason: 'o isolate fecha o dispositivo ao sair do laço');
    expect(registro.perdas, 0);
    expect(registro.liberacoes, 1);
  });

  test('should_close_the_device_and_report_the_loss_when_the_reader_dies_without_a_stop', () {
    final registro = _Registro();
    final ciclo = registro.ciclo();

    ciclo.receber(_relatorio);
    ciclo.receber(null);

    expect(registro.recebidos, [_relatorio]);
    expect(registro.fechamentos, 1);
    expect(registro.perdas, 1);
    expect(registro.liberacoes, 1);
  });

  test('should_report_the_loss_but_keep_the_device_open_when_the_reader_warns_the_cable_is_gone', () {
    final registro = _Registro();
    final ciclo = registro.ciclo();

    ciclo.receber(AvisosLeitura.perdido);

    expect(registro.perdas, 1);
    expect(registro.fechamentos, 0, reason: 'o lado principal pode estar no meio de um hid_write');
  });

  test('should_not_write_the_stop_flag_after_the_shared_memory_was_released', () {
    final registro = _Registro();
    final ciclo = registro.ciclo();
    ciclo.receber(null);

    ciclo.pedirParada();

    expect(registro.paradasEscritas, 0);
  });
}
