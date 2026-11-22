// O modo dos footswitches na linha das cenas: três pílulas pequenas, PRESET /
// STOMP / SCENE, com a do modo atual acesa na cor do LED da Anagram (branco,
// roxo e azul-claro — exceção pedida pelo dono à regra do âmbar, DECISOES
// FM8). O desenho é baixo; o alvo tem 48 dp no toque e 32 px com mouse. Trocar acende a nova e
// apaga a antiga; quando a releitura confirma, a nova pulsa; recusa volta ao
// valor real com um tremor curto. Com "reduzir movimento", nada se mexe.
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_conexao.dart';
import '../../aplicacao/estado/controlador_modo_footswitches.dart';
import '../../aplicacao/estado/estado_conexao.dart';
import '../../l10n/app_localizations.dart';
import '../../nucleo/ajustes/modo_footswitches.dart';
import '../tema/tokens.dart';
import 'seletor_modo_footswitches.dart' show nomeDoModo;

/// O movimento das pílulas, num lugar só.
abstract final class MovimentoModo {
  /// Acender a nova e apagar a antiga.
  static const troca = Duration(milliseconds: 220);

  /// Pulso de confirmação e tremor de recusa.
  static const efeito = Duration(milliseconds: 420);

  /// Amplitude do tremor e raio máximo do brilho do pulso, em pixels lógicos.
  static const tremor = 3.0;
  static const brilho = 10.0;

  /// Idas e voltas do tremor.
  static const oscilacoes = 3;
}

/// A cor do LED da pedaleira em cada modo.
Color corDoModo(Paleta cores, ModoFootswitches modo) => switch (modo) {
      ModoFootswitches.preset => cores.modoPreset,
      ModoFootswitches.stomp => cores.modoStomp,
      ModoFootswitches.scene => cores.modoScene,
    };

enum _Efeito { pulso, tremor }

class PilulasModoFootswitches extends ConsumerStatefulWidget {
  const PilulasModoFootswitches({super.key, this.espacoAntes = 0});

  /// Distância das cenas, só quando as pílulas aparecem (conectado).
  final double espacoAntes;

  @override
  ConsumerState<PilulasModoFootswitches> createState() => _PilulasModoFootswitchesState();
}

