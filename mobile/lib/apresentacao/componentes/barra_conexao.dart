// Estado da conexão sempre à vista, interruptor "Ao vivo" e a latência do
// último envio. A versão do app fica na tela Sobre: aqui só o essencial.
// Com o MCP escutando, um selo "IA" lembra que outro programa pode mexer.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_conexao.dart';
import '../../aplicacao/estado/controlador_editor.dart';
import '../../aplicacao/estado/estado_conexao.dart';
import '../../aplicacao/mcp/controlador_mcp.dart';
import '../rotas.dart';
import '../tema/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../textos.dart';

class BarraConexao extends ConsumerWidget {
  const BarraConexao({super.key, required this.compacta});

  final bool compacta;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conexao = ref.watch(conexaoProvider);
    final l = AppLocalizations.of(context);
    final (cor, texto) = _resumo(l, conexao);
    return Container(
      constraints: const BoxConstraints(minHeight: Medidas.barraConexaoAltura),
      padding: const EdgeInsets.symmetric(horizontal: Espacos.l),
      decoration: const BoxDecoration(
        color: Cores.painel,
        border: Border(bottom: BorderSide(color: Cores.filete)),
      ),
      child: Row(
        children: [
          Flexible(child: _Estado(cor: cor, texto: texto, linhas: compacta ? 2 : 1)),
          const SizedBox(width: Espacos.s),
          if (conexao is Conectada) _AoVivo(compacta: compacta),
          if (conexao is Conectada)
            IconButton(
              tooltip: l.desconectar,
              icon: const Icon(Icons.link_off),
              onPressed: ref.read(conexaoProvider.notifier).desconectar,
            ),
          const SeloMcp(),
          IconButton(
            key: const ValueKey('botao-configuracoes'),
            tooltip: l.mcpConfiguracoes,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => const RotaConfiguracoes().push<void>(context),
          ),
          // no celular não cabem os dois: o Sobre fica dentro das Configurações
          if (!compacta)
            IconButton(
              tooltip: l.creditos,
              icon: const Icon(Icons.info_outline),
              onPressed: () => const RotaCreditos().push<void>(context),
            ),
        ],
      ),
    );
  }

  static (Color, String) _resumo(AppLocalizations l, EstadoConexao estado) => switch (estado) {
    SemConexao() => (Cores.ledDesligado, l.estadoSemConexao),
    Conectando(demonstracao: true) => (Cores.tally, l.txEstadoAbrindoDemonstracao),
    Conectando(:final meio) => (Cores.tally, l.estadoConectando(TextosDoApp.meioVisivel(meio))),
    Conectada(demonstracao: true) => (Cores.ledDemonstracao, l.estadoDemonstracao),
    Conectada(:final meio, :final firmware) =>
      (Cores.ledLigado, l.estadoConectada(TextosDoApp.meioVisivel(meio), firmware)),
    FalhaDeConexao() => (Cores.erro, l.estadoFalha),
  };
}

/// LED + frase do estado, anunciada a leitores de tela quando muda.
class _Estado extends StatelessWidget {
  const _Estado({required this.cor, required this.texto, required this.linhas});

  final Color cor;
  final String texto;
  final int linhas;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    label: AppLocalizations.of(context).conexaoSemantica(texto),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          key: const ValueKey('led-conexao'),
          width: Medidas.led,
          height: Medidas.led,
          decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
        ),
        const SizedBox(width: Espacos.s),
        Flexible(
          child: Text(texto, maxLines: linhas, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleSmall),
        ),
      ],
    ),
  );
}

class _AoVivo extends ConsumerWidget {
  const _AoVivo({required this.compacta});

  final bool compacta;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aoVivo = ref.watch(editorProvider.select((e) => e.aoVivo));
    final latencia = ref.watch(editorProvider.select((e) => e.latencia));
    final tema = Theme.of(context).textTheme;
    final l = AppLocalizations.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (latencia != null && aoVivo && !compacta)
          Text(l.idaEVolta(latencia.inMilliseconds), style: tema.labelMedium),
        const SizedBox(width: Espacos.s),
        // desligado precisa saltar aos olhos: a pedaleira não ouve as edições
        Container(
          key: const ValueKey('rotulo-ao-vivo'),
          padding: const EdgeInsets.symmetric(horizontal: Espacos.s, vertical: Espacos.xxs),
          color: aoVivo ? Colors.transparent : Cores.fitaAlerta,
          child: Text(aoVivo ? l.aoVivo : l.aoVivoDesligado,
              style: tema.labelLarge?.copyWith(color: aoVivo ? Cores.tally : Cores.sobreAlerta)),
        ),
        Switch(
          key: const ValueKey('interruptor-ao-vivo'),
          value: aoVivo,
          activeThumbColor: Cores.tally,
          onChanged: ref.read(editorProvider.notifier).definirAoVivo,
        ),
      ],
    );
  }
}

/// Selo discreto enquanto o MCP escuta: o som pode mudar sem a pessoa tocar.
class SeloMcp extends ConsumerWidget {
  const SeloMcp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(controladorMcpProvider.select((e) => e.situacao)) is! McpEscutando) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    return Tooltip(
      message: l.mcpAtivoDica,
      child: Container(
        key: const ValueKey('selo-mcp'),
        padding: const EdgeInsets.symmetric(horizontal: Espacos.s, vertical: Espacos.xxs),
        decoration: BoxDecoration(
          border: Border.all(color: Cores.ledLigado),
          borderRadius: BorderRadius.circular(Raios.canto),
        ),
        child: Text(l.mcpAtivoNaBarra, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Cores.ledLigado)),
      ),
    );
  }
}
