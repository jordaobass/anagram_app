// Estado da conexão sempre à vista, interruptor "Ao vivo" e a latência
// do último envio.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_conexao.dart';
import '../../aplicacao/estado/controlador_editor.dart';
import '../../aplicacao/estado/estado_conexao.dart';
import '../rotas.dart';
import '../tema/tokens.dart';

class BarraConexao extends ConsumerWidget {
  const BarraConexao({super.key, required this.compacta});

  final bool compacta;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conexao = ref.watch(conexaoProvider);
    final (cor, texto) = _resumo(conexao);
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
              tooltip: 'Desconectar',
              icon: const Icon(Icons.link_off),
              onPressed: ref.read(conexaoProvider.notifier).desconectar,
            ),
          IconButton(
            tooltip: 'Créditos',
            icon: const Icon(Icons.info_outline),
            onPressed: () => const RotaCreditos().push<void>(context),
          ),
        ],
      ),
    );
  }

  static (Color, String) _resumo(EstadoConexao estado) => switch (estado) {
    SemConexao() => (Cores.ledDesligado, 'Sem conexão'),
    Conectando(:final meio) => (Cores.tally, 'Conectando ($meio)…'),
    Conectada(demonstracao: true) => (Cores.ledDemonstracao, 'Demonstração · sem pedaleira'),
    Conectada(:final meio, :final firmware) => (Cores.ledLigado, 'Anagram · $meio · $firmware'),
    FalhaDeConexao() => (Cores.erro, 'Falha na conexão'),
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
    label: 'Conexão: $texto',
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (latencia != null && aoVivo && !compacta)
          Text('ida e volta ${latencia.inMilliseconds} ms', style: tema.labelMedium),
        const SizedBox(width: Espacos.s),
        // desligado precisa saltar aos olhos: a pedaleira não ouve as edições
        Container(
          key: const ValueKey('rotulo-ao-vivo'),
          padding: const EdgeInsets.symmetric(horizontal: Espacos.s, vertical: Espacos.xxs),
          color: aoVivo ? Colors.transparent : Cores.fitaAlerta,
          child: Text(aoVivo ? 'AO VIVO' : 'AO VIVO DESLIGADO',
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
