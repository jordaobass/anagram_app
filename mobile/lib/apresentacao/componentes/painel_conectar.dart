// Tela sem conexão: conectar a pedaleira ou abrir a demonstração. O aviso
// (erro ao conectar, cabo que saiu) fica logo acima das ações, perto de onde a
// pessoa vai agir. Onde a plataforma não alcança o USB (iPhone/iPad, navegador
// sem WebHID), a demonstração vira a ação principal e o porquê fica a um toque.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/avisos.dart';
import '../../aplicacao/estado/controlador_conexao.dart';
import '../../aplicacao/estado/estado_conexao.dart';
import '../../aplicacao/provedores.dart';
import '../../l10n/app_localizations.dart';
import '../../nucleo/suporte_aparelho.dart';
import '../tema/tokens.dart';
import '../textos.dart';
import '../app_anagram.dart';
import 'caminho_monitoramento_entrada.dart';
import 'fita_gaffer.dart';
import 'seletor_idioma.dart';

class PainelConectar extends ConsumerWidget {
  const PainelConectar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conexao = ref.watch(conexaoProvider);
    final suporte = ref.watch(fabricaTransporteProvider).suporte;
    final l = AppLocalizations.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Espacos.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Medidas.larguraConteudoVazio),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const _Identidade(),
            const SizedBox(height: Espacos.xl),
            ..._cabecalho(context, l, suporte),
            const SizedBox(height: Espacos.xl),
            ..._aviso(context, l, conexao),
            ..._acoes(context, ref, l, suporte, conexao),
            const SizedBox(height: Espacos.xl),
            const Align(alignment: Alignment.centerRight, child: MenuIdioma()),
          ]),
        ),
      ),
    );
  }

  static List<Widget> _cabecalho(BuildContext context, AppLocalizations l, SuporteAparelho suporte) {
    final tema = Theme.of(context).textTheme;
    return switch (suporte) {
      AparelhoDisponivel() => [
          Text(l.conecteTitulo, style: tema.titleLarge),
          const SizedBox(height: Espacos.s),
          Text(l.conecteFecheSuite, style: tema.bodyMedium),
        ],
      AparelhoIndisponivel(:final motivo) => [
          Text(l.txModoDemonstracaoTitulo, style: tema.titleLarge),
          const SizedBox(height: Espacos.s),
          Text(l.txSemUsbAquiCurto, style: tema.bodyMedium),
          Align(alignment: Alignment.centerLeft, child: _PorQue(motivo: motivo)),
        ],
    };
  }

  static List<Widget> _acoes(BuildContext context, WidgetRef ref, AppLocalizations l, SuporteAparelho suporte,
      EstadoConexao conexao) {
    final controlador = ref.read(conexaoProvider.notifier);
    final ocupado = conexao is Conectando;
    // sem USB nesta plataforma, a demonstração é o caminho: vira o botão cheio
    final demonstracao = _BotaoDeConexao(
      chave: const ValueKey('botao-demonstracao'),
      icone: Icons.science_outlined,
      rotulo: l.abrirDemonstracao,
      principal: suporte is AparelhoIndisponivel,
      emAndamento: conexao is Conectando && conexao.demonstracao ? l.txEstadoAbrindoDemonstracao : null,
      aoTocar: ocupado ? null : controlador.conectarDemonstracao,
    );
    if (suporte is AparelhoIndisponivel) return [demonstracao, if (ocupado) _cancelar(controlador, l)];
    return [
      _BotaoDeConexao(
        chave: const ValueKey('botao-conectar'),
        icone: Icons.usb,
        rotulo: l.conectarPeloUsb,
        principal: true,
        emAndamento: _conectandoUsb(l, conexao),
        aoTocar: ocupado ? null : controlador.conectarAparelho,
      ),
      const SizedBox(height: Espacos.m),
      demonstracao,
      if (ocupado) _cancelar(controlador, l),
    ];
  }

  /// "Conectando (USB)…" enquanto o USB abre; o botão tocado é que diz. Ao
  /// abrir o app, sem toque, "Procurando a pedaleira…" (DECISOES CA2).
  static String? _conectandoUsb(AppLocalizations l, EstadoConexao conexao) => switch (conexao) {
        Conectando(demonstracao: false, automatica: true) => l.caProcurando,
        Conectando(demonstracao: false, :final meio) => l.estadoConectando(TextosDoApp.meioVisivel(meio)),
        _ => null,
      };

  static Widget _cancelar(ControladorConexao controlador, AppLocalizations l) => Padding(
        padding: const EdgeInsets.only(top: Espacos.m),
        child: OutlinedButton(
          key: const ValueKey('botao-cancelar-conexao'),
          onPressed: controlador.cancelarConexao,
          child: Text(l.cancelar),
        ),
      );

  /// Erro de conexão em vermelho; a pedaleira que saiu é informação, em tom neutro.
  static List<Widget> _aviso(BuildContext context, AppLocalizations l, EstadoConexao conexao) {
    final (aviso, erro) = switch (conexao) {
      FalhaDeConexao(:final aviso) => (aviso, true),
      SemConexao(:final aviso) => (aviso, aviso is! AvisoPedaleiraDesconectada),
      _ => (null, false),
    };
    if (aviso == null) return const [];
    final cor = erro ? context.cores.erro : context.cores.textoSecundario;
    return [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(erro ? Icons.error_outline : Icons.info_outline, color: cor),
        const SizedBox(width: Espacos.s),
        Expanded(
          child: Text(l.aviso(aviso),
              key: const ValueKey('aviso-conexao'),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: erro ? cor : context.cores.texto)),
        ),
      ]),
      if (aviso is AvisoMonitoramentoEntrada) const CaminhoMonitoramentoEntrada(),
      const SizedBox(height: Espacos.l),
    ];
  }
}

