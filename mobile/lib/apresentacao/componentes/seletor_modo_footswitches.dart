// O modo dos footswitches (PRESET / STOMP / SCENE), ajuste global da pedaleira:
// o indicador diz o que a pedaleira tem agora e os três botões, como os de
// cena, trocam na hora. Fica no cartão "Footswitches" da seção Pedaleira das
// Configurações; no editor, o modo é o selo da faixa do preset (DECISOES FM7).
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
  const SeletorModoFootswitches({super.key});

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
        _Indicador(texto: nomeDoModo(l, modo)),
        const SizedBox(width: Espacos.m),
        for (final opcao in ModoFootswitches.values) ...[
          if (opcao != ModoFootswitches.values.first) const SizedBox(width: Espacos.s),
          Expanded(child: _BotaoModo(modo: opcao, ativo: modo == opcao, habilitado: disponivel)),
        ],
      ]),
      _Rodape(disponivel: disponivel),
    ]);
  }
}

/// O modo lido (o título do cartão já diz "Footswitches").
class _Indicador extends StatelessWidget {
  const _Indicador({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) => KeyedSubtree(
        key: const ValueKey('indicador-modo-footswitches'),
        child: Text(texto, style: Theme.of(context).textTheme.labelLarge),
      );
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
  const _Rodape({required this.disponivel});

  final bool disponivel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final estilo = Theme.of(context).textTheme.bodySmall;
    final recusado = ref.watch(controladorModoProvider.select((e) => e.recusado));
    final lido = ref.watch(modoLidoProvider);
    return Padding(
      padding: const EdgeInsets.only(top: Espacos.xs),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.fmDica, style: estilo?.copyWith(color: Cores.textoSecundario)),
        if (recusado) Text(l.fmErro, style: estilo?.copyWith(color: Cores.erro)),
        if (lido && !disponivel) Text(l.fmIndisponivel, style: estilo?.copyWith(color: Cores.textoSecundario)),
      ]),
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
