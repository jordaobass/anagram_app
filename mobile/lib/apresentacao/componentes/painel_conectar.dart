// Tela sem conexão: conectar a pedaleira (com o motivo, quando a plataforma
// não deixa) ou abrir a demonstração.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_conexao.dart';
import '../../aplicacao/estado/estado_conexao.dart';
import '../../aplicacao/provedores.dart';
import '../../nucleo/suporte_aparelho.dart';
import '../tema/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../textos.dart';

class PainelConectar extends ConsumerWidget {
  const PainelConectar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conexao = ref.watch(conexaoProvider);
    final suporte = ref.watch(fabricaTransporteProvider).suporte;
    final tema = Theme.of(context).textTheme;
    final l = AppLocalizations.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Espacos.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Medidas.larguraConteudoVazio),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(l.conecteTitulo, style: tema.titleLarge),
            const SizedBox(height: Espacos.s),
            Text(l.conecteFecheSuite, style: tema.bodyMedium),
            const SizedBox(height: Espacos.xl),
            ..._botoes(ref, l, tema, suporte, ocupado: conexao is Conectando),
            ..._aviso(l, tema, conexao),
          ]),
        ),
      ),
    );
  }

  static List<Widget> _botoes(WidgetRef ref, AppLocalizations l, TextTheme tema, SuporteAparelho suporte,
      {required bool ocupado}) {
    final controlador = ref.read(conexaoProvider.notifier);
    return [
      ..._conectarPeloUsb(controlador, l, tema, suporte, ocupado: ocupado),
      if (ocupado) ..._cancelar(controlador, l),
      const SizedBox(height: Espacos.m),
      OutlinedButton.icon(
        key: const ValueKey('botao-demonstracao'),
        onPressed: ocupado ? null : controlador.conectarDemonstracao,
        icon: const Icon(Icons.science_outlined),
        label: Text(l.abrirDemonstracao),
      ),
    ];
  }

  /// Sem suporte na plataforma, o botão fica desligado e o motivo aparece logo
  /// abaixo, em vez de um erro depois do toque.
  static List<Widget> _conectarPeloUsb(
      ControladorConexao controlador, AppLocalizations l, TextTheme tema, SuporteAparelho suporte,
      {required bool ocupado}) {
    return [
      FilledButton.icon(
        key: const ValueKey('botao-conectar'),
        onPressed: ocupado || suporte is AparelhoIndisponivel ? null : controlador.conectarAparelho,
        icon: const Icon(Icons.usb),
        label: Text(l.conectarPeloUsb),
      ),
      const SizedBox(height: Espacos.xs),
      Text(
        switch (suporte) {
          AparelhoDisponivel(:final meio) => l.viaMeio(meio),
          AparelhoIndisponivel(:final motivo) => l.indisponivel(motivo),
        },
        style: tema.bodySmall,
      ),
    ];
  }

  static List<Widget> _cancelar(ControladorConexao controlador, AppLocalizations l) => [
        const SizedBox(height: Espacos.m),
        const LinearProgressIndicator(),
        const SizedBox(height: Espacos.s),
        OutlinedButton(
          key: const ValueKey('botao-cancelar-conexao'),
          onPressed: controlador.cancelarConexao,
          child: Text(l.cancelar),
        ),
      ];

  static List<Widget> _aviso(AppLocalizations l, TextTheme tema, EstadoConexao conexao) {
    final aviso = switch (conexao) {
      FalhaDeConexao(:final aviso) => aviso,
      SemConexao(:final aviso) => aviso,
      _ => null,
    };
    final texto = aviso == null ? null : l.aviso(aviso);
    if (texto == null) return const [];
    return [
      const SizedBox(height: Espacos.xl),
      Text(texto, key: const ValueKey('aviso-conexao'), style: tema.bodyLarge?.copyWith(color: Cores.erro)),
    ];
  }
}
