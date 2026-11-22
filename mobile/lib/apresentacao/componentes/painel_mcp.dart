// Seção "IA local (MCP)" das Configurações: ligar, ver em que pé está,
// trocar a porta, ver/copiar/trocar o token e copiar a configuração pronta
// para o cliente de IA. O token fica oculto até a pessoa pedir.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/mcp/controlador_mcp.dart';
import '../../aplicacao/mcp/trechos_configuracao.dart';
import '../../l10n/app_localizations.dart';
import '../tema/tokens.dart';
import 'campo_porta_mcp.dart';
import 'dialogo_confirmar.dart';

class PainelMcp extends ConsumerWidget {
  const PainelMcp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(controladorMcpProvider);
    final controlador = ref.read(controladorMcpProvider.notifier);
    final l = AppLocalizations.of(context);
    final tema = Theme.of(context).textTheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SwitchListTile(
        key: const ValueKey('mcp-permitir'),
        contentPadding: EdgeInsets.zero,
        activeThumbColor: context.cores.tally,
        title: Text(l.mcpPermitir),
        subtitle: Text(l.mcpPermitirTexto),
        value: estado.configuracao.ativo,
        onChanged: controlador.ativar,
      ),
      const SizedBox(height: Espacos.s),
      _SituacaoMcp(estado.situacao),
      const SizedBox(height: Espacos.l),
      CampoPortaMcp(porta: estado.configuracao.porta, aoAplicar: controlador.definirPorta),
      if (estado.configuracao.token case final token?) ...[
        const SizedBox(height: Espacos.l),
        _Token(token),
        const SizedBox(height: Espacos.l),
        _CopiarConfiguracao(endereco: _endereco(estado), token: token),
      ],
      const SizedBox(height: Espacos.l),
      Text(l.mcpLimitacoes, style: tema.bodyMedium?.copyWith(color: context.cores.textoSecundario)),
    ]);
  }

  static String _endereco(EstadoMcp estado) => switch (estado.situacao) {
        final McpEscutando escutando => escutando.endereco,
        _ => McpEscutando(estado.configuracao.porta).endereco,
      };
}

/// LED + frase: escutando (verde), porta ocupada (erro), desligado (cinza).
class _SituacaoMcp extends StatelessWidget {
  const _SituacaoMcp(this.situacao);

  final SituacaoMcp situacao;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final (cor, texto) = switch (situacao) {
      McpDesligado() => (context.cores.ledDesligado, l.mcpEstadoDesligado),
      McpIniciando() => (context.cores.tallyTinta, l.mcpEstadoIniciando),
      final McpEscutando s => (context.cores.ledLigado, l.mcpEstadoEscutando(s.endereco)),
      McpPortaOcupada(:final porta) => (context.cores.erro, l.mcpEstadoPortaOcupada(porta)),
    };
    return Semantics(
      liveRegion: true,
      child: Row(key: const ValueKey('mcp-situacao'), children: [
        Container(width: Medidas.led, height: Medidas.led, decoration: BoxDecoration(color: cor, shape: BoxShape.circle)),
        const SizedBox(width: Espacos.s),
        Expanded(child: SelectableText(texto, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: cor == context.cores.erro ? cor : null))),
      ]),
    );
  }
}

class _Token extends ConsumerStatefulWidget {
  const _Token(this.token);

  final String token;

  @override
  ConsumerState<_Token> createState() => _EstadoToken();
}

class _EstadoToken extends ConsumerState<_Token> {
  bool _visivel = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tema = Theme.of(context).textTheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l.mcpToken, style: tema.titleSmall),
      Text(l.mcpTokenTexto, style: tema.bodyMedium?.copyWith(color: context.cores.textoSecundario)),
      const SizedBox(height: Espacos.xs),
      Row(children: [
        Expanded(
          child: SelectableText(_visivel ? widget.token : '•' * 16,
              key: const ValueKey('mcp-token'), maxLines: 1, style: tema.bodyLarge),
        ),
        IconButton(
          tooltip: _visivel ? l.mcpOcultarToken : l.mcpMostrarToken,
          icon: Icon(_visivel ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _visivel = !_visivel),
        ),
        IconButton(
          tooltip: l.mcpCopiarToken,
          icon: const Icon(Icons.copy),
          onPressed: () => copiarComAviso(context, widget.token),
        ),
        TextButton(key: const ValueKey('mcp-novo-token'), onPressed: _gerarNovo, child: Text(l.mcpGerarNovoToken)),
      ]),
    ]);
  }

  Future<void> _gerarNovo() async {
    final l = AppLocalizations.of(context);
    final sim = await confirmar(context,
        titulo: l.mcpGerarNovoTitulo,
        texto: l.mcpGerarNovoTexto,
        rotuloCancelar: l.cancelar,
        rotuloConfirmar: l.mcpGerarNovoToken,
        chaveConfirmar: const ValueKey('confirmar-novo-token'));
    if (sim && mounted) await ref.read(controladorMcpProvider.notifier).gerarNovoToken();
  }
}

class _CopiarConfiguracao extends StatelessWidget {
  const _CopiarConfiguracao({required this.endereco, required this.token});

  final String endereco;
  final String token;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final rotulos = {
      ClienteMcp.lmStudio: l.mcpClienteLmStudio,
      ClienteMcp.claudeDesktop: l.mcpClienteClaudeDesktop,
      ClienteMcp.generico: l.mcpClienteGenerico,
    };
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l.mcpCopiarConfiguracao, style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: Espacos.xs),
      Wrap(spacing: Espacos.s, runSpacing: Espacos.s, children: [
        for (final MapEntry(key: cliente, value: rotulo) in rotulos.entries)
          OutlinedButton.icon(
            key: ValueKey('mcp-copiar-${cliente.name}'),
            icon: const Icon(Icons.content_copy, size: Espacos.l),
            label: Text(rotulo),
            onPressed: () => copiarComAviso(context, trechoConfiguracao(cliente, endereco: endereco, token: token)),
          ),
      ]),
    ]);
  }
}

Future<void> copiarComAviso(BuildContext context, String texto) async {
  final mensageiro = ScaffoldMessenger.of(context);
  final aviso = AppLocalizations.of(context).mcpCopiado;
  await Clipboard.setData(ClipboardData(text: texto));
  mensageiro.showSnackBar(SnackBar(content: Text(aviso)));
}
