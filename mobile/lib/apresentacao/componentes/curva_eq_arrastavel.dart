// A curva de um equalizador com os pontos que o dedo arrasta: serve ao Global
// EQ da pedaleira e ao bloco Parametric EQ (o mesmo DSP). O ponto pego é o
// mais perto do toque; arrastar muda frequência × ganho da banda (no corte,
// só a frequência — quem decide é [aoArrastar]). Como o knob, avisa
// "arrastando" durante o gesto e, ao soltar, manda o último ponto com
// `arrastando: false`: no bloco é o envio final ao vivo, sem esperar a janela
// do arraste (DECISOES L1, K2). Sem [CurvaEqArrastavel.aoArrastar] a curva só
// se desenha (o Global EQ, que a pedaleira não aplica ao som, DECISOES AJ1).
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../nucleo/ajustes/curva_global_eq.dart';
import '../tema/tokens.dart';
import 'pintor_global_eq.dart';

typedef AoArrastarBanda = void Function(int indice, double frequencia, double ganho, {required bool arrastando});

class CurvaEqArrastavel extends StatefulWidget {
  const CurvaEqArrastavel({
    super.key,
    required this.bandas,
    required this.cor,
    this.aoArrastar,
    this.ganhoGeral = 0,
  });

  final List<BandaGlobalEq> bandas;
  final Color cor;
  final double ganhoGeral;

  /// Nulo = só leitura: sem gesto, a curva não disputa o rolar da tela.
  final AoArrastarBanda? aoArrastar;

  @override
  State<CurvaEqArrastavel> createState() => _CurvaEqArrastavelState();
}

class _CurvaEqArrastavelState extends State<CurvaEqArrastavel> {
  int? _ativa;

  /// Frequência e ganho do último ponto do arraste, que vão de novo ao soltar.
  (double, double)? _ultimo;

  void _arrastar(Offset local, Size tamanho, {bool comecando = false}) {
    final g = GeometriaGlobalEq(tamanho, ganhoGeral: widget.ganhoGeral);
    if (comecando) _ativa = maisPerto(widget.bandas.map(g.ponto).toList(), local);
    final i = _ativa;
    if (i == null) return;
    final ultimo = (g.frequencia(local.dx), g.ganhoDaBanda(local.dy));
    _ultimo = ultimo;
    widget.aoArrastar!(i, ultimo.$1, ultimo.$2, arrastando: true);
    setState(() {});
  }

  /// Fim do gesto, também cancelado: tira o destaque e manda o valor final.
  void _soltar() {
    final (i, ultimo) = (_ativa, _ultimo);
    setState(() {
      _ativa = null;
      _ultimo = null;
    });
    if (i != null && ultimo != null) widget.aoArrastar!(i, ultimo.$1, ultimo.$2, arrastando: false);
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
          final desenho = CustomPaint(
            size: tamanho,
            painter: PintorGlobalEq(widget.bandas, cores: context.cores, cor: widget.cor, ativa: _ativa, ganhoGeral: widget.ganhoGeral),
          );
          if (widget.aoArrastar == null) return desenho;
          // arraste vertical e horizontal (não "pan"): assim o ponto vence o
          // rolar da tela, como os knobs; a posição inteira vale nos dois eixos
          return GestureDetector(
            // o ponto pego é o do toque, não o de onde o dedo já tinha andado
            dragStartBehavior: DragStartBehavior.down,
            onVerticalDragStart: (d) => _arrastar(d.localPosition, tamanho, comecando: true),
            onVerticalDragUpdate: (d) => _arrastar(d.localPosition, tamanho),
            onVerticalDragEnd: (_) => _soltar(),
            onVerticalDragCancel: _soltar,
            onHorizontalDragStart: (d) => _arrastar(d.localPosition, tamanho, comecando: true),
            onHorizontalDragUpdate: (d) => _arrastar(d.localPosition, tamanho),
            onHorizontalDragEnd: (_) => _soltar(),
            onHorizontalDragCancel: _soltar,
            child: desenho,
          );
        }),
      );
}
