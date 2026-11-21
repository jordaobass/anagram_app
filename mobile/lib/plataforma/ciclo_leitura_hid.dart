// O ciclo de vida de uma leitura HID, sem FFI: o que fazer com cada mensagem
// que o isolate de leitura manda e quem fecha o dispositivo. Fica separado do
// `TransporteHidapi` para ser testado sem a pedaleira nem a hidapi.
//
// Regra (ver o cabeçalho de transporte_hidapi.dart): quem fecha o dispositivo
// é o isolate, depois de sair do laço; o lado principal só pede a parada e
// libera a memória compartilhada quando o isolate termina. A exceção é o
// isolate morrer sem a parada ter sido pedida: aí ninguém mais vai fechar.
import 'dart:typed_data';

import '../nucleo/registro.dart';

/// O que o isolate de leitura manda pela porta, além dos relatórios.
abstract final class AvisosLeitura {
  /// A leitura falhou (cabo saiu); o isolate fica esperando a parada.
  static const perdido = 'perdido';
}

class CicloLeituraHid {
  CicloLeituraHid({
    required this.aoReceber,
    required this.aoPerder,
    required this.escreverParada,
    required this.fecharDispositivo,
    required this.liberarRecursos,
  });

  final void Function(Uint8List relatorio) aoReceber;
  final void Function() aoPerder;

  /// Escreve a bandeira de parada que o isolate lê a cada volta.
  final void Function() escreverParada;
  final void Function() fecharDispositivo;

  /// Devolve a bandeira (memória nativa) e fecha a porta de mensagens.
  final void Function() liberarRecursos;

  bool _paradaPedida = false;
  bool _liberada = false;

  bool get liberada => _liberada;

  /// Relatório, aviso de perda, ou `null` quando o isolate terminou (onExit).
  void receber(Object? mensagem) {
    if (mensagem is Uint8List) {
      if (!_paradaPedida) aoReceber(mensagem);
    } else if (mensagem == AvisosLeitura.perdido) {
      aoPerder();
    } else if (mensagem == null) {
      _aoTerminar();
    }
  }

  void pedirParada() {
    // depois de liberada, a bandeira é memória devolvida: não se escreve nela
    if (_paradaPedida || _liberada) return;
    _paradaPedida = true;
    escreverParada();
  }

  /// O isolate não sobe: ninguém mais vai fechar o dispositivo.
  void abortar() {
    liberar();
    fecharDispositivo();
  }

  void liberar() {
    if (_liberada) return;
    _liberada = true;
    liberarRecursos();
  }

  void _aoTerminar() {
    liberar();
    // o isolate só sai do laço depois da parada; sem ela, ele caiu antes do
    // hid_close e o dispositivo ainda está aberto
    if (_paradaPedida) return;
    registro.e('hidapi: a leitura parou sem ninguém pedir');
    fecharDispositivo();
    aoPerder();
  }
}
