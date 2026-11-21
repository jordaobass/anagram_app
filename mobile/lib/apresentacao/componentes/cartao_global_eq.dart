// Global EQ da pedaleira, como a tela dela: o seletor de modo (ganho em
// verde, frequência em roxo, largura em laranja), a curva somada das 6
// bandas na cor do modo, com um ponto por banda que se arrasta em
// frequência × ganho, e as 6 bandas com o valor do modo. "Input Gain" leva
// ao cartão Entrada; "Reset" volta aos padrões de fábrica, com desfazer.
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_ajustes.dart';
import '../../l10n/app_localizations.dart';
import '../../nucleo/ajustes/curva_global_eq.dart';
import '../../nucleo/ajustes/mapa_ajustes.dart';
import '../tema/tokens.dart';
import 'cartao_secao_synth.dart';
import 'controles_ajuste.dart';
import 'dialogo_confirmar.dart';
import 'fileira_bandas_eq.dart';
import 'pintor_global_eq.dart';

class CartaoGlobalEq extends ConsumerStatefulWidget {
  const CartaoGlobalEq({super.key, this.aoIrParaEntrada});

  final VoidCallback? aoIrParaEntrada;

  @override
  ConsumerState<CartaoGlobalEq> createState() => _CartaoGlobalEqState();
}

class _CartaoGlobalEqState extends ConsumerState<CartaoGlobalEq> {
  ModoEq _modo = ModoEq.gain;
  int? _ativa;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final bandas = bandasDaTela(ref.watch(controladorAjustesProvider));
    return CartaoSecaoSynth(
      key: const ValueKey('cartao-global-eq'),
      titulo: l.pdGlobalEq,
      largura: double.infinity,
      chave: _acoes(l),
      desenho: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SeletorModoEq(modo: _modo, aoEscolher: (m) => setState(() => _modo = m)),
        const SizedBox(height: Espacos.s),
        _curva(bandas),
        const SizedBox(height: Espacos.xs),
        Text(l.pdEqDica, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Cores.textoSecundario)),
      ]),
      filhos: [
        FileiraBandasEq(modo: _modo),
        AvisoErroAjustes(ids: {for (final a in ajustesConfirmados(GrupoAjuste.globalEq)) a.id}),
      ],
    );
  }

  Widget _acoes(AppLocalizations l) => Row(mainAxisSize: MainAxisSize.min, children: [
        TextButton(key: const ValueKey('eq-input-gain'), onPressed: widget.aoIrParaEntrada, child: Text(l.pdEqInputGain)),
        TextButton(key: const ValueKey('eq-reset'), onPressed: _reset, child: Text(l.pdEqReset)),
      ]);

  /// Pergunta, volta as 18 chaves ao padrão de fábrica e oferece desfazer.
  Future<void> _reset() async {
    final l = AppLocalizations.of(context);
    final mensageiro = ScaffoldMessenger.of(context);
    final sim = await confirmar(context,
        titulo: l.pdEqResetTitulo,
        texto: l.pdEqResetTexto,
        rotuloCancelar: l.cancelar,
        rotuloConfirmar: l.pdEqResetConfirmar,
        chaveConfirmar: const ValueKey('confirmar-reset-eq'));
    if (!sim) return;
    final controlador = ref.read(controladorAjustesProvider.notifier);
    final estado = ref.read(controladorAjustesProvider);
    final antes = {for (final a in ajustesConfirmados(GrupoAjuste.globalEq)) a: estado.valor(a) ?? a.padrao};
    antes.forEach((a, _) => controlador.alterar(a, a.padrao));
    mensageiro.showSnackBar(SnackBar(
      content: Text(l.pdEqResetFeito),
      action: SnackBarAction(label: l.desfazer, onPressed: () => antes.forEach(controlador.alterar)),
    ));
  }

  void _arrastar(Offset local, Size tamanho, {bool comecando = false}) {
    final bandas = bandasDaTela(ref.read(controladorAjustesProvider));
    final g = GeometriaGlobalEq(tamanho);
    if (comecando) _ativa = _maisPerto(bandas.map((b) => g.ponto(b)).toList(), local);
    final i = _ativa;
    if (i == null) return;
    final controlador = ref.read(controladorAjustesProvider.notifier);
    final banda = bandasEqGlobal[i];
    controlador.alterar(ajustePorIdOuChave(banda.id(ModoEq.freq))!, g.frequencia(local.dx));
    controlador.alterar(ajustePorIdOuChave(banda.id(ModoEq.gain))!, g.ganho(local.dy));
    setState(() {});
  }

  static int? _maisPerto(List<Offset> pontos, Offset alvo) {
    int? melhor;
    var menor = Medidas.alcancePontoEq;
    for (var i = 0; i < pontos.length; i++) {
      final d = (pontos[i] - alvo).distance;
      if (d <= menor) (melhor, menor) = (i, d);
    }
    return melhor;
  }

  Widget _curva(List<BandaGlobalEq> bandas) => SizedBox(
        height: Medidas.alturaCurvaGlobalEq,
        child: LayoutBuilder(builder: (context, restricoes) {
          final tamanho = Size(restricoes.maxWidth, Medidas.alturaCurvaGlobalEq);
          // arraste vertical e horizontal (não "pan"): assim o ponto vence o
          // rolar da tela, como os knobs; a posição inteira vale nos dois eixos
          return GestureDetector(
            key: const ValueKey('curva-global-eq'),
            // o ponto pego é o do toque, não o de onde o dedo já tinha andado
            dragStartBehavior: DragStartBehavior.down,
            onVerticalDragStart: (d) => _arrastar(d.localPosition, tamanho, comecando: true),
            onVerticalDragUpdate: (d) => _arrastar(d.localPosition, tamanho),
            onVerticalDragEnd: (_) => setState(() => _ativa = null),
            onHorizontalDragStart: (d) => _arrastar(d.localPosition, tamanho, comecando: true),
            onHorizontalDragUpdate: (d) => _arrastar(d.localPosition, tamanho),
            onHorizontalDragEnd: (_) => setState(() => _ativa = null),
            child: CustomPaint(
                size: tamanho, painter: PintorGlobalEq(bandas, cor: Cores.doModoEq(_modo), ativa: _ativa)),
          );
        }),
      );
}

