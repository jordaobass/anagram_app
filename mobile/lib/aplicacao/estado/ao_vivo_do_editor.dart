// Ao vivo: o que muda no preset aberto soa na pedaleira na hora, com vazão
// limitada durante o arraste, e a latência do último envio vai para o estado.
// Fica fora do ControladorEditor para ele cuidar só de abrir e gravar.
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../avisos.dart';
import '../../dados/repositorio_pedaleira.dart';
import '../../nucleo/modelo/bloco_preset.dart';
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
    // desligado, nem o valor do arraste já agendado sai mais
    if (!ligado) descartarEnvioPendente();
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

  /// Um toque num parâmetro momentâneo (o Action do Auto Drummer): a
  /// pedaleira toca o preset com o parâmetro em 1 e, logo depois, em 0. O
  /// documento não muda (nada a salvar, nada a desfazer), então o preset
  /// nunca é gravado com o botão "apertado" (DECISOES BT2).
  Future<void> pulsar(PosicaoBloco posicao, String simbolo) async {
    final atual = state.atual;
    if (atual == null || !state.aoVivo) return;
    await enviarAoVivo(atual.comParametro(posicao, simbolo, 1));
    await Future<void>.delayed(pausaDoPulso);
    // o preset pode ter mudado durante o toque: solta sobre o atual
    final depois = state.atual;
    if (depois != null) await enviarAoVivo(depois.comParametro(posicao, simbolo, 0));
  }

  /// Quanto o parâmetro fica em 1: o bastante para o plugin ver o toque,
  /// e bem menos que o "segurar 1 s" que ele entende como outro gesto.
  static const pausaDoPulso = Duration(milliseconds: 150);

  /// O que estava agendado (arraste) ou esperando a vez deixa de valer; o
  /// envio já em voo termina, porque a pedaleira atende uma conversa por vez.
  @protected
  void descartarEnvioPendente() => _envio?.cancelar();

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
      // falha de uma conexão que já acabou: a tela de conectar já diz isso
      if (!identical(repositorioAtual, repositorio)) return;
      if (envio case Falha(:final erro)) state = state.copiar(aviso: AvisoErro(erro));
    });
  }
}
