// Configurações do app, nesta ordem: idioma, aparência (sistema, escuro ou
// claro), a pedaleira (ajustes globais da conectada, a pausa entre pacotes
// USB e o conectar ao abrir) e, no computador, o backup dos presets, a IA
// local pelo MCP, as atualizações e o registro para suporte; por último, o
// Sobre, com a versão do app. Abre pela engrenagem, à direita da barra de
// cima, conectado ou não; é por aqui que se chega ao Sobre em toda tela
// (a barra não tem mais o "i", DECISOES BS1).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/conectar_ao_abrir.dart';
import '../../aplicacao/copias/copia_automatica.dart';
import '../../aplicacao/diagnostico.dart';
import '../../aplicacao/estado/controlador_conexao.dart';
import '../../aplicacao/estado/estado_conexao.dart';
import '../../aplicacao/mcp/controlador_mcp.dart';
import '../../aplicacao/versao_app.dart';
import '../../aplicacao/versao_nova.dart';
import '../../l10n/app_localizations.dart';
import '../componentes/interruptor_conectar_ao_abrir.dart';
import '../componentes/painel_mcp.dart';
import '../componentes/secao_copias.dart';
import '../componentes/secao_pedaleira.dart';
import '../componentes/secao_registro.dart';
import '../componentes/secao_versao_nova.dart';
import '../componentes/seletor_pausa.dart';
import '../componentes/seletor_idioma.dart';
import '../componentes/seletor_tema.dart';
import '../rotas.dart';
import '../tema/tokens.dart';

class TelaConfiguracoes extends ConsumerWidget {
  const TelaConfiguracoes({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context).mcpConfiguracoes)),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Medidas.larguraConfiguracoes),
            child: ListView(padding: const EdgeInsets.all(Espacos.xl), children: _secoes(context, ref)),
          ),
        ),
      );

  List<Widget> _secoes(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return [
      // o idioma vem antes de tudo: quem caiu num idioma que não lê precisa achá-lo
      TituloSecao(l.idioma),
      const Align(alignment: Alignment.centerLeft, child: SeletorIdioma()),
      ..._secao(l.temaSecao, const Align(alignment: Alignment.centerLeft, child: SeletorTema())),
      ..._secao(
          l.pdSecao,
          _pedaleira(
            conectada: ref.watch(conexaoProvider) is Conectada,
            procuraAoAbrir: ref.watch(plataformaDeAberturaProvider) != PlataformaDeAbertura.semTentativa,
          )),
      // o backup vem logo depois da pedaleira: é a rede de segurança de quem grava nela
      if (ref.watch(pastaDeCopiasProvider) case final pasta?) ..._secao(l.bkSecao, SecaoCopias(pasta)),
      if (ref.watch(mcpDisponivelProvider)) ..._secao(l.mcpSecao, const PainelMcp()),
      if (ref.watch(verificacaoVersaoDisponivelProvider)) ..._secao(l.versaoNovaSecao, const SecaoVersaoNova()),
      if (ref.watch(registroEmArquivoProvider) case final arquivo?) ..._secao(l.registroSecao, SecaoRegistro(arquivo)),
      const SizedBox(height: Espacos.xxl),
      ListTile(
        key: const ValueKey('abrir-sobre'),
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.info_outline),
        title: Text(l.sobreTitulo),
        subtitle: _versaoDoApp(ref, l),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => const RotaCreditos().push<void>(context),
      ),
    ];
  }

  /// "App v0.2.0" sob o Sobre: quem vai relatar um problema acha a versão
  /// sem abrir mais nada.
  static Widget? _versaoDoApp(WidgetRef ref, AppLocalizations l) {
    final (:versao, comArte: _) = ref.watch(rotuloVersaoProvider);
    if (versao.isEmpty) return null;
    return Text(l.versaoAppNaBarra(versao), key: const ValueKey('versao-app-configuracoes'));
  }

  /// Os ajustes globais só existem com uma pedaleira (ou a demonstração) do
  /// outro lado; a pausa USB e o conectar ao abrir (só no computador) valem
  /// também antes de conectar.
  static Widget _pedaleira({required bool conectada, required bool procuraAoAbrir}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (conectada) ...[const SecaoPedaleira(), const SizedBox(height: Espacos.l)],
        const AjustePausaUsb(),
        if (procuraAoAbrir) ...[const SizedBox(height: Espacos.m), const InterruptorConectarAoAbrir()],
      ]);

  static List<Widget> _secao(String titulo, Widget conteudo) =>
      [const SizedBox(height: Espacos.xxl), TituloSecao(titulo), conteudo];
}

/// Título de seção em alumínio: o âmbar é só de seleção e ação (DESIGN.md).
class TituloSecao extends StatelessWidget {
  const TituloSecao(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: Espacos.s),
        child: Text(texto.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: context.cores.aluminioClaro)),
      );
}
