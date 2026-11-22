// Estado da conexão sempre à vista, interruptor "Ao vivo" e a latência do
// último envio. A versão do app fica na tela Sobre: aqui só o essencial.
// Com o MCP escutando, um selo "IA" lembra que outro programa pode mexer;
// com versão nova publicada, um aviso discreto oferece baixar.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/versao_app.dart';

import '../../aplicacao/estado/controlador_conexao.dart';
import '../../aplicacao/estado/controlador_editor.dart';
import '../../aplicacao/estado/estado_conexao.dart';
import '../../aplicacao/mcp/controlador_mcp.dart';
import '../rotas.dart';
import '../tema/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../textos.dart';
import 'aviso_versao_nova.dart';

class BarraConexao extends ConsumerWidget {
  const BarraConexao({super.key, required this.compacta});

  final bool compacta;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conexao = ref.watch(conexaoProvider);
    final (cor, texto) = _resumo(AppLocalizations.of(context), context.cores, conexao);
    final medidas = MedidasDoTopo.daPlataforma;
    return _semMargemDeToque(context, medidas, Container(
      constraints: BoxConstraints(minHeight: medidas.barraConexao),
      padding: const EdgeInsets.symmetric(horizontal: Espacos.l),
      decoration: BoxDecoration(
        color: context.cores.painel,
        border: Border(bottom: BorderSide(color: context.cores.filete)),
      ),
      child: Row(children: [
        Flexible(child: _Estado(cor: cor, texto: texto, linhas: compacta ? 2 : 1)),
        // a versão do app ao lado do firmware: ao relatar um problema, as duas
        // estão à vista (no celular e logo acima da quebra larga a barra não
        // comporta: fica no Sobre)
        if (!compacta && MediaQuery.sizeOf(context).width >= Quebras.barraComVersao) const _VersaoNaBarra(),
        const SizedBox(width: Espacos.s),
        if (conexao is Conectada) ..._conectada(context, ref),
        AvisoVersaoNova(compacta: compacta || MediaQuery.sizeOf(context).width < Quebras.barraComAvisoVersao),
        const SeloMcp(),
        ..._navegacao(context),
      ]),
    ));
  }

  /// Com mouse, ícones, interruptor e botões da barra sem a margem de toque
  /// de 48 dp: ficam com 40 px, e a barra com 48 (DECISOES BC1).
  static Widget _semMargemDeToque(BuildContext context, MedidasDoTopo medidas, Widget barra) => medidas.comMouse
      ? Theme(data: Theme.of(context).copyWith(materialTapTargetSize: MaterialTapTargetSize.shrinkWrap), child: barra)
      : barra;

  /// Só com a pedaleira (ou a demonstração) do outro lado: ao vivo e desconectar.
  List<Widget> _conectada(BuildContext context, WidgetRef ref) => [
        _AoVivo(compacta: compacta),
        IconButton(
          tooltip: AppLocalizations.of(context).desconectar,
          icon: const Icon(Icons.link_off),
          onPressed: ref.read(conexaoProvider.notifier).desconectar,
        ),
      ];

  /// Configurações e, fora do celular, o Sobre (lá ele fica dentro das Configurações).
  List<Widget> _navegacao(BuildContext context) {
    final l = AppLocalizations.of(context);
    return [
      IconButton(
        key: const ValueKey('botao-configuracoes'),
        tooltip: l.mcpConfiguracoes,
        icon: const Icon(Icons.settings_outlined),
        onPressed: () => const RotaConfiguracoes().push<void>(context),
      ),
      if (!compacta)
        IconButton(
          tooltip: l.creditos,
          icon: const Icon(Icons.info_outline),
          onPressed: () => const RotaCreditos().push<void>(context),
        ),
    ];
  }

  static (Color, String) _resumo(AppLocalizations l, Paleta cores, EstadoConexao estado) => switch (estado) {
    SemConexao() => (cores.ledDesligado, l.estadoSemConexao),
    Conectando(demonstracao: true) => (cores.tallyTinta, l.txEstadoAbrindoDemonstracao),
    Conectando(automatica: true) => (cores.tallyTinta, l.caProcurando),
    Conectando(:final meio) => (cores.tallyTinta, l.estadoConectando(TextosDoApp.meioVisivel(meio))),
    Conectada(demonstracao: true) => (cores.ledDemonstracao, l.estadoDemonstracao),
    Conectada(:final meio, :final firmware) =>
      (cores.ledLigado, l.estadoConectada(TextosDoApp.meioVisivel(meio), firmware)),
    FalhaDeConexao() => (cores.erro, l.estadoFalha),
  };
}

class _VersaoNaBarra extends ConsumerWidget {
  const _VersaoNaBarra();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (:versao, comArte: _) = ref.watch(rotuloVersaoProvider);
    if (versao.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: Espacos.m),
      child: Text(
        AppLocalizations.of(context).versaoAppNaBarra(versao),
        key: const ValueKey('versao-app-barra'),
        maxLines: 1,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: context.cores.textoSecundario),
      ),
    );
  }
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
          color: aoVivo ? Colors.transparent : context.cores.fitaAlerta,
          child: Text(aoVivo ? l.aoVivo : l.aoVivoDesligado,
              style: tema.labelLarge?.copyWith(color: aoVivo ? context.cores.tallyTinta : context.cores.sobreAlerta)),
        ),
        Switch(
          key: const ValueKey('interruptor-ao-vivo'),
          value: aoVivo,
          activeThumbColor: context.cores.tally,
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
          border: Border.all(color: context.cores.ledLigado),
          borderRadius: BorderRadius.circular(Raios.canto),
        ),
        child: Text(l.mcpAtivoNaBarra, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: context.cores.ledLigado)),
      ),
    );
  }
}
