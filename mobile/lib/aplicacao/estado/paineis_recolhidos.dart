// "Controles da pedaleira" aberto ou recolhido. Enquanto a pessoa não escolhe,
// vale o preset (aberto só se tiver algum controle atribuído); depois de abrir
// ou recolher uma vez, a escolha dela vale para todos e fica guardada.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dados/preferencias_paineis.dart';

final preferenciasPaineisProvider = Provider<PreferenciasPaineis>((ref) => PreferenciasPaineisLocais());

/// A escolha da pessoa, ou nulo enquanto não há (lida do disco ao abrir).
final controlesAbertosProvider = NotifierProvider<ControlesAbertos, bool?>(ControlesAbertos.new);

class ControlesAbertos extends Notifier<bool?> {
  @override
  bool? build() {
    unawaited(_carregar());
    return null;
  }

  Future<void> _carregar() async {
    final salvo = await ref.read(preferenciasPaineisProvider).lerControlesAbertos();
    // um toque antes de o disco responder vale mais que o guardado
    if (state == null && salvo != null) state = salvo;
  }

  void definir({required bool abertos}) {
    state = abertos;
    unawaited(ref.read(preferenciasPaineisProvider).gravarControlesAbertos(abertos));
  }

  /// Aberto pela escolha da pessoa ou, sem ela, se o preset tem atribuição.
  static bool resolver(bool? escolha, {required bool temAtribuicao}) => escolha ?? temAtribuicao;
}
