// Ao vivo: o que muda no preset aberto soa na pedaleira na hora, com vazão
// limitada durante o arraste, e a latência do último envio vai para o estado.
// Fica fora do ControladorEditor para ele cuidar só de abrir e gravar.
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dados/repositorio_pedaleira.dart';
import '../../nucleo/modelo/documento_preset.dart';
import '../../nucleo/protocolo/api_anagram.dart';
import '../../nucleo/resultado.dart';
import '../envio_ao_vivo.dart';
import 'estado_editor.dart';

mixin AoVivoDoEditor on Notifier<EstadoEditor> {
  EnvioAoVivo? _envio;
  StreamSubscription<Object?>? _medicoes;

  /// Repositório da conexão atual; `null` quando não há pedaleira.
  @protected
  RepositorioPedaleira? get repositorioAtual;

  Future<void> definirAoVivo(bool ligado) async {
    state = state.copiar(aoVivo: ligado);
    final atual = state.atual;
    if (ligado && atual != null) await enviarAoVivo(atual);
  }

  /// Durante o arraste: só o mais recente sai, uma vez por janela.
  @protected
  void agendarAoVivo(DocumentoPreset documento) => _envioAtivo()?.agendar(documento);

  /// Ao soltar o controle, em bypass ou cena: envia já o valor final.
  @protected
  Future<void> enviarAoVivo(DocumentoPreset documento) async {
    if (!state.aoVivo) return;
    await _envioAtivo()?.enviarAgora(documento);
  }

  /// A conexão acabou: o envio pendente e a escuta das medições morrem com ela.
  @protected
  void largarEnvioAoVivo() {
    _envio?.cancelar();
    _envio = null;
    unawaited(_medicoes?.cancel());
    _medicoes = null;
  }

  EnvioAoVivo? _envioAtivo() {
    final repositorio = repositorioAtual;
    if (repositorio == null) return null;
    return _envio ??= _criarEnvio(repositorio);
  }

  EnvioAoVivo _criarEnvio(RepositorioPedaleira repositorio) {
    _medicoes = repositorio.medicoes
        .where((m) => m.acao == AcoesAnagram.tocarAoVivo)
        .listen((m) => state = state.copiar(latencia: m.duracao));
    return EnvioAoVivo((documento) async {
      final envio = await repositorio.tocarAoVivo(documento);
      if (envio case Falha(:final erro)) state = state.copiar(aviso: erro.mensagem);
    });
  }
}
