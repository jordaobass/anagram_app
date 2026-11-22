// O modo dos footswitches (PRESET / STOMP / SCENE), ajuste global da pedaleira:
// o indicador diz o que a pedaleira tem agora e os três botões, como os de
// cena, trocam na hora. Aparece no editor, sob as cenas, e no painel da
// pedaleira das Configurações (DECISOES FM3).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_conexao.dart';
import '../../aplicacao/estado/controlador_modo_footswitches.dart';
import '../../aplicacao/estado/estado_conexao.dart';
import '../../l10n/app_localizations.dart';
import '../../nucleo/ajustes/modo_footswitches.dart';
import '../tema/tokens.dart';
import 'botao_tally.dart';

/// "STOMP", ou "—" para modo desconhecido ou ainda não lido.
String nomeDoModo(AppLocalizations l, ModoFootswitches? modo) => l.fmModo(modo?.valor ?? '');

class SeletorModoFootswitches extends ConsumerStatefulWidget {
  const SeletorModoFootswitches({super.key, this.noCartao = false});

  /// Nas Configurações o cartão em volta já diz "Footswitches" e há espaço
  /// para a dica; no editor, onde a altura é dos blocos, a dica fica no
  /// toque longo/passar o mouse do indicador e no painel de Controles.
  final bool noCartao;

  @override
  ConsumerState<SeletorModoFootswitches> createState() => _SeletorModoFootswitchesState();
}

class _SeletorModoFootswitchesState extends ConsumerState<SeletorModoFootswitches> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(controladorModoProvider.notifier).garantirLeitura());
  }

  @override
  Widget build(BuildContext context) {
    if (ref.watch(conexaoProvider) is! Conectada) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final modo = ref.watch(modoExibidoProvider);
    final disponivel = ref.watch(modoDisponivelProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        _Indicador(texto: nomeDoModo(l, modo), comRotulo: !widget.noCartao),
        const SizedBox(width: Espacos.m),
        for (final opcao in ModoFootswitches.values) ...[
          if (opcao != ModoFootswitches.values.first) const SizedBox(width: Espacos.s),
          Expanded(child: _BotaoModo(modo: opcao, ativo: modo == opcao, habilitado: disponivel)),
        ],
      ]),
      _Rodape(disponivel: disponivel, comDica: widget.noCartao),
    ]);
  }
}

/// "FOOTSWITCHES" em rótulo de painel e, embaixo, o modo lido (o indicador).
class _Indicador extends StatelessWidget {
  const _Indicador({required this.texto, required this.comRotulo});

  final String texto;
  final bool comRotulo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final l = AppLocalizations.of(context);
    return Tooltip(
      message: l.fmDica,
      child: Column(
        key: const ValueKey('indicador-modo-footswitches'),
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (comRotulo) Text(l.fmTitulo.toUpperCase(), style: tema.labelMedium?.copyWith(color: Cores.aluminioClaro)),
          Text(texto, style: tema.labelLarge),
        ],
      ),
    );
  }
}

class _BotaoModo extends ConsumerWidget {
  const _BotaoModo({required this.modo, required this.ativo, required this.habilitado});

  final ModoFootswitches modo;
  final bool ativo;
  final bool habilitado;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final nome = nomeDoModo(l, modo);
    final cor = BotaoTally.corDoTexto(ativo: ativo, habilitado: habilitado);
    return BotaoTally(
      chave: ValueKey('modo-footswitches-${modo.valor}'),
      ativo: ativo,
      rotuloSemantico: l.fmSemantica(nome),
      aoTocar: habilitado && !ativo ? () => ref.read(controladorModoProvider.notifier).escolher(modo) : null,
      alturaMinima: Medidas.alvoMinimo,
      filho: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Espacos.xs),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(nome, maxLines: 1, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: cor)),
          ),
        ),
      ),
    );
  }
}

/// A dica do Stomp; e, quando cabe, o aviso de recusa ou de modo indisponível.
class _Rodape extends ConsumerWidget {
  const _Rodape({required this.disponivel, required this.comDica});

  final bool disponivel;
  final bool comDica;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final estilo = Theme.of(context).textTheme.bodySmall;
    final recusado = ref.watch(controladorModoProvider.select((e) => e.recusado));
    final lido = ref.watch(modoLidoProvider);
    final linhas = [
      if (comDica)
        Text(l.fmDica,
            key: const ValueKey('dica-modo-footswitches'), style: estilo?.copyWith(color: Cores.textoSecundario)),
      if (recusado)
        Text(l.fmErro, key: const ValueKey('erro-modo-footswitches'), style: estilo?.copyWith(color: Cores.erro)),
      if (lido && !disponivel) Text(l.fmIndisponivel, style: estilo?.copyWith(color: Cores.textoSecundario)),
    ];
    if (linhas.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: Espacos.xs),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: linhas),
    );
  }
}

/// No painel de Controles: a dica do Stomp e, fora dele, o aviso de que os
/// FOOT atribuídos não agem.
class AvisoModoNosControles extends ConsumerWidget {
  const AvisoModoNosControles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modo = ref.watch(modoExibidoProvider);
    final l = AppLocalizations.of(context);
    final estilo = Theme.of(context).textTheme.bodySmall;
    final foraDoStomp = modo != null && modo != ModoFootswitches.stomp;
    return Padding(
      padding: const EdgeInsets.only(top: Espacos.xs),
      child: Text(
        foraDoStomp ? l.fmAvisoControles(nomeDoModo(l, modo)) : l.fmDica,
        key: ValueKey(foraDoStomp ? 'aviso-modo-controles' : 'dica-modo-controles'),
        style: estilo?.copyWith(color: foraDoStomp ? Cores.aluminioClaro : Cores.textoSecundario),
      ),
    );
  }
}