class _PilulasModoFootswitchesState extends ConsumerState<PilulasModoFootswitches>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animacao;
  _Efeito? _efeito;

  @override
  void initState() {
    super.initState();
    _animacao = AnimationController(vsync: this, duration: MovimentoModo.efeito);
    Future.microtask(() => ref.read(controladorModoProvider.notifier).garantirLeitura());
  }

  @override
  void dispose() {
    _animacao.dispose();
    super.dispose();
  }

  /// A troca terminou: pulso se a pedaleira confirmou, tremor se não.
  void _aoMudar(EstadoModoFootswitches? antes, EstadoModoFootswitches agora) {
    if (antes?.pedido == null || agora.pedido != null || MediaQuery.disableAnimationsOf(context)) return;
    setState(() => _efeito = agora.recusado ? _Efeito.tremor : _Efeito.pulso);
    _animacao.forward(from: 0).whenComplete(() {
      if (mounted) setState(() => _efeito = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(controladorModoProvider, _aoMudar);
    if (ref.watch(conexaoProvider) is! Conectada) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final modo = ref.watch(modoExibidoProvider);
    final ocupado = ref.watch(controladorModoProvider.select((e) => e.pedido != null));
    final habilitado = modo != null && ref.watch(modoDisponivelProvider) && !ocupado;
    final linha = Row(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(width: widget.espacoAntes),
      for (final opcao in ModoFootswitches.values)
        _Pilula(
          modo: opcao,
          acesa: opcao == modo,
          aoTocar: habilitado && opcao != modo ? () => _escolher(opcao) : null,
          pulso: opcao == modo && _efeito == _Efeito.pulso ? _animacao : null,
        ),
    ]);
    return Tooltip(message: _dica(l, modo), child: _tremendo(linha));
  }

  void _escolher(ModoFootswitches modo) => unawaited(ref.read(controladorModoProvider.notifier).escolher(modo));

  String _dica(AppLocalizations l, ModoFootswitches? modo) {
    if (modo != null) return l.fmDica;
    final lido = ref.read(modoLidoProvider);
    return lido && ref.read(modoDisponivelProvider) ? l.fmDesconhecido : l.fmIndisponivel;
  }

  /// O tremor balança a linha na horizontal, amortecendo.
  Widget _tremendo(Widget linha) {
    if (_efeito != _Efeito.tremor) return linha;
    return AnimatedBuilder(
      key: const ValueKey('tremor-modo-footswitches'),
      animation: _animacao,
      builder: (context, filho) {
        final t = _animacao.value;
        final deslocamento = math.sin(t * math.pi * 2 * MovimentoModo.oscilacoes) * MovimentoModo.tremor * (1 - t);
        return Transform.translate(offset: Offset(deslocamento, 0), child: filho);
      },
      child: linha,
    );
  }
}

/// Uma pílula: acesa na cor do modo com texto [Paleta.sobreModo]; apagada só
/// com o contorno de filete e texto secundário. O alvo vem do topo da
/// plataforma (48 dp no toque, 32 px com mouse).
class _Pilula extends StatelessWidget {
  const _Pilula({required this.modo, required this.acesa, required this.aoTocar, required this.pulso});

  final ModoFootswitches modo;
  final bool acesa;
  final VoidCallback? aoTocar;

  /// Presente só enquanto a pílula pulsa.
  final Animation<double>? pulso;

  static double get _alvo => MedidasDoTopo.daPlataforma.alvoPilula;

  @override
  Widget build(BuildContext context) {
    final nome = nomeDoModo(AppLocalizations.of(context), modo);
    return Semantics(
      button: true,
      selected: acesa,
      enabled: aoTocar != null,
      label: AppLocalizations.of(context).fmSemantica(nome),
      excludeSemantics: true,
      child: InkWell(
        key: ValueKey('pilula-modo-${modo.valor}'),
        onTap: aoTocar,
        borderRadius: BorderRadius.circular(_alvo / 2),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: _alvo, minWidth: _alvo),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Espacos.xxs),
            child: Center(widthFactor: 1, child: _comPulso(context, _desenho(context, nome))),
          ),
        ),
      ),
    );
  }

  Widget _desenho(BuildContext context, String nome) {
    final cor = corDoModo(context.cores, modo);
    final duracao = MediaQuery.disableAnimationsOf(context) ? Duration.zero : MovimentoModo.troca;
    final estilo = Theme.of(context).textTheme.labelSmall;
    return AnimatedContainer(
      duration: duracao,
      curve: Curves.easeOut,
      height: Medidas.alturaPilulaModo,
      padding: const EdgeInsets.symmetric(horizontal: Espacos.s),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: acesa ? cor : Colors.transparent,
        borderRadius: BorderRadius.circular(Medidas.alturaPilulaModo / 2),
        border: Border.all(color: acesa ? cor : context.cores.filete, width: Medidas.filete),
      ),
      child: AnimatedDefaultTextStyle(
        duration: duracao,
        curve: Curves.easeOut,
        style: (estilo ?? const TextStyle()).copyWith(color: acesa ? context.cores.sobreModo : context.cores.textoSecundario),
        child: Text(nome, maxLines: 1),
      ),
    );
  }

  /// O pulso: um brilho na cor do modo que cresce e some uma vez.
  Widget _comPulso(BuildContext context, Widget desenho) {
    final animacao = pulso;
    if (animacao == null) return desenho;
    final cor = corDoModo(context.cores, modo);
    return AnimatedBuilder(
      key: const ValueKey('pulso-modo-footswitches'),
      animation: animacao,
      builder: (context, filho) {
        final intensidade = math.sin(animacao.value * math.pi);
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Medidas.alturaPilulaModo / 2),
            boxShadow: [
              BoxShadow(color: cor.withValues(alpha: intensidade), blurRadius: MovimentoModo.brilho * intensidade),
            ],
          ),
          child: filho,
        );
      },
      child: desenho,
    );
  }
}

/// Sob as cenas: a troca de modo não se confirmou (a causa vai para o log).
class AvisoErroModoFootswitches extends ConsumerWidget {
  const AvisoErroModoFootswitches({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(controladorModoProvider.select((e) => e.recusado))) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: Espacos.xs),
      child: Text(AppLocalizations.of(context).fmErro,
          key: const ValueKey('erro-modo-footswitches'),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: context.cores.erro)),
    );
  }
}
