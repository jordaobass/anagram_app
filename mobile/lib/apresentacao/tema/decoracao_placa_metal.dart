// A placa anodizada das colunas e cartões do Ignissor e do Entropia: metal
// escuro escovado, reflexo especular, bisel em relevo, ranhura usinada na
// base e parafusos sextavados nos quatro cantos. Uma Decoration, para entrar
// no Container que já existia sem mudar a árvore de widgets.
import 'package:flutter/painting.dart';

import 'desenho_metal.dart';
import 'paletas_painel.dart';
import 'tokens.dart';

class DecoracaoPlacaMetal extends Decoration {
  const DecoracaoPlacaMetal({required this.paleta});

  final Paleta paleta;

  static const raio = Raios.painel;

  @override
  Path getClipPath(Rect rect, TextDirection textDirection) =>
      Path()..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(raio)));

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _PintorPlaca(paleta);

  @override
  bool operator ==(Object other) => other is DecoracaoPlacaMetal && other.paleta == paleta;

  @override
  int get hashCode => paleta.hashCode;
}

class _PintorPlaca extends BoxPainter {
  _PintorPlaca(this.paleta);

  final Paleta paleta;

  // dentro do respiro de 12 px dos cartões: o parafuso não encosta em texto
  static const _recuoParafuso = 6.0;
  static const _raioParafuso = 3.0;
  static const _vaoRanhura = 16.0;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final area = offset & configuration.size!;
    final borda = RRect.fromRectAndRadius(area, const Radius.circular(DecoracaoPlacaMetal.raio));
    canvas.drawRRect(borda, Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [paleta.painelElevado, paleta.painel],
      ).createShader(area));
    canvas.save();
    canvas.clipRRect(borda);
    pintarEscovado(canvas, area, claro: CoresChassi.escovadoPlacaClaro, escuro: CoresChassi.escovadoPlacaEscuro, semente: area.width);
    pintarEspecular(canvas, area, CoresChassi.especularPlaca);
    canvas.restore();
    pintarRanhura(canvas, area.bottomLeft.translate(_vaoRanhura, -_recuoParafuso),
        area.bottomRight.translate(-_vaoRanhura, -_recuoParafuso),
        luz: CoresChassi.luzRanhura, sombra: CoresChassi.sombraRelevo);
    pintarBisel(canvas, borda, luz: CoresChassi.luzBiselPlaca, sombra: CoresChassi.sombraRelevo, largura: 2);
    pintarParafusosNosCantos(canvas, area, _recuoParafuso, _raioParafuso,
        corpo: paleta.aluminio, fenda: paleta.corpoKnob, cabeca: CabecaParafuso.sextavado);
  }
}
