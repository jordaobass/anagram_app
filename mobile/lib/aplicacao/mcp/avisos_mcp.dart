// O que o MCP precisa que a tela mostre: a última mudança feita pela IA
// (para a pessoa saber que o som mudou sem ela mexer) e o pedido de
// gravação, que só a pessoa confirma.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class MudancaDaIa {
  const MudancaDaIa(this.numero, this.resumo);

  /// Cresce a cada mudança: duas iguais seguidas também aparecem.
  final int numero;
  final String resumo;
}

final avisosMcpProvider = NotifierProvider<AvisosMcp, MudancaDaIa?>(AvisosMcp.new);

class AvisosMcp extends Notifier<MudancaDaIa?> {
  @override
  MudancaDaIa? build() => null;

  void mudancaDaIa(String resumo) => state = MudancaDaIa((state?.numero ?? 0) + 1, resumo);
}

/// A IA pediu para gravar o preset [nomePreset] no slot [rotuloSlot].
class PedidoSalvar {
  PedidoSalvar(this.nomePreset, this.rotuloSlot);

  final String nomePreset;
  final String? rotuloSlot;
  final Completer<bool> _resposta = Completer<bool>();

  Future<bool> get resposta => _resposta.future;
  bool get respondido => _resposta.isCompleted;

  void responder(bool confirmado) {
    if (!respondido) _resposta.complete(confirmado);
  }
}

final pedidoSalvarProvider = NotifierProvider<PedidosSalvar, PedidoSalvar?>(PedidosSalvar.new);

class PedidosSalvar extends Notifier<PedidoSalvar?> {
  @override
  PedidoSalvar? build() => null;

  /// Abre o pedido e espera a pessoa; sem resposta no [prazo], `null`.
  Future<bool?> pedir(String nomePreset, String? rotuloSlot, Duration prazo) async {
    state?.responder(false);
    final pedido = PedidoSalvar(nomePreset, rotuloSlot);
    state = pedido;
    try {
      return await pedido.resposta.timeout(prazo);
    } on TimeoutException {
      return null;
    } finally {
      if (identical(state, pedido)) state = null;
    }
  }
}

/// Quanto o `save_preset` espera a pessoa responder (os testes encurtam).
final prazoConfirmarSalvarProvider = Provider<Duration>((ref) => const Duration(minutes: 2));

/// O que a IA pediu para fazer com os slots gravados (DECISOES IA9).
enum TipoOrganizar { limpar, mover }

/// A IA pediu para limpar ou mover slots: [linhas] diz o que acontece com
/// cada um, na ordem, para a pessoa confirmar o lote de uma vez.
class PedidoOrganizar {
  PedidoOrganizar(this.tipo, this.linhas);

  final TipoOrganizar tipo;
  final List<String> linhas;
  final Completer<bool> _resposta = Completer<bool>();

  Future<bool> get resposta => _resposta.future;
  bool get respondido => _resposta.isCompleted;

  void responder(bool confirmado) {
    if (!respondido) _resposta.complete(confirmado);
  }
}

final pedidoOrganizarProvider = NotifierProvider<PedidosOrganizar, PedidoOrganizar?>(PedidosOrganizar.new);

class PedidosOrganizar extends Notifier<PedidoOrganizar?> {
  @override
  PedidoOrganizar? build() => null;

  /// Abre o pedido e espera a pessoa; sem resposta no [prazo], `null`.
  Future<bool?> pedir(TipoOrganizar tipo, List<String> linhas, Duration prazo) async {
    state?.responder(false);
    final pedido = PedidoOrganizar(tipo, linhas);
    state = pedido;
    try {
      return await pedido.resposta.timeout(prazo);
    } on TimeoutException {
      return null;
    } finally {
      if (identical(state, pedido)) state = null;
    }
  }
}
