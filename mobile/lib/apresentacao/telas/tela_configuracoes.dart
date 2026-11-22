// Configurações do app: idioma, os ajustes globais da pedaleira conectada (e a
// pausa entre pacotes USB, que vale mesmo sem pedaleira) e,
// no computador, a IA local pelo MCP, as atualizações e o registro para
// suporte. Abre pela engrenagem da barra de cima, conectado ou não; no
// celular, onde a barra não tem lugar para o "i", é por aqui que se chega ao Sobre.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/diagnostico.dart';
import '../../aplicacao/estado/controlador_conexao.dart';
import '../../aplicacao/estado/estado_conexao.dart';
import '../../aplicacao/mcp/controlador_mcp.dart';
import '../../aplicacao/versao_nova.dart';
import '../../l10n/app_localizations.dart';
import '../componentes/painel_mcp.dart';
import '../componentes/secao_pedaleira.dart';
import '../componentes/secao_registro.dart';
import '../componentes/secao_versao_nova.dart';
import '../componentes/seletor_pausa.dart';
import '../componentes/seletor_idioma.dart';
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
      ..._secao(l.pdSecao, _pedaleira(ref.watch(conexaoProvider) is Conectada)),
      if (ref.watch(mcpDisponivelProvider)) ..._secao(l.mcpSecao, const PainelMcp()),
      if (ref.watch(verificacaoVersaoDisponivelProvider)) ..._secao(l.versaoNovaSecao, const SecaoVersaoNova()),
      if (ref.watch(registroEmArquivoProvider) case final arquivo?) ..._secao(l.registroSecao, SecaoRegistro(arquivo)),
      const SizedBox(height: Espacos.xxl),
      ListTile(
        key: const ValueKey('abrir-sobre'),
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.info_outline),
        title: Text(l.sobreTitulo),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => const RotaCreditos().push<void>(context),
      ),
    ];
  }

  /// Os ajustes globais só existem com uma pedaleira (ou a demonstração) do
  /// outro lado; a pausa USB vale também antes de conectar.
  static Widget _pedaleira(bool conectada) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (conectada) ...[const SecaoPedaleira(), const SizedBox(height: Espacos.l)],
        const AjustePausaUsb(),
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
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Cores.aluminioClaro)),
      );
}