/// "01A" em estêncil e o nome do app em fita gaffer, como a faixa do preset
/// no editor e a página do app: a tela de entrada já é o case de estrada.
class _Identidade extends StatelessWidget {
  const _Identidade();

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return ExcludeSemantics(
      child: Row(children: [
        Text('01A', style: tema.displaySmall),
        const SizedBox(width: Espacos.m),
        Flexible(child: FitaGaffer(child: Text(AppAnagram.titulo, maxLines: 1, style: tema.headlineSmall))),
      ]),
    );
  }
}

/// Conectar ou abrir a demonstração. Em andamento, o próprio botão diz o que
/// está acontecendo, com o giro ao lado, e não responde a novo toque.
class _BotaoDeConexao extends StatelessWidget {
  const _BotaoDeConexao({
    required this.chave,
    required this.icone,
    required this.rotulo,
    required this.principal,
    required this.aoTocar,
    this.emAndamento,
  });

  final Key chave;
  final IconData icone;
  final String rotulo;
  final bool principal;
  final VoidCallback? aoTocar;

  /// A frase da espera ("Abrindo a demonstração…"), ou nulo parado.
  final String? emAndamento;

  @override
  Widget build(BuildContext context) {
    final andamento = emAndamento;
    final frente = principal ? context.cores.sobreTally : context.cores.texto;
    final icone = andamento == null
        ? Icon(this.icone)
        : SizedBox.square(
            dimension: Medidas.giroNoBotao,
            child: CircularProgressIndicator(strokeWidth: Medidas.linhaSinal, color: frente),
          );
    final texto = Text(andamento ?? rotulo);
    // em andamento o botão não aceita toque, mas mantém a cor: não está desligado
    final estilo = andamento == null
        ? null
        : (principal
            ? FilledButton.styleFrom(disabledBackgroundColor: context.cores.tally, disabledForegroundColor: frente)
            : OutlinedButton.styleFrom(disabledForegroundColor: frente));
    return principal
        ? FilledButton.icon(key: chave, onPressed: aoTocar, style: estilo, icon: icone, label: texto)
        : OutlinedButton.icon(key: chave, onPressed: aoTocar, style: estilo, icon: icone, label: texto);
  }
}

/// O porquê de não haver USB, guardado atrás de um toque: a explicação inteira
/// (DriverKit, WebHID) não cabe na frase de abertura.
class _PorQue extends StatelessWidget {
  const _PorQue({required this.motivo});

  final MotivoIndisponivel motivo;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return TextButton(
      key: const ValueKey('por-que-sem-usb'),
      onPressed: () => showDialog<void>(
        context: context,
        builder: (contexto) => AlertDialog(
          content: Text(l.indisponivel(motivo)),
          actions: [TextButton(onPressed: () => Navigator.pop(contexto), child: Text(l.txEntendi))],
        ),
      ),
      child: Text(l.txPorQue),
    );
  }
}