/// As 6 bandas com o valor da tela (o mexido ou o lido; sem leitura, o padrão).
List<BandaGlobalEq> bandasDaTela(EstadoAjustes estado) => [
      for (final banda in bandasEqGlobal)
        BandaGlobalEq(
          banda.tipo,
          _valor(estado, banda, ModoEq.freq),
          _valor(estado, banda, ModoEq.gain),
          _valor(estado, banda, ModoEq.width),
        ),
    ];

double _valor(EstadoAjustes estado, BandaEqGlobal banda, ModoEq modo) {
  final a = ajustePorIdOuChave(banda.id(modo))!;
  return (estado.valor(a) ?? a.padrao).toDouble();
}

/// Os três modos, botões de ícone na cor de cada um, como o canto da tela da
/// Anagram: o escolhido fica cheio, os outros só com o contorno.
class SeletorModoEq extends StatelessWidget {
  const SeletorModoEq({super.key, required this.modo, required this.aoEscolher});

  final ModoEq modo;
  final ValueChanged<ModoEq> aoEscolher;

  static IconData _icone(ModoEq m) => switch (m) {
        ModoEq.gain => Icons.unfold_more,
        ModoEq.freq => Icons.code,
        ModoEq.width => Icons.width_normal_outlined,
      };

  static String _nome(AppLocalizations l, ModoEq m) => switch (m) {
        ModoEq.gain => l.pdEqModoGanho,
        ModoEq.freq => l.pdEqModoFrequencia,
        ModoEq.width => l.pdEqModoLargura,
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(children: [
      for (final m in ModoEq.values)
        Padding(
          padding: const EdgeInsets.only(right: Espacos.s),
          child: Tooltip(
            message: _nome(l, m),
            child: IconButton(
              key: ValueKey('modo-eq-${m.name}'),
              onPressed: () => aoEscolher(m),
              isSelected: m == modo,
              icon: Icon(_icone(m), color: m == modo ? Cores.textoSobreModoEq : Cores.doModoEq(m)),
              style: IconButton.styleFrom(
                backgroundColor: m == modo ? Cores.doModoEq(m) : Colors.transparent,
                side: BorderSide(color: Cores.doModoEq(m)),
              ),
            ),
          ),
        ),
      Text(_nome(l, modo), style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Cores.doModoEq(modo))),
    ]);
  }
}
