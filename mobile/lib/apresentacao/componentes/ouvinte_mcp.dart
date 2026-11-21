// O lado visível do MCP no editor: liga o servidor ao abrir o app (se a
// pessoa deixou ligado), avisa cada mudança feita pela IA — o som mudou sem
// ninguém tocar no app — e mostra o pedido de gravação, que só a pessoa
// confirma. Se a IA desistir (prazo), o diálogo fecha sozinho.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/mcp/avisos_mcp.dart';
import '../../aplicacao/mcp/controlador_mcp.dart';
import '../../l10n/app_localizations.dart';
import '../tema/tokens.dart';

class OuvinteMcp extends ConsumerWidget {
  const OuvinteMcp({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(controladorMcpProvider);
    ref.listen(avisosMcpProvider, (_, mudanca) {
      if (mudanca == null) return;
      final mensageiro = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
      mensageiro.showSnackBar(SnackBar(
        key: const ValueKey('aviso-mudanca-ia'),
        content: Text(AppLocalizations.of(context).mcpMudancaDaIa(mudanca.resumo)),
      ));
    });
    ref.listen(pedidoSalvarProvider, (_, pedido) {
      if (pedido != null) _perguntar(context, pedido);
    });
    return child;
  }

  static Future<void> _perguntar(BuildContext context, PedidoSalvar pedido) async {
    final resposta = await showDialog<bool>(context: context, builder: (_) => _DialogoPedidoSalvar(pedido));
    pedido.responder(resposta ?? false);
  }
}

class _DialogoPedidoSalvar extends ConsumerWidget {
  const _DialogoPedidoSalvar(this.pedido);

  final PedidoSalvar pedido;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // pedido vencido (prazo, ou a IA pediu de novo): este diálogo não vale mais
    ref.listen(pedidoSalvarProvider, (_, atual) {
      if (!identical(atual, pedido) && Navigator.canPop(context)) Navigator.pop(context, false);
    });
    final l = AppLocalizations.of(context);
    final slot = pedido.rotuloSlot;
    return AlertDialog(
      key: const ValueKey('dialogo-pedido-salvar'),
      title: Text(l.mcpPedidoSalvarTitulo),
      content: Text(slot == null ? l.mcpPedidoSalvarSemSlot(pedido.nomePreset) : l.mcpPedidoSalvarTexto(pedido.nomePreset, slot)),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Cores.texto),
          onPressed: () => Navigator.pop(context, false),
          child: Text(l.mcpAgoraNao),
        ),
        FilledButton(
          key: const ValueKey('mcp-confirmar-salvar'),
          onPressed: () => Navigator.pop(context, true),
          child: Text(l.mcpSalvar),
        ),
      ],
    );
  }
}
