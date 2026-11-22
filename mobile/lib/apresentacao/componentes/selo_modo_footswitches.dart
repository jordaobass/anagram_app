// O modo dos footswitches na faixa do preset: um selo pequeno, "STOMP ▾", que
// abre o menu PRESET / STOMP / SCENE. O desenho é compacto, mas o alvo de
// toque tem 48 dp (como na K5). Em repouso o selo não é âmbar: âmbar é ação e
// seleção. Trocar desliza o texto e, quando a releitura confirma, o selo dá um
// pulso âmbar; recusa volta ao valor real com um tremor curto. Com "reduzir
// movimento" do sistema, nada se mexe (DECISOES FM7).
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

/// O movimento do selo, num lugar só.
abstract final class MovimentoSelo {
  /// Troca do texto: deslize curto com saída exponencial.
  static const troca = Duration(milliseconds: 220);

  /// Pulso de confirmação e tremor de recusa.
  static const efeito = Duration(milliseconds: 420);

  /// Quanto o texto novo sobe ao entrar, em fração da altura.
  static const deslize = 0.45;

  /// Amplitude do tremor, em pixels lógicos.
  static const tremor = 3.0;

  /// Idas e voltas do tremor.
  static const oscilacoes = 3;
}

abstract final class MedidasSelo {
  /// Largura da linha da faixa a partir da qual o selo fica ao lado do nome:
  /// slot (~170) + fita com nome, lápis e NÃO SALVO (~300) + selo (~90).
  static const double larguraParaFicarAoLado = 560;
}

enum _Efeito { pulso, tremor }

class SeloModoFootswitches extends ConsumerStatefulWidget {
  const SeloModoFootswitches({super.key});

  @override
  ConsumerState<SeloModoFootswitches> createState() => _SeloModoFootswitchesState();
}

class _SeloModoFootswitchesState extends ConsumerState<SeloModoFootswitches> with SingleTickerProviderStateMixin {
  late final AnimationController _animacao;
  _Efeito? _efeito;

  @override
  void initState() {
    super.initState();
    _animacao = AnimationController(vsync: this, duration: MovimentoSelo.efeito);
    Future.microtask(() => ref.read(controladorModoProvider.notifier).garantirLeitura());
  }

  @override
  void dispose() {
    _animacao.dispose();
    super.dispose();
  }

  bool get _semMovimento => MediaQuery.disableAnimationsOf(context);

  /// A troca terminou: pulso se a pedaleira confirmou, tremor se não.
  void _aoMudar(EstadoModoFootswitches? antes, EstadoModoFootswitches agora) {
    if (antes?.pedido == null || agora.pedido != null || _semMovimento) return;
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
    return Tooltip(
      message: _dica(l, modo),
      child: Semantics(
        button: true,
        enabled: habilitado,
        label: l.fmSemantica(nomeDoModo(l, modo)),
        excludeSemantics: true,
        child: InkWell(
          key: const ValueKey('selo-modo-footswitches'),
          borderRadius: BorderRadius.circular(Raios.controle),
          onTap: modo != null && habilitado ? () => _abrirMenu(modo) : null,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: Medidas.alvoMinimo, minWidth: Medidas.alvoMinimo),
            child: Center(widthFactor: 1, child: _animado(_Desenho(modo: modo, habilitado: habilitado))),
          ),
        ),
      ),
    );
  }

  String _dica(AppLocalizations l, ModoFootswitches? modo) {
    if (modo != null) return l.fmDica;
    final lido = ref.read(modoLidoProvider);
    return lido && ref.read(modoDisponivelProvider) ? l.fmDesconhecido : l.fmIndisponivel;
  }

  /// O pulso acende o contorno em âmbar e apaga; o tremor balança na horizontal.
  Widget _animado(Widget desenho) {
    final efeito = _efeito;
    if (efeito == null) return desenho;
    return AnimatedBuilder(
      key: ValueKey(efeito == _Efeito.pulso ? 'pulso-modo-footswitches' : 'tremor-modo-footswitches'),
      animation: _animacao,
      builder: (context, filho) {
        final t = _animacao.value;
        if (efeito == _Efeito.tremor) {
          final deslocamento = math.sin(t * math.pi * 2 * MovimentoSelo.oscilacoes) * MovimentoSelo.tremor * (1 - t);
          return Transform.translate(offset: Offset(deslocamento, 0), child: filho);
        }
        return _Desenho.comBrilho(filho!, math.sin(t * math.pi));
      },
      child: desenho,
    );
  }

  Future<void> _abrirMenu(ModoFootswitches atual) async {
    final caixa = context.findRenderObject()! as RenderBox;
    final sobreposicao = Overlay.of(context).context.findRenderObject()! as RenderBox;
    final posicao = RelativeRect.fromRect(
      Rect.fromPoints(caixa.localToGlobal(caixa.size.bottomLeft(Offset.zero), ancestor: sobreposicao),
          caixa.localToGlobal(caixa.size.bottomRight(Offset.zero), ancestor: sobreposicao)),
      Offset.zero & sobreposicao.size,
    );
    final escolha = await showMenu<ModoFootswitches>(
      context: context,
      position: posicao,
      items: [for (final modo in ModoFootswitches.values) _item(modo, marcado: modo == atual)],
    );
    if (escolha != null && escolha != atual) await ref.read(controladorModoProvider.notifier).escolher(escolha);
  }

  PopupMenuItem<ModoFootswitches> _item(ModoFootswitches modo, {required bool marcado}) {
    final l = AppLocalizations.of(context);
    return PopupMenuItem(
      value: modo,
      key: ValueKey('menu-modo-${modo.valor}'),
      child: Row(children: [
        SizedBox(
          width: Medidas.iconeLapis + Espacos.s,
          child: marcado
              ? const Icon(Icons.check, key: ValueKey('modo-marcado'), size: Medidas.iconeLapis, color: Cores.tally)
              : null,
        ),
        Text(nomeDoModo(l, modo),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: marcado ? Cores.tally : Cores.texto)),
      ]),
    );
  }
}

