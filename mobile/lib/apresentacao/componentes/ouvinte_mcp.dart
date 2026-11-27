// O lado visível do MCP no editor: liga o servidor ao abrir o app (se a
// pessoa deixou ligado), avisa cada mudança feita pela IA — o som mudou sem
// ninguém tocar no app — e mostra os pedidos de gravar e de limpar ou mover
// slots (IA9), que só a pessoa confirma. Se a IA desistir (prazo), o diálogo
// fecha sozinho.
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
    ref.listen(pedidoOrganizarProvider, (_, pedido) {
      if (pedido != null) _perguntarOrganizar(context, pedido);
    });
    return child;
  }

  static Future<void> _perguntarOrganizar(BuildContext context, PedidoOrganizar pedido) async {
    final resposta = await showDialog<bool>(context: context, builder: (_) => _DialogoPedidoOrganizar(pedido));
    pedido.responder(resposta ?? false);
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
          style: TextButton.styleFrom(foregroundColor: context.cores.texto),
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

/// Limpar ou mover slots pedido pela IA (IA9): a lista inteira, na ordem em
/// que vai acontecer, e uma resposta para o lote.
class _DialogoPedidoOrganizar extends ConsumerWidget {
  const _DialogoPedidoOrganizar(this.pedido);

  final PedidoOrganizar pedido;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(pedidoOrganizarProvider, (_, atual) {
      if (!identical(atual, pedido) && Navigator.canPop(context)) Navigator.pop(context, false);
    });
    final l = AppLocalizations.of(context);
    final limpar = pedido.tipo == TipoOrganizar.limpar;
    return AlertDialog(
      key: const ValueKey('dialogo-pedido-organizar'),
      title: Text(limpar ? l.mcpPedidoLimparTitulo : l.mcpPedidoMoverTitulo),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Medidas.larguraDialogo),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(limpar ? l.mcpPedidoLimparTexto : l.mcpPedidoMoverTexto),
            const SizedBox(height: Espacos.m),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [for (final linha in pedido.linhas) Text(linha)],
                ),
              ),
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: context.cores.texto),
          onPressed: () => Navigator.pop(context, false),
          child: Text(l.mcpAgoraNao),
        ),
        FilledButton(
          key: const ValueKey('mcp-confirmar-organizar'),
          onPressed: () => Navigator.pop(context, true),
          child: Text(limpar ? l.mcpLimpar : l.mcpMover),
        ),
      ],
    );
  }
}
