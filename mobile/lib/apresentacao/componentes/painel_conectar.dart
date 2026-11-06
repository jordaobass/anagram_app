// Tela sem conexão: conectar a pedaleira (com o motivo, quando a plataforma
// não deixa) ou abrir a demonstração.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_conexao.dart';
import '../../aplicacao/estado/estado_conexao.dart';
import '../../aplicacao/provedores.dart';
import '../../plataforma/fabrica_transporte.dart';
import '../tema/tokens.dart';

class PainelConectar extends ConsumerWidget {
  const PainelConectar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conexao = ref.watch(conexaoProvider);
    final suporte = ref.watch(fabricaTransporteProvider).suporte;
    final tema = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Espacos.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Medidas.larguraConteudoVazio),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Conecte a Anagram pelo USB', style: tema.titleLarge),
            const SizedBox(height: Espacos.s),
            Text('Feche o Darkglass Suite antes: só um programa por vez controla a pedaleira.',
                style: tema.bodyMedium),
            const SizedBox(height: Espacos.xl),
            ..._botoes(ref, tema, suporte, ocupado: conexao is Conectando),
            ..._aviso(tema, conexao),
          ]),
        ),
      ),
    );
  }

  static List<Widget> _botoes(WidgetRef ref, TextTheme tema, SuporteAparelho suporte, {required bool ocupado}) {
    final controlador = ref.read(conexaoProvider.notifier);
    return [
      FilledButton.icon(
        key: const ValueKey('botao-conectar'),
        onPressed: ocupado || suporte is AparelhoIndisponivel ? null : controlador.conectarAparelho,
        icon: const Icon(Icons.usb),
        label: const Text('CONECTAR PELO USB'),
      ),
      const SizedBox(height: Espacos.xs),
      Text(
        switch (suporte) {
          AparelhoDisponivel(:final meio) => 'Via $meio.',
          AparelhoIndisponivel(:final motivo) => motivo,
        },
        style: tema.bodySmall,
      ),
      if (ocupado) ...[
        const SizedBox(height: Espacos.m),
        const LinearProgressIndicator(),
        const SizedBox(height: Espacos.s),
        OutlinedButton(
          key: const ValueKey('botao-cancelar-conexao'),
          onPressed: controlador.cancelarConexao,
          child: const Text('CANCELAR'),
        ),
      ],
      const SizedBox(height: Espacos.m),
      OutlinedButton.icon(
        key: const ValueKey('botao-demonstracao'),
        onPressed: ocupado ? null : controlador.conectarDemonstracao,
        icon: const Icon(Icons.science_outlined),
        label: const Text('ABRIR DEMONSTRAÇÃO'),
      ),
    ];
  }

  static List<Widget> _aviso(TextTheme tema, EstadoConexao conexao) {
    final texto = switch (conexao) {
      FalhaDeConexao(:final mensagem) => mensagem,
      SemConexao(:final aviso) => aviso,
      _ => null,
    };
    if (texto == null) return const [];
    return [
      const SizedBox(height: Espacos.xl),
      Text(texto, key: const ValueKey('aviso-conexao'), style: tema.bodyLarge?.copyWith(color: Cores.erro)),
    ];
  }
}
