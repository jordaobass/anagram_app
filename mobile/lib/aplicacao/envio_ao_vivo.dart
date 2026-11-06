// Envio ao vivo com vazão limitada: durante o arraste manda no máximo um
// documento a cada [intervalo] (sempre o mais recente) e, ao soltar, o
// valor final na hora. Nunca há dois envios em voo: o aparelho atende uma
// conversa por vez.
import 'dart:async';

import '../nucleo/modelo/documento_preset.dart';

class EnvioAoVivo {
  EnvioAoVivo(this._enviar, {this.intervalo = const Duration(milliseconds: 100)});

  final Future<void> Function(DocumentoPreset) _enviar;
  final Duration intervalo;
  Timer? _temporizador;
  DocumentoPreset? _pendente;
  Future<void>? _emVoo;

  /// Durante o arraste: agenda o mais recente para a próxima janela.
  void agendar(DocumentoPreset documento) {
    _pendente = documento;
    _temporizador ??= Timer(intervalo, () {
      _temporizador = null;
      unawaited(_despachar());
    });
  }

  /// Ao soltar o controle (ou em bypass/cena): envia já o valor final.
  Future<void> enviarAgora(DocumentoPreset documento) {
    _temporizador?.cancel();
    _temporizador = null;
    _pendente = documento;
    return _despachar();
  }

  Future<void> _despachar() async {
    while (_emVoo != null) {
      await _emVoo;
    }
    final documento = _pendente;
    if (documento == null) return;
    _pendente = null;
    final envio = _enviar(documento);
    _emVoo = envio;
    try {
      await envio;
    } finally {
      _emVoo = null;
    }
  }

  void cancelar() {
    _temporizador?.cancel();
    _temporizador = null;
    _pendente = null;
  }
}
