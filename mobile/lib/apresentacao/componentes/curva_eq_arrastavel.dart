// A curva de um equalizador com os pontos que o dedo arrasta: serve ao Global
// EQ da pedaleira e ao bloco Parametric EQ (o mesmo DSP). O ponto pego é o
// mais perto do toque; arrastar muda frequência × ganho da banda (no corte,
// só a frequência — quem decide é [aoArrastar]).
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../nucleo/ajustes/curva_global_eq.dart';
import '../tema/tokens.dart';
import 'pintor_global_eq.dart';

typedef AoArrastarBanda = void Function(int indice, double frequencia, double ganho);

class CurvaEqArrastavel extends StatefulWidget {
  const CurvaEqArrastavel({
    super.key,
    required this.bandas,
    required this.cor,
    required this.aoArrastar,
    this.ganhoGeral = 0,
    this.aoSoltar,
  });

  final List<BandaGlobalEq> bandas;
  final Color cor;
  final double ganhoGeral;
  final AoArrastarBanda aoArrastar;

  /// Fim do arraste (o bloco usa para fechar a edição do arraste).
  final VoidCallback? aoSoltar;

  @override
  State<CurvaEqArrastavel> createState() => _CurvaEqArrastavelState();
}

class _CurvaEqArrastavelState extends State<CurvaEqArrastavel> {
  int? _ativa;

  void _arrastar(Offset local, Size tamanho, {bool comecando = false}) {
    final g = GeometriaGlobalEq(tamanho);
    if (comecando) _ativa = maisPerto(widget.bandas.map(g.ponto).toList(), local);
    final i = _ativa;
    if (i == null) return;
    widget.aoArrastar(i, g.frequencia(local.dx), g.ganho(local.dy));
    setState(() {});
  }

  void _soltar() {
    setState(() => _ativa = null);
    widget.aoSoltar?.call();
  }

  /// O ponto mais perto do toque, dentro do alcance do dedo; nulo fora dele.
  static int? maisPerto(List<Offset> pontos, Offset alvo) {
    int? melhor;
    var menor = Medidas.alcancePontoEq;
    for (var i = 0; i < pontos.length; i++) {
      final d = (pontos[i] - alvo).distance;
      if (d <= menor) (melhor, menor) = (i, d);
    }
    return melhor;
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        height: Medidas.alturaCurvaGlobalEq,
        child: LayoutBuilder(builder: (context, restricoes) {
          final tamanho = Size(restricoes.maxWidth, Medidas.alturaCurvaGlobalEq);
          // arraste vertical e horizontal (não "pan"): assim o ponto vence o
          // rolar da tela, como os knobs; a posição inteira vale nos dois eixos
          return GestureDetector(
            // o ponto pego é o do toque, não o de onde o dedo já tinha andado
            dragStartBehavior: DragStartBehavior.down,
            onVerticalDragStart: (d) => _arrastar(d.localPosition, tamanho, comecando: true),
            onVerticalDragUpdate: (d) => _arrastar(d.localPosition, tamanho),
            onVerticalDragEnd: (_) => _soltar(),
            onHorizontalDragStart: (d) => _arrastar(d.localPosition, tamanho, comecando: true),
            onHorizontalDragUpdate: (d) => _arrastar(d.localPosition, tamanho),
            onHorizontalDragEnd: (_) => _soltar(),
            child: CustomPaint(
              size: tamanho,
              painter: PintorGlobalEq(widget.bandas, cor: widget.cor, ativa: _ativa, ganhoGeral: widget.ganhoGeral),
            ),
          );
        }),
      );
}
