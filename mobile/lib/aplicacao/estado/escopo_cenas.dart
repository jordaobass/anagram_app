// Onde vale a edição com uma cena ativa (DECISOES CE1): a chave "Controlar"
// do editor. Knob, campo de número, voltar ao padrão, templates e liga/desliga
// leem daqui; o MCP também, quando a IA não manda `scope`. O padrão é só a
// cena ativa: nunca muda o que as outras cenas tocam.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dados/preferencias_cenas.dart';
import '../../nucleo/modelo/cenas_do_bloco.dart';

final preferenciasCenasProvider = Provider<PreferenciasCenas>((ref) => PreferenciasCenasLocais());

final escopoCenasProvider = NotifierProvider<ControladorEscopoCenas, EscopoCenas>(ControladorEscopoCenas.new);

class ControladorEscopoCenas extends Notifier<EscopoCenas> {
  static const padrao = EscopoCenas.soNaCena;

  /// Um toque antes de o disco responder vale mais que o guardado.
  bool _escolhido = false;

  @override
  EscopoCenas build() {
    unawaited(_carregar());
    return padrao;
  }

  Future<void> _carregar() async {
    final salvo = await ref.read(preferenciasCenasProvider).lerEscopo();
    if (!ref.mounted || _escolhido || salvo == null) return;
    state = salvo;
  }

  void definir(EscopoCenas escopo) {
    _escolhido = true;
    state = escopo;
    unawaited(ref.read(preferenciasCenasProvider).gravarEscopo(escopo));
  }
}
