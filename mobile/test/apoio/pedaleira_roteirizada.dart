// Pedaleira de teste que responde o que o roteiro mandar, pedido a pedido, no
// mesmo enquadramento HID do aparelho: serve às falhas do cliente que a
// pedaleira de demonstração não sabe encenar (resposta fora de ordem, recusa
// no formato real, envio que nunca volta).
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:anagram_app/nucleo/protocolo/quadros_hid.dart';
import 'package:anagram_app/nucleo/protocolo/transporte_anagram.dart';

/// Para cada pedido completo: os quadros `{"action", "payload"}` a devolver,
/// em ordem. Lista vazia = a pedaleira cala.
typedef RoteiroPedaleira = List<Map<String, dynamic>> Function(MensagemAnagram pedido);

class PedaleiraRoteirizada with FluxosDoTransporte implements TransporteAnagram {
  PedaleiraRoteirizada(this.roteiro);

  final RoteiroPedaleira roteiro;
  final _montador = MontadorQuadros();
  final _codificador = const CodificadorQuadros();

  /// Pedidos completos que chegaram, em ordem.
  final List<MensagemAnagram> pedidos = [];

  /// O próximo envio de relatório nunca termina (USB travado no meio da
  /// escrita); os seguintes voltam ao normal.
  bool travarProximoEnvio = false;

  @override
  bool get aberto => true;

  @override
  String get descricao => 'Roteiro';

  @override
  Duration get pausaSugerida => Duration.zero;

  @override
  Future<void> abrir() async => anunciarEstado(EstadoTransporte.aberto);

  @override
  Future<void> fechar() async => anunciarEstado(EstadoTransporte.fechado);

  @override
  Future<void> enviarRelatorio(Uint8List relatorio) {
    if (travarProximoEnvio) {
      travarProximoEnvio = false;
      return Completer<void>().future;
    }
    final quadro = _montador.acrescentar(relatorio);
    if (quadro != null) {
      final pedido = MensagemAnagram('${quadro['action']}', quadro['payload'] as Map<String, dynamic>);
      pedidos.add(pedido);
      scheduleMicrotask(() => roteiro(pedido).forEach(_emitir));
    }
    return Future.value();
  }

  void _emitir(Map<String, dynamic> quadro) {
    final texto = ProtocoloAnagram.marcadorInicio + jsonEncode(quadro) + ProtocoloAnagram.marcadorFim;
    _codificador.fatiar(utf8.encode(texto)).forEach(entregarRelatorio);
  }
}
