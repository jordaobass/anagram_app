// Um módulo da tela do Axioma, como os da pedaleira: moldura dupla chanfrada
// (tubo ciano por fora, rosa por dentro), a faixa magenta com o título em
// display ("Osc 1 Vol") e o conteúdo embaixo. Entre módulos, a grade de
// furos com parafusos, a "ventilação" do aparelho.
import 'package:flutter/material.dart';

import '../../tema/desenho_metal.dart';
import '../../tema/paletas_painel.dart';
import '../../tema/tokens.dart';
import 'neon.dart';

class ModuloNeon extends StatelessWidget {
  const ModuloNeon({super.key, required this.titulo, required this.child, this.chave, this.apagada = false, this.largura});

  final String titulo;
  final Widget child;

  /// Liga/desliga da seção na faixa do título (o arpejador).
  final Widget? chave;

  /// Seção desligada: o conteúdo apaga, mas continua ajustável.
  final bool apagada;
  final double? largura;

  static const _moldura = 7.0;

  /// Da borda do módulo até o conteúdo (moldura + respiro), para quem
  /// precisa da largura útil.
  static const recuoInterno = _moldura + Espacos.m;
  static const _alturaFaixa = 34.0;
  static const _corpoTitulo = 17.0;

  @override
  Widget build(BuildContext context) {
    final brilho = BrilhoNeon.of(context);
    return SizedBox(
      width: largura,
      child: CustomPaint(
        painter: PintorModuloNeon(fundo: context.cores.painel, brilho: brilho),
        child: Padding(
          padding: const EdgeInsets.all(_moldura),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
            _faixa(),
            Padding(
              padding: const EdgeInsets.all(Espacos.m),
              child: Opacity(opacity: apagada ? Medidas.opacidadeBandaDesligada : 1, child: child),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _faixa() => Container(
        constraints: const BoxConstraints(minHeight: _alturaFaixa),
        padding: const EdgeInsets.symmetric(horizontal: Espacos.s),
        color: CoresNeon.faixaTitulo,
        child: Row(children: [
          Expanded(
            child: Text(titulo,
                textAlign: chave == null ? TextAlign.center : TextAlign.start,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontFamily: Fontes.tecno, fontSize: _corpoTitulo, color: CoresNeon.sobreFaixa)),
          ),
          ?chave,
        ]),
      );
}

/// A moldura dupla: fundo do módulo, tubo ciano chanfrado por fora e tubo
/// rosa por dentro.
class PintorModuloNeon extends CustomPainter {
  const PintorModuloNeon({required this.fundo, required this.brilho});

  final Color fundo;
  final double brilho;

  static Path chanfrado(Rect r, double c) => Path()
    ..moveTo(r.left + c, r.top)
    ..lineTo(r.right - c, r.top)
    ..lineTo(r.right, r.top + c)
    ..lineTo(r.right, r.bottom - c)
    ..lineTo(r.right - c, r.bottom)
    ..lineTo(r.left + c, r.bottom)
    ..lineTo(r.left, r.bottom - c)
    ..lineTo(r.left, r.top + c)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    final fora = (Offset.zero & size).deflate(1.5);
    final dentro = fora.deflate(4);
    canvas.drawPath(chanfrado(fora, 10), Paint()..color = fundo);
    tracoNeon(canvas, chanfrado(fora, 10), CoresNeon.ciano, largura: 2, brilho: brilho);
    tracoNeon(canvas, chanfrado(dentro, 7), CoresNeon.rosa, largura: 1.4, brilho: brilho * 0.8);
  }

  @override
  bool shouldRepaint(PintorModuloNeon antigo) => antigo.fundo != fundo || antigo.brilho != brilho;
}

/// A faixa estreita entre dois módulos: chapa escura com duas colunas de
/// furos e um parafuso em cima e outro embaixo.
class GradeFuros extends StatelessWidget {
  const GradeFuros({super.key});

  static const largura = 22.0;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: SizedBox(width: largura, child: CustomPaint(painter: _PintorGrade(context.cores))),
      );
}

class _PintorGrade extends CustomPainter {
  const _PintorGrade(this.cores);

  final Paleta cores;

  static const _passo = 6.0;
  static const _raioFuro = 1.3;
  static const _margem = 18.0;

  @override
  void paint(Canvas canvas, Size size) {
    final area = Rect.fromLTWH(3, 6, size.width - 6, size.height - 12);
    canvas.drawRect(area, Paint()..color = CoresNeon.barra.last);
    canvas.drawRect(area, Paint()
      ..color = cores.filete
      ..style = PaintingStyle.stroke);
    final furo = Paint()..color = CoresNeon.furo;
    final aro = Paint()
      ..color = cores.filete.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    for (var y = area.top + _margem; y < area.bottom - _margem; y += _passo) {
      for (final x in [area.center.dx - 3, area.center.dx + 3]) {
        canvas.drawCircle(Offset(x, y), _raioFuro, furo);
        canvas.drawCircle(Offset(x, y), _raioFuro, aro);
      }
    }
    for (final y in [area.top + 7, area.bottom - 7]) {
      pintarParafuso(canvas, Offset(area.center.dx, y), 3.4, corpo: cores.aluminio, fenda: CoresNeon.furo);
    }
  }

  @override
  bool shouldRepaint(_PintorGrade antigo) => antigo.cores != cores;
}
