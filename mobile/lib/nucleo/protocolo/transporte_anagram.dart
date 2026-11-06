// Contrato entre o cliente do protocolo e o meio físico (USB/HID, WebHID,
// USB Host do Android ou a pedaleira simulada). O transporte só move
// relatórios de 64 bytes; enquadramento e JSON ficam no cliente.
import 'dart:typed_data';

enum EstadoTransporte { fechado, abrindo, aberto, perdido }

abstract interface class TransporteAnagram {
  /// Nome curto para a interface ("USB", "WebHID", "Demonstração").
  String get descricao;

  /// Mudanças de estado: inclusive a perda do aparelho no meio do uso.
  Stream<EstadoTransporte> get estados;

  /// Cada relatório de entrada que o aparelho mandou.
  Stream<Uint8List> get relatoriosRecebidos;

  bool get aberto;

  /// Pausa entre relatórios que este meio aguenta. A referência Python usa
  /// 10 ms; no IOKit o SetReport é síncrono, então 0 deve bastar (medir).
  Duration get pausaSugerida;

  /// Abre a interface de controle. Lança [ErroAnagram] se não der.
  Future<void> abrir();

  /// Envia um relatório de 64 bytes (o primeiro byte é o id 0x01).
  Future<void> enviarRelatorio(Uint8List relatorio);

  Future<void> fechar();
}
