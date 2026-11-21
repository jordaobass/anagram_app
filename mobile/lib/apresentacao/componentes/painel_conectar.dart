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
    if (suporte is AparelhoIndisponivel) {
      return [_demonstracao(controlador, l, ocupado: ocupado, principal: true), if (ocupado) ..._progresso(controlador, l)];
    }
    return [
      FilledButton.icon(
        key: const ValueKey('botao-conectar'),
        onPressed: ocupado ? null : controlador.conectarAparelho,
        icon: const Icon(Icons.usb),
        label: Text(l.conectarPeloUsb),
      ),
      if (ocupado) ..._progresso(controlador, l),
      const SizedBox(height: Espacos.m),
      _demonstracao(controlador, l, ocupado: ocupado, principal: false),
    ];
  }

  static Widget _demonstracao(ControladorConexao controlador, AppLocalizations l,
      {required bool ocupado, required bool principal}) {
    final aoTocar = ocupado ? null : controlador.conectarDemonstracao;
    const icone = Icon(Icons.science_outlined);
    final rotulo = Text(l.abrirDemonstracao);
    const chave = ValueKey('botao-demonstracao');
    return principal
        ? FilledButton.icon(key: chave, onPressed: aoTocar, icon: icone, label: rotulo)
        : OutlinedButton.icon(key: chave, onPressed: aoTocar, icon: icone, label: rotulo);
  }

  static List<Widget> _progresso(ControladorConexao controlador, AppLocalizations l) => [
        const SizedBox(height: Espacos.m),
        // âmbar: é a ação em curso, não um estado neutro
        const LinearProgressIndicator(color: Cores.tally, backgroundColor: Cores.painelElevado),
        const SizedBox(height: Espacos.s),
        OutlinedButton(
          key: const ValueKey('botao-cancelar-conexao'),
          onPressed: controlador.cancelarConexao,
          child: Text(l.cancelar),
        ),
      ];

  /// Erro de conexão em vermelho; a pedaleira que saiu é informação, em tom neutro.
  static List<Widget> _aviso(BuildContext context, AppLocalizations l, EstadoConexao conexao) {
    final (aviso, erro) = switch (conexao) {
      FalhaDeConexao(:final aviso) => (aviso, true),
      SemConexao(:final aviso) => (aviso, aviso is! AvisoPedaleiraDesconectada),
      _ => (null, false),
    };
    if (aviso == null) return const [];
    final cor = erro ? Cores.erro : Cores.textoSecundario;
    return [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(erro ? Icons.error_outline : Icons.info_outline, color: cor),
        const SizedBox(width: Espacos.s),
        Expanded(
          child: Text(l.aviso(aviso),
              key: const ValueKey('aviso-conexao'),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: erro ? cor : Cores.texto)),
        ),
      ]),
      const SizedBox(height: Espacos.l),
    ];
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
