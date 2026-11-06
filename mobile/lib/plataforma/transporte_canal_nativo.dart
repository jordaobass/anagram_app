// Transporte por canal de plataforma: o lado nativo (Swift/IOKit no macOS,
// Kotlin/UsbManager no Android) abre a interface e move relatórios crus.
import 'dart:async';

import 'package:flutter/services.dart';

import '../nucleo/protocolo/erros_anagram.dart';
import '../nucleo/protocolo/quadros_hid.dart';
import '../nucleo/protocolo/transporte_anagram.dart';

class TransporteCanalNativo implements TransporteAnagram {
  TransporteCanalNativo(this.descricao, {required this.pausaSugerida});

  static const _metodos = MethodChannel('anagram_app/hid');
  static const _eventos = EventChannel('anagram_app/hid/eventos');

  @override
  final String descricao;

  @override
  final Duration pausaSugerida;
  final _estados = StreamController<EstadoTransporte>.broadcast();
  final _entrada = StreamController<Uint8List>.broadcast();
  StreamSubscription<dynamic>? _assinatura;
  bool _aberto = false;

  @override
  bool get aberto => _aberto;

  @override
  Stream<EstadoTransporte> get estados => _estados.stream;

  @override
  Stream<Uint8List> get relatoriosRecebidos => _entrada.stream;

  @override
  Future<void> abrir() async {
    _estados.add(EstadoTransporte.abrindo);
    _assinatura ??= _eventos.receiveBroadcastStream().listen(_aoReceber);
    try {
      await _metodos.invokeMethod<void>('abrir', {
        'idFornecedor': ProtocoloAnagram.idFornecedor,
        'idProduto': ProtocoloAnagram.idProduto,
      });
    } on PlatformException catch (erro) {
      await _assinatura?.cancel();
      _assinatura = null;
      throw _traduzir(erro);
    }
    _aberto = true;
    _estados.add(EstadoTransporte.aberto);
  }

  @override
  Future<void> enviarRelatorio(Uint8List relatorio) async {
    try {
      await _metodos.invokeMethod<void>('enviar', relatorio);
    } on PlatformException catch (erro) {
      throw _traduzir(erro);
    }
  }

  @override
  Future<void> fechar() async {
    _aberto = false;
    await _assinatura?.cancel();
    _assinatura = null;
    await _metodos.invokeMethod<void>('fechar');
    _estados.add(EstadoTransporte.fechado);
  }

  void _aoReceber(dynamic evento) {
    if (evento is Uint8List) {
      _entrada.add(evento);
    } else if (evento == 'perdido') {
      _aberto = false;
      // sem aparelho não há mais o que ouvir: solta o EventChannel
      unawaited(_assinatura?.cancel());
      _assinatura = null;
      _estados.add(EstadoTransporte.perdido);
    }
  }

  static ErroAnagram _traduzir(PlatformException erro) {
    final detalhe = '${erro.message ?? erro.code} (${erro.code})';
    return switch (erro.code) {
      'ocupado' => ErroInterfaceOcupada(detalhe),
      'sem_permissao' => ErroInterfaceOcupada('Permissão USB negada: $detalhe'),
      _ => ErroDesconectado(detalhe),
    };
  }
}
