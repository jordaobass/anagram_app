// Transporte por canal de plataforma: o lado nativo (Swift/IOKit no macOS,
// Kotlin/UsbManager no Android) abre a interface e move relatórios crus.
import 'dart:async';

import 'package:flutter/services.dart';

import '../nucleo/protocolo/erros_anagram.dart';
import '../nucleo/protocolo/quadros_hid.dart';
import '../nucleo/protocolo/transporte_anagram.dart';
import '../nucleo/registro.dart';

class TransporteCanalNativo with FluxosDoTransporte implements TransporteAnagram {
  TransporteCanalNativo(this.descricao, {required this.pausaSugerida});

  static const _metodos = MethodChannel('anagram_app/hid');
  static const _eventos = EventChannel('anagram_app/hid/eventos');

  /// O que o lado nativo manda pelo EventChannel quando o cabo sai.
  static const _eventoPerdido = 'perdido';

  @override
  final String descricao;

  @override
  final Duration pausaSugerida;
  StreamSubscription<dynamic>? _assinatura;
  bool _aberto = false;

  @override
  bool get aberto => _aberto;

  @override
  Future<void> abrir() async {
    anunciarEstado(EstadoTransporte.abrindo);
    try {
      await _metodos.invokeMethod<void>('abrir', {
        'idFornecedor': ProtocoloAnagram.idFornecedor,
        'idProduto': ProtocoloAnagram.idProduto,
      });
    } on PlatformException catch (erro) {
      // quem ouviu "abrindo" precisa saber que não abriu
      anunciarEstado(EstadoTransporte.fechado);
      throw _traduzir(erro);
    }
    // só depois de abrir: o EventChannel é um só para o app, e uma tentativa
    // que falha tarde (permissão cancelada no Android) cancelaria a assinatura
    // de quem conectou depois dela
    _assinatura ??= _eventos.receiveBroadcastStream().listen(_aoReceber, onError: _aoFalharEvento);
    _aberto = true;
    anunciarEstado(EstadoTransporte.aberto);
  }

  @override
  Future<void> enviarRelatorio(Uint8List relatorio) async {
    try {
      await _metodos.invokeMethod<void>('enviar', relatorio);
    } on PlatformException catch (erro) {
      throw _traduzir(erro);
    }
  }

  /// Fechar nunca lança: quem fecha está saindo (Desconectar, cabo arrancado)
  /// e não tem o que fazer com o erro além de registrá-lo.
  @override
  Future<void> fechar() async {
    _aberto = false;
    await _largarEventos();
    try {
      await _metodos.invokeMethod<void>('fechar');
    } on Exception catch (erro) {
      registro.w('$descricao: o lado nativo falhou ao fechar', error: erro);
    }
    anunciarEstado(EstadoTransporte.fechado);
  }

  void _aoReceber(dynamic evento) {
    if (evento is Uint8List) {
      entregarRelatorio(evento);
    } else if (evento == _eventoPerdido) {
      _marcarPerdido();
    }
  }

  /// Erro no EventChannel é o lado nativo dizendo que a leitura morreu: para
  /// o app, é o mesmo que o cabo sair.
  void _aoFalharEvento(Object erro) {
    registro.w('$descricao: erro no canal de eventos', error: erro);
    if (_aberto) _marcarPerdido();
  }

  void _marcarPerdido() {
    _aberto = false;
    // sem aparelho não há mais o que ouvir: solta o EventChannel
    unawaited(_largarEventos());
    anunciarEstado(EstadoTransporte.perdido);
  }

  Future<void> _largarEventos() async {
    final assinatura = _assinatura;
    _assinatura = null;
    await assinatura?.cancel();
  }

  static ErroAnagram _traduzir(PlatformException erro) {
    final detalhe = '${erro.message ?? erro.code} (${erro.code})';
    return switch (erro.code) {
      'ocupado' => ErroInterfaceOcupada(detalhe),
      'sem_permissao' => ErroPermissaoNegada('Permissão USB negada: $detalhe'),
      _ => ErroDesconectado(detalhe),
    };
  }
}