/// O desenho do selo: fundo `painel-elevado`, filete, "STOMP" em label-medium
/// e o ▾ em alumínio. O texto entra deslizando quando o modo muda.
class _Desenho extends StatelessWidget {
  const _Desenho({required this.modo, required this.habilitado});

  final ModoFootswitches? modo;
  final bool habilitado;

  /// O mesmo selo com o contorno aceso em âmbar na intensidade [brilho] (0–1).
  static Widget comBrilho(Widget selo, double brilho) => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Raios.controle),
          border: Border.all(color: Color.lerp(Cores.filete, Cores.tally, brilho)!, width: Medidas.contornoSelecao),
        ),
        position: DecorationPosition.foreground,
        child: selo,
      );

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final cor = habilitado ? Cores.texto : Cores.textoSecundario;
    final semMovimento = MediaQuery.disableAnimationsOf(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(Espacos.s, Espacos.xxs, Espacos.xxs, Espacos.xxs),
      decoration: BoxDecoration(
        color: Cores.painelElevado,
        borderRadius: BorderRadius.circular(Raios.controle),
        border: Border.all(color: Cores.filete, width: Medidas.filete),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        ClipRect(
          child: AnimatedSwitcher(
            duration: semMovimento ? Duration.zero : MovimentoSelo.troca,
            switchInCurve: Curves.easeOutExpo,
            switchOutCurve: Curves.easeOutExpo,
            transitionBuilder: _deslizar,
            child: Text(nomeDoModo(AppLocalizations.of(context), modo),
                key: ValueKey(modo), style: tema.labelMedium?.copyWith(color: cor)),
          ),
        ),
        Icon(Icons.arrow_drop_down, size: Medidas.iconeLapis, color: habilitado ? Cores.aluminioClaro : Cores.filete),
      ]),
    );
  }

  static Widget _deslizar(Widget filho, Animation<double> animacao) => FadeTransition(
        opacity: animacao,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, MovimentoSelo.deslize), end: Offset.zero).animate(animacao),
          child: filho,
        ),
      );
}

/// Sob a faixa: a troca de modo não se confirmou (a causa vai para o log).
class AvisoErroModoFootswitches extends ConsumerWidget {
  const AvisoErroModoFootswitches({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(controladorModoProvider.select((e) => e.recusado))) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: Espacos.xs),
      child: Text(AppLocalizations.of(context).fmErro,
          key: const ValueKey('erro-modo-footswitches'),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Cores.erro)),
    );
  }
}
